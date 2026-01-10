{
  description = "Ollama + Open WebUI";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          rocmSupport = true;
        };
      };

      ollama = pkgs.ollama-rocm;
      webui  = pkgs.open-webui;

      app = pkgs.writeShellScriptBin "ollama-webui" ''
        set -euo pipefail

        export OLLAMA_HOST="127.0.0.1:11434"
        export OLLAMA_MODELS="$PWD/ollama-models"
        export DATA_DIR="$PWD/open-webui-data"

        mkdir -p "$OLLAMA_MODELS" "$DATA_DIR"

        ${ollama}/bin/ollama serve &
        OLLAMA_PID="$!"
        trap 'kill "$OLLAMA_PID" >/dev/null 2>&1 || true' EXIT INT TERM

        for _ in $(seq 1 200); do
          ${ollama}/bin/ollama list >/dev/null 2>&1 && break
          sleep 0.25
        done

        ${ollama}/bin/ollama pull dolphin-mistral:latest

        exec ${webui}/bin/open-webui serve --host 127.0.0.1 --port 8080
      '';
    in
    {
      apps.${system}.default = { type = "app"; program = "${app}/bin/ollama-webui"; };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ ollama ];
        shellHook = ''
          export OLLAMA_HOST="127.0.0.1:11434"
          export OLLAMA_MODELS="$PWD/ollama-models"
          mkdir -p "$OLLAMA_MODELS"
        '';
      };
    };
}
