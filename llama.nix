{
  pkgs,
  utils,
}: let
  modelsDir = "./text/models";
  promptsDir = "./text/prompts";
  benchDir = "./text/bench";
  modelsJson = ./llama/models.json;

  modelArgs = pkgs.writeShellApplication {
    name = "model-args";
    runtimeInputs = [pkgs.jq utils.ensureModels utils.jsonToArgs];
    text = ''
      model_json=$(jq -r --arg model_name "$MODEL" '.[$model_name]' ${modelsJson})
      if [ "$model_json" = "null" ]; then
        echo "Error: model '$MODEL' not found in llama/models.json" >&2
        exit 1
      fi

      echo "$model_json" | ensure-models "${modelsDir}"
      echo "$model_json" | json-to-args
    '';
  };
in {
  commands = [
    pkgs.llama-cpp-rocm
    modelArgs

    (pkgs.writeShellApplication {
      name = "rocm-server";
      runtimeInputs = [pkgs.llama-cpp-rocm modelArgs];
      text = ''
        mapfile -t model_args < <(model-args)
        exec llama-server \
          "''${model_args[@]}" \
          --host 0.0.0.0 \
          --parallel 1
      '';
    })

    (pkgs.writeShellApplication {
      name = "benchmark-prompt";
      runtimeInputs = [pkgs.llama-cpp-rocm modelArgs];
      text = ''
        PROMPT_NAME="''${1:?Usage: benchmark-prompt <prompt-name>}"
        PROMPT_FILE="''${PROMPT_FILE:-${promptsDir}/$PROMPT_NAME.md}"
        out="${benchDir}/''${MODEL}-''${PROMPT_NAME}.md"

        mkdir -p "${benchDir}"

        if [ ! -f "$PROMPT_FILE" ]; then
          echo "Prompt file not found: $PROMPT_FILE"
          exit 1
        fi

        mapfile -t model_args < <(model-args)
        llama-completion \
          "''${model_args[@]}" \
          --perf \
          --single-turn --no-display-prompt --no-conversation \
          --prompt "$(cat "$PROMPT_FILE")" > "$out"

        echo "Wrote $out"
      '';
    })

    (pkgs.writeShellApplication {
      name = "oneshot";
      runtimeInputs = [pkgs.llama-cpp-rocm modelArgs];
      text = ''
        PROMPT="''${1:?Usage: oneshot <prompt>}"
        mapfile -t model_args < <(model-args)
        llama-completion \
          "''${model_args[@]}" \
          --log-verbosity 0 \
          --single-turn --no-display-prompt --no-conversation \
          --prompt "$PROMPT"
      '';
    })

    (pkgs.writeShellApplication {
      name = "chat";
      runtimeInputs = [pkgs.llama-cpp-rocm modelArgs];
      text = ''
        PROMPT="''${1:-}"
        mapfile -t model_args < <(model-args)
        exec llama-cli \
          "''${model_args[@]}" \
          ''${PROMPT:+--prompt "$PROMPT"}
      '';
    })
  ];
}
