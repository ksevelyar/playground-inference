{
  description = "Ollama + Open WebUI";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      ollama = pkgs.ollama;
      webui = pkgs.open-webui;

      app = pkgs.writeShellScriptBin "ollama-webui" ''
        set -euo pipefail

        export OLLAMA_HOST="127.0.0.1:11434"
        export OLLAMA_MODELS="$PWD/ollama-models"
        export DATA_DIR="$PWD/open-webui-data"

        mkdir -p "$OLLAMA_MODELS" "$DATA_DIR"

        ${ollama}/bin/ollama serve &

        exec ${webui}/bin/open-webui serve --host 127.0.0.1 --port 8080
      '';
    in
    {
      apps.${system}.default = {
        type = "app";
        program = "${app}/bin/ollama-webui";
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ ollama ];
        shellHook = ''
          export OLLAMA_HOST="127.0.0.1:11434"
          export OLLAMA_MODELS="$PWD/ollama-models"
          export OLLAMA_NUM_CTX=32768
          mkdir -p "$OLLAMA_MODELS"
        '';
      };
    };
}
