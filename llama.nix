{
  pkgs,
  modelsIni ? ./llama/models.ini,
}: let
  promptsDir = "./text/prompts";
  benchDir = "./text/bench";
in {
  commands = [
    pkgs.llama-cpp-rocm

    (pkgs.writeShellApplication {
      name = "rocm-server";
      runtimeInputs = [pkgs.llama-cpp-rocm];
      text = ''
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
      runtimeInputs = [pkgs.llama-cpp-rocm];
      text = ''
        PROMPT_NAME="''${1:?}"
        PROMPT_FILE="${promptsDir}/$PROMPT_NAME.md"
        out="${benchDir}/''${MODEL}-''${PROMPT_NAME}.md"

        mkdir -p "${benchDir}"

        llama-completion \
          --models-preset ${modelsIni} \
          --model "''${MODEL:?}" \
          --perf \
          --single-turn --no-display-prompt --no-conversation \
          --prompt "$(cat "$PROMPT_FILE")" > "$out"

        echo "Wrote $out"
      '';
    })

    (pkgs.writeShellApplication {
      name = "oneshot";
      runtimeInputs = [pkgs.llama-cpp-rocm];
      text = ''
        PROMPT="''${1:?}"
        llama-completion \
          --models-preset ${modelsIni} \
          --model "''${MODEL:?}" \
          --log-verbosity 0 \
          --single-turn --no-display-prompt --no-conversation \
          --prompt "$PROMPT"
      '';
    })

    (pkgs.writeShellApplication {
      name = "chat";
      runtimeInputs = [pkgs.llama-cpp-rocm];
      text = ''
        PROMPT="''${1:-}"
        exec llama-cli \
          --models-preset ${modelsIni} \
          --model "''${MODEL:?}" \
          ''${PROMPT:+--prompt "$PROMPT"}
      '';
    })
  ];
}
