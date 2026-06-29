{
  pkgs,
  utils,
}: let
  modelsDir = "./graphics/models";
  outputDir = "./graphics/output";
  promptsDir = "./graphics/prompts";
  modelsJson = ./stable-diffusion/models.json;

  generateCmd = pkgs.writeShellApplication {
    name = "generate";
    runtimeInputs = [pkgs.stable-diffusion-cpp-rocm pkgs.jq pkgs.coreutils utils.ensureModels utils.jsonToArgs];
    text = ''
      PROMPT="''${1:?Usage: generate <prompt-string>}"

      model_json=$(jq -r --arg model_name "''${SD_MODEL:-}" '.[$model_name]' ${modelsJson})
      if [ "$model_json" = "null" ]; then
        echo "Error: model '$SD_MODEL' not found in stable-diffusion/models.json" >&2
        exit 1
      fi

      echo "$model_json" | ensure-models "${modelsDir}"

      LORA_NAME=$(echo "$model_json" | jq -r '.lora.name // ""')
      if [ -n "$LORA_NAME" ]; then
        LORA_WEIGHT=$(echo "$model_json" | jq -r '.lora.weight // "1"')
        PROMPT="''${PROMPT}<lora:''${LORA_NAME}:''${LORA_WEIGHT}>"
      fi

      mapfile -t model_args < <(echo "$model_json" | json-to-args)

      if [ -n "$LORA_NAME" ]; then
        model_args+=(--lora-model-dir "${modelsDir}")
      fi

      MODEL_DIR=$(echo "$SD_MODEL" | tr '[:upper:]' '[:lower:]')
      OUTDIR="${outputDir}/''${MODEL_DIR}"
      mkdir -p "$OUTDIR"
      TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
      if [ -n "''${PROMPT_NAME:-}" ]; then
        OUTPUT="$OUTDIR/$TIMESTAMP-$PROMPT_NAME.png"
      else
        OUTPUT="$OUTDIR/$TIMESTAMP.png"
      fi

      sd-cli \
        "''${model_args[@]}" \
        -p "$PROMPT" \
        --output "$OUTPUT"

      echo "Saved: $OUTPUT"
    '';
  };

  generateFromPromptCmd = pkgs.writeShellApplication {
    name = "generate-from-prompt";
    runtimeInputs = [generateCmd];
    text = ''
      NAME="''${1:?Usage: generate-from-prompt <prompt-name>}"
      PROMPT_FILE="${promptsDir}/''${NAME}.md"

      if [ ! -f "$PROMPT_FILE" ]; then
        echo "Error: prompt file not found: $PROMPT_FILE" >&2
        exit 1
      fi

      PROMPT_NAME="$NAME" generate "$(cat "$PROMPT_FILE")"
    '';
  };
in {
  commands = [
    generateCmd
    generateFromPromptCmd
  ];
}
