# AMD Radeon RX 9060 XT 16 GB (gfx1200)
# AMD Ryzen 7 7700 (8 cores)
# DDR5 32 GB RAM
{
  description = "llama.cpp + stable-diffusion.cpp";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    stableDiffusionCpp = pkgs.stable-diffusion-cpp-rocm.overrideAttrs (old: {
      version = "master-1705-8caa3f9";
      src = pkgs.fetchFromGitHub {
        owner = "leejet";
        repo = "stable-diffusion.cpp";
        rev = "8caa3f908ae6d4a4bef531e73b9a969f266a3d1f";
        hash = "sha256-voybvJQrG6/Puogf9vBr/3jzHBcl1MnIAsRQtswUw2U=";
        fetchSubmodules = true;
      };
    });

    utils = import ./utils.nix { inherit pkgs; };
    llama = import ./llama.nix { inherit pkgs utils; };
    stable-diffusion = import ./stable-diffusion.nix { inherit pkgs utils stableDiffusionCpp; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = llama.commands ++ stable-diffusion.commands;

      MODEL = "Qwen3.6-27B-Q3_K_M";
      SD_MODEL = "PixelArt-XL";
    };
  };
}
