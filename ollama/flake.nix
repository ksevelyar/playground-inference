{
  description = "Ollama + Open WebUI (cpu/gpu switch)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          rocmSupport = true;
          allowUnfree = true;
        };
      };

      webui = pkgs.open-webui;

      mkWebui = name: ollamaPkg:
        pkgs.writeShellScriptBin name ''
          set -euo pipefail

          export OLLAMA_HOST="127.0.0.1:11434"
          export OLLAMA_MODELS="$PWD/ollama-models"
          export DATA_DIR="$PWD/open-webui-data"

          mkdir -p "$OLLAMA_MODELS" "$DATA_DIR"

          ${ollamaPkg}/bin/ollama serve &
          ollama_pid=$!
          trap 'kill $ollama_pid 2>/dev/null || true' EXIT

          exec ${webui}/bin/open-webui serve --host 127.0.0.1 --port 8080
        '';

      webuiCpu = mkWebui "webui-cpu" (pkgs.ollama);
      webuiGpu = mkWebui "webui-gpu" (pkgs.ollama-rocm);
    in
    {
      apps.${system} = {
        webui-cpu = { type = "app"; program = "${webuiCpu}/bin/webui-cpu"; };
        webui-gpu = { type = "app"; program = "${webuiGpu}/bin/webui-gpu"; };

        # optional default:
        default = { type = "app"; program = "${webuiGpu}/bin/webui-gpu"; };
      };
    };
}
