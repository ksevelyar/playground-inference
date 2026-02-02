{
  description = "Ollama + Open WebUI";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    webui = pkgs.open-webui;

    ollamaCPU = pkgs.ollama;
    ollamaAMD = pkgs.ollama-rocm;
    ollamaNVIDIA = pkgs.ollama-cuda;

    mkWebui = name: ollamaPkg:
      pkgs.writeShellScriptBin name ''
        set -euo pipefail

        export OLLAMA_HOST="127.0.0.1:11434"
        export OLLAMA_MODELS="$PWD/ollama-models"
        export DATA_DIR="$PWD/open-webui-data"
        mkdir -p "$OLLAMA_MODELS" "$DATA_DIR"

        ${ollamaPkg}/bin/ollama serve &

        exec ${webui}/bin/open-webui serve --host 127.0.0.1 --port 8080
      '';

    webuiCPU = mkWebui "webui-cpu" ollamaCPU;
    webuiAMD = mkWebui "webui-amd" ollamaAMD;
    webuiCUDA = mkWebui "webui-nvidia" ollamaNVIDIA;
  in {
    apps.${system} = {
      webui-cpu = {
        type = "app";
        program = "${webuiCPU}/bin/webui-cpu";
      };
      webui-amd = {
        type = "app";
        program = "${webuiAMD}/bin/webui-amd";
      };
      webui-nvidia = {
        type = "app";
        program = "${webuiCUDA}/bin/webui-cuda";
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        ollamaCPU
        webui
      ];

      shellHook = ''
        export OLLAMA_HOST="127.0.0.1:11434"
        export OLLAMA_MODELS="$PWD/ollama-models"
        export DATA_DIR="$PWD/open-webui-data"
        mkdir -p "$OLLAMA_MODELS" "$DATA_DIR"

        echo "ollama pull qwen2.5:14b"
        echo "nix run .#webui-amd"
        echo "nix run .#webui-cpu"
        echo "nix run .#webui-nvidia"
      '';
    };
  };
}
