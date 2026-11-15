{
  description = "Reproducible development environment managed via Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Google Antigravity CLI の Flake を入力に追加
    antigravity-cli.url = "github:xsen/antigravity-cli-nix";
  };

  outputs = { self, nixpkgs, flake-utils, antigravity-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true; # Antigravity CLI 等のプロプライエタリ対応
          };
        };
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

            # Google Antigravity CLI (agy)
            antigravity-cli.packages.${system}.default
          ];
        };
      }
    );
}
