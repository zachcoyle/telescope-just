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
        overlays = [devshell.overlays.default self.overlays.default];
      };
    in {
      packages.default = pkgs.vimPlugins.telescope_just;

      devShell = pkgs.devshell.mkShell {
        name = "telescope_just";
        packages = with pkgs; [
          jq
          just
        ];
      };
    })
    // {
      overlays.default = final: prev: {
        vimPlugins =
          prev.vimPlugins
          // {
            telescope_just = prev.vimUtils.buildVimPlugin {
              pname = "telescope_just";
              version = "0.0.1";
              src = ./.;
            };
          };
      };
    };
}
