{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
          inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, final, ... }: {
        overlayAttrs = {
            moonbit = final.callPackage ./moonbit.nix {};
        };
        packages.default = final.moonbit;
      };
    };
}
