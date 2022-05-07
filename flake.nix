{
  description = "SnO2WMaN's Articles for Zenn";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    devshell = {
      url = "github:numtide/devshell";
    };
  };
  outputs = { self, nixpkgs, devshell, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system: {
        devShell =
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ devshell.overlay ];
            };
          in
          pkgs.devshell.mkShell {
            imports = [
              (pkgs.devshell.importTOML ./devshell.toml)
            ];
          };
      }
    );
}
