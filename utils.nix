{ pkgs }:

let
  inherit (pkgs) jq wget coreutils;
in {
  jsonToArgs = pkgs.writeShellApplication {
    name = "json-to-args";
    runtimeInputs = [ jq ];
    text = ''
      jq -r '
        .arguments | to_entries | .[] |
        if .value == "true" then "--\(.key)"
        else "--\(.key)", .value
        end
      '
    '';
  };

  ensureModels = pkgs.writeShellApplication {
    name = "ensure-models";
    runtimeInputs = [ jq wget coreutils ];
    text = ''
      models_dir="''${1:?Usage: ensure-models <models-dir>}"
      jq -r '.urls[] // empty' | while read -r url; do
        file="$models_dir/$(basename "$url")"
        if [ ! -f "$file" ]; then
          mkdir -p "$models_dir"
          wget -c -O "$file" "$url"
        fi
      done
    '';
  };
}
