# show available recipes
default:
    just -l

build:
    nix build -L .

update INPUT:
    nix flake lock --update-input {{ INPUT }} --commit-lock-file
