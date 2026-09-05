# AMD Radeon RX 9060 XT 16 GB (gfx1200)
# AMD Ryzen 7 7700 (8 cores)
# DDR5 32 GB RAM
{
  description = "llama.cpp + stable-diffusion.cpp";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    utils = import ./utils.nix { inherit pkgs; };
    llama = import ./llama.nix { inherit pkgs; };
    stable-diffusion = import ./stable-diffusion.nix { inherit pkgs utils; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = llama.commands ++ stable-diffusion.commands;

      MODEL = "Qwen3.8-27B-UD-Q3_K_XL";
      SD_MODEL = "Krea2-Turbo";
    };
  };
}
