{
  description = "ComfyUI";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      ldPath = pkgs.lib.makeLibraryPath (with pkgs; [
        stdenv.cc.cc
        zlib
        zstd
      ]);

      app = pkgs.writeTextFile {
        name = "comfyui";
        executable = true;
        destination = "/bin/comfyui";
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          ROOT="$PWD"
          REPO_DIR="$ROOT/repo"
          VENV_DIR="$ROOT/venv"

          TORCH_INDEX_URL="''${TORCH_INDEX_URL:-https://download.pytorch.org/whl/nightly/rocm7.0}"

          export LD_LIBRARY_PATH="${ldPath}"

          if [ ! -d "$REPO_DIR/.git" ]; then
            git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git "$REPO_DIR"
          fi

          if [ ! -d "$VENV_DIR" ]; then
            python3.12 -m venv "$VENV_DIR"
          fi

          "$VENV_DIR/bin/python" -m pip install -U pip wheel setuptools
          "$VENV_DIR/bin/python" -m pip install -U --pre torch torchvision torchaudio --index-url "$TORCH_INDEX_URL"
          "$VENV_DIR/bin/python" -m pip install -U -r "$REPO_DIR/requirements.txt"
          "$VENV_DIR/bin/python" -m pip install -U -r "$REPO_DIR/manager_requirements.txt"

          mkdir -p "$REPO_DIR/user/__manager"
          printf '%s\n' '[default]' 'use_uv = False' > "$REPO_DIR/user/__manager/config.ini"

          cd "$REPO_DIR"
          exec "$VENV_DIR/bin/python" main.py --enable-manager
        '';
      };
    in
    {
      packages.${system}.default = app;
      apps.${system}.default = { type = "app"; program = "${app}/bin/comfyui"; };
    };
}
