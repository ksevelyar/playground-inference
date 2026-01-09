{
  description = "ComfyUI native (ROCm) with persistent state + dynamicprompts + Manager (NixOS-safe)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      ldPath = pkgs.lib.makeLibraryPath (with pkgs; [
        stdenv.cc.cc
        libgcc
        zlib
        zstd
        bzip2
        xz
        libffi
        openssl
      ]);

      app = pkgs.writeTextFile {
        name = "comfyui";
        executable = true;
        destination = "/bin/comfyui";
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          STATE_DIR="''${COMFYUI_STATE_DIR:-$PWD/.comfyui}"
          REPO_DIR="$STATE_DIR/ComfyUI"
          VENV_DIR="$STATE_DIR/venv"

          MODELS_DIR="$STATE_DIR/models"
          INPUT_DIR="$STATE_DIR/input"
          OUTPUT_DIR="$STATE_DIR/output"
          WORKFLOWS_DIR="$STATE_DIR/workflows"
          CUSTOM_NODES_DIR="$STATE_DIR/custom_nodes"
          USER_DIR="$STATE_DIR/user"
          HF_DIR="$STATE_DIR/cache/hf"
          TORCH_DIR="$STATE_DIR/cache/torch"

          HOST="''${COMFYUI_HOST:-127.0.0.1}"
          PORT="''${COMFYUI_PORT:-8188}"
          ARGS="''${COMFYUI_ARGS:-}"

          TORCH_INDEX_URL="''${TORCH_INDEX_URL:-https://download.pytorch.org/whl/nightly/rocm7.0}"

          export PYTORCH_HIP_ALLOC_CONF="''${PYTORCH_HIP_ALLOC_CONF:-garbage_collection_threshold:0.6,max_split_size_mb:128}"
          export HF_HOME="$HF_DIR"
          export TORCH_HOME="$TORCH_DIR"
          export LD_LIBRARY_PATH="${ldPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          export PATH="${pkgs.git}/bin:${pkgs.uv}/bin:$PATH"

          mkdir -p \
            "$MODELS_DIR" "$INPUT_DIR" "$OUTPUT_DIR" "$WORKFLOWS_DIR" \
            "$CUSTOM_NODES_DIR" "$USER_DIR/default" \
            "$HF_DIR" "$TORCH_DIR"

          if [ ! -d "$REPO_DIR/.git" ]; then
            rm -rf "$REPO_DIR"
            ${pkgs.git}/bin/git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git "$REPO_DIR"
          fi

          link_migrate() {
            local link="$1"
            local target="$2"
            mkdir -p "$target" "$(dirname "$link")"
            if [ -L "$link" ]; then
              return 0
            fi
            if [ -d "$link" ]; then
              cp -a "$link/." "$target/" 2>/dev/null || true
            fi
            rm -rf "$link"
            ln -s "$target" "$link"
          }

          link_migrate "$REPO_DIR/models" "$MODELS_DIR"
          link_migrate "$REPO_DIR/input" "$INPUT_DIR"
          link_migrate "$REPO_DIR/output" "$OUTPUT_DIR"
          link_migrate "$REPO_DIR/custom_nodes" "$CUSTOM_NODES_DIR"
          link_migrate "$REPO_DIR/user" "$USER_DIR"
          link_migrate "$REPO_DIR/user/default/workflows" "$WORKFLOWS_DIR"

          PY="${pkgs.python312}/bin/python3.12"
          [ -d "$VENV_DIR" ] || "$PY" -m venv "$VENV_DIR"
          # shellcheck disable=SC1090
          source "$VENV_DIR/bin/activate"

          python -m pip install -U pip wheel setuptools
          python -m pip install -U --pre torch torchvision torchaudio --index-url "$TORCH_INDEX_URL"
          python -m pip install -U -r "$REPO_DIR/requirements.txt"

          if [ ! -d "$CUSTOM_NODES_DIR/ComfyUI-Manager/.git" ]; then
            ${pkgs.git}/bin/git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git "$CUSTOM_NODES_DIR/ComfyUI-Manager"
          fi

          mkdir -p "$CUSTOM_NODES_DIR/ComfyUI-Manager"
          cat > "$CUSTOM_NODES_DIR/ComfyUI-Manager/config.ini" <<EOF
          [default]
          git_exe = ${pkgs.git}/bin/git
          use_uv = False
          EOF

          if [ ! -d "$CUSTOM_NODES_DIR/comfyui-dynamicprompts/.git" ]; then
            ${pkgs.git}/bin/git clone --depth=1 https://github.com/adieyal/comfyui-dynamicprompts "$CUSTOM_NODES_DIR/comfyui-dynamicprompts"
          fi

          DYN_MARKER="$STATE_DIR/.dynamicprompts.installed"
          if [ ! -f "$DYN_MARKER" ]; then
            if [ -f "$CUSTOM_NODES_DIR/comfyui-dynamicprompts/requirements.txt" ]; then
              python -m pip install -U -r "$CUSTOM_NODES_DIR/comfyui-dynamicprompts/requirements.txt"
            fi
            python "$CUSTOM_NODES_DIR/comfyui-dynamicprompts/install.py"
            mkdir -p "$CUSTOM_NODES_DIR/comfyui-dynamicprompts/wildcards"
            : > "$DYN_MARKER"
          fi

          python -m pip install -U gguf insightface

          cd "$REPO_DIR"
          exec python main.py --listen "$HOST" --port "$PORT" $ARGS
        '';
      };
    in
    {
      packages.${system}.default = app;
      apps.${system}.default = { type = "app"; program = "${app}/bin/comfyui"; };
    };
}
