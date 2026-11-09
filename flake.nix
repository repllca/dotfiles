{
  description = "Reproducible development environment managed via Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.buildEnv {
          name = "global-packages";
          paths = with pkgs; [
            # Base tools
            neovim
            tmux
            sops
            age

            # Cloud & Infrastructure
            awscli2

            # Modern CLI tools
            starship
            eza
            bat
            ripgrep
            zoxide

            # Dev Environment & Automation
            devbox
            direnv
          ];
        };
      }
    );
}
