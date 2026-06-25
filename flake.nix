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
    samplingOpts = "--temp 0.6 --top-k 20 --top-p 0.95";

    rocm-server = pkgs.writeShellApplication {
      name = "rocm-server";
      runtimeInputs = [ pkgs.llama-cpp-rocm ];
      text = ''
        exec llama-server \
          --model "${modelsDir}/$MODEL" \
          --host 0.0.0.0 --port 8080 \
          --jinja \
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
          --host 0.0.0.0 --port 8080 \
          --jinja \
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
            -m "$MODEL_PATH" ${gpuOpts} -p 512 -n 128 -r 3 -o md
      '';
    };

    llama-completion = pkgs.writeShellApplication {
      name = "llama-completion";
      runtimeInputs = [ pkgs.llama-cpp-rocm ];
      text = ''
        exec llama-completion \
          ${gpuOpts} ${samplingOpts} \
          "$@"
      '';
    };

    benchmark-prompt = pkgs.writeShellApplication {
      name = "benchmark-prompt";
      runtimeInputs = [ llama-completion ];
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
          --model "$MODEL_PATH" \
          --ctx-size 16384 \
          --single-turn --simple-io --no-display-prompt \
          --prompt "$(cat "$PROMPT_FILE")" > "$out"

        echo "Wrote $out"
      '';
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        rocm-server
        cpu-server
        download-model
        benchmark-model
        llama-completion
        benchmark-prompt
      ];

      MODEL = "Qwen3.6-27B-Q3_K_M.gguf";
    };
  };
}
