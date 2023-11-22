{
  description = "just telescope+just";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlays.default];
      };
    in {
      devShell = pkgs.devshell.mkShell {
        name = "telescope-just";
        packages = with pkgs; [
          fzf
          jq
          just
        ];
      };
    });
}
