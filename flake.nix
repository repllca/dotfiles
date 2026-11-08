{
  description = "Portable developer environment & global CLI packages";

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
            # エディタ・ツール
            neovim
            helix
            ripgrep
            fd
            fzf
            bat
            eza
            jq

            # シークレット管理
            sops
            age
          ];
        };
      });
}
