{
  pkgs,
  modelsIni ? ./llama/models.ini,
}: let
  inherit (pkgs) lib;
  modelsDir = "./text/models";
  promptsDir = "./text/prompts";
  benchDir = "./text/bench";

  urls = {
    "Qwen3.8-27B-UD-IQ3_S" = "https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/main/Qwen3.8-27B-UD-IQ3_S.gguf";
    "Qwen3.6-27B-Q3_K_M-mtp" = "https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-Q3_K_M.gguf";
    "Qwen3.6-27B-Q3_K_M" = "https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-Q3_K_M.gguf";
  };

  downloadModel = pkgs.writeShellApplication {
    name = "download-model";
    runtimeInputs = [pkgs.wget pkgs.coreutils];
    text = ''
      model_name="''${1:?Usage: download-model <model>}"
      models_dir="''${MODELS_DIR:-${modelsDir}}"
      mkdir -p "$models_dir"
      case "$model_name" in
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: url: ''
        "${name}")
          url="${url}"
          ;;
      '') urls)}
      *)
        echo "error: unknown model: $model_name" >&2
        exit 1
        ;;
      esac
      file="$models_dir/$(basename "$url")"
      if [ ! -f "$file" ]; then
        wget -c -O "$file" "$url"
      fi
    '';
  };

  modelArgs = pkgs.writeShellApplication {
    name = "model-args";
    runtimeInputs = [pkgs.gawk downloadModel];
    text = ''
      model_name="''${1:-''${MODEL:?Usage: model-args [profile]}}"
      download-model "$model_name"
      exec awk -v name="$model_name" '
        $0 == "[*]" || $0 == "[" name "]" { active = 1; next }
        /^\[/ { active = 0; next }
        active && /=/ {
          key = $1
          gsub(/[[:space:]]+$/, "", key)
          sub(/^[[:space:]]*[^=]*=[[:space:]]*/, "")
          args[key] = $0
        }
        END {
          if (!("model" in args)) {
            print "error: unknown model profile: " name > "/dev/stderr"
            exit 1
          }
          for (k in args) {
            if (k == "model" || k == "load-on-startup" || k == "stop-timeout" || k == "dedup-cache-models") continue
            v = args[k]
            if (v == "true") print "--" k
            else if (v == "false") continue
            else {
              print "--" k
              print v
            }
          }
          print "--model"
          print args["model"]
        }
      ' ${modelsIni}
    '';
  };
in {
  commands = [
    pkgs.llama-cpp-rocm
    modelArgs

    (pkgs.writeShellApplication {
      name = "rocm-server";
      runtimeInputs = [pkgs.llama-cpp-rocm downloadModel];
      text = ''
        MODEL="''${MODEL:-Qwen3.8-27B-UD-IQ3_S}"
        download-model "$MODEL"
        mkdir -p ./log
        exec llama-server \
          --models-preset ${modelsIni} \
          --models-max 1 \
          --host 0.0.0.0 \
          --parallel 1 \
          --log-file "./log/router.log"
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