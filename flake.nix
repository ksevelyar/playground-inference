{
  description = "llama.cpp for AMD Radeon RX 9060 XT 16GB for agentic flow";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    modelsDir = "./downloads/models";

    gpuOpts = "--n-gpu-layers 999 --flash-attn on --split-mode none --main-gpu 0";
    samplingOpts = "--temp 0.6 --top-k 20";

    rocm-server = pkgs.writeShellApplication {
      name = "rocm-server";
      runtimeInputs = [ pkgs.llama-cpp-rocm ];
      text = ''
        exec llama-server \
          --model "${modelsDir}/$MODEL" \
          --host 0.0.0.0 \
          ${gpuOpts} ${samplingOpts} \
          --parallel 1 --ctx-size 16384
      '';
    };

    cpu-server = pkgs.writeShellApplication {
      name = "cpu-server";
      runtimeInputs = [ pkgs.llama-cpp ];
      text = ''
        exec llama-server \
          --model "${modelsDir}/$MODEL" \
          --host 0.0.0.0 \
          ${samplingOpts} --ctx-size 8192
      '';
    };

    download-model = pkgs.writeShellApplication {
      name = "download-model";
      runtimeInputs = [ pkgs.wget ];
      text = ''
        URL="''${1:?Usage: download-model <url>}"
        mkdir -p "${modelsDir}"
        wget -c -O "${modelsDir}/$(basename "$URL")" "$URL"
      '';
    };

    benchmark-model = pkgs.writeShellApplication {
      name = "benchmark-model";
      runtimeInputs = [ pkgs.llama-cpp-rocm pkgs.coreutils ];
      text = ''
        MODEL_PATH="${modelsDir}/$MODEL"
        echo "=== Benchmark: $(basename "$MODEL_PATH") ==="
        timeout 120 \
          llama-bench \
            --model "$MODEL_PATH" \
            --n-gpu-layers 999 --flash-attn 1 --split-mode none --main-gpu 0 \
            --n-prompt 512 --n-gen 128 --repetitions 3 --output md
      '';
    };

    benchmark-prompt = pkgs.writeShellApplication {
      name = "benchmark-prompt";
      runtimeInputs = [ pkgs.llama-cpp-rocm ];
      text = ''
        PROMPT_NAME="''${1:?Usage: benchmark-prompt <prompt-name>}"
        PROMPT_FILE="''${PROMPT_FILE:-./prompts/$PROMPT_NAME.md}"
        MODEL_PATH="${modelsDir}/$MODEL"
        MODEL_NAME="$(basename "$MODEL_PATH" .gguf)"
        out="./bench/''${MODEL_NAME}-''${PROMPT_NAME}.md"

        mkdir -p ./bench

        if [ ! -f "$PROMPT_FILE" ]; then
          echo "Prompt file not found: $PROMPT_FILE"
          exit 1
        fi

        llama-completion \
          ${gpuOpts} ${samplingOpts} \
          --model "$MODEL_PATH" \
          --ctx-size 16384 \
          --single-turn --simple-io --no-display-prompt \
          --prompt "$(cat "$PROMPT_FILE")" > "$out"

        echo "Wrote $out"
      '';
    };

    oneshot = pkgs.writeShellApplication {
      name = "oneshot";
      runtimeInputs = [ pkgs.llama-cpp-rocm ];
      text = ''
        PROMPT="''${1:?Usage: oneshot <prompt>}"
        MODEL_PATH="${modelsDir}/$MODEL"
        llama-completion \
          ${gpuOpts} ${samplingOpts} \
          --model "$MODEL_PATH" \
          --ctx-size 16384 \
          --log-disable \
          --single-turn --no-display-prompt \
          --prompt "$PROMPT"
      '';
    };

    chat = pkgs.writeShellApplication {
      name = "chat";
      runtimeInputs = [ pkgs.llama-cpp-rocm ];
      text = ''
        PROMPT="''${1:?Usage: chat <prompt>}"
        MODEL_PATH="${modelsDir}/$MODEL"
        exec llama-cli \
          --model "$MODEL_PATH" \
          --prompt "$PROMPT" \
          ${gpuOpts} ${samplingOpts} --ctx-size 16384
      '';
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        rocm-server
        cpu-server
        download-model
        benchmark-model
        benchmark-prompt
        oneshot
        chat
      ];

      MODEL = "Qwen3.6-27B-Q3_K_M.gguf";
    };
  };
}
