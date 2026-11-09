#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting dotfiles setup..."

# 必要なディレクトリの事前作成
mkdir -p "$HOME/.config"

# --------------------------------------------------
# ヘルパー関数: 安全なシンボリックリンク作成
# --------------------------------------------------
link_file() {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Backing up existing $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -sfn "$src" "$dst"
  echo "Linked: $dst -> $src"
}

# --------------------------------------------------
# 1. tmux 設定の展開 (シンボリックリンク)
# --------------------------------------------------
if [ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]; then
  echo "==> Configuring tmux..."
  link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
else
  echo "Notice: $DOTFILES_DIR/tmux/.tmux.conf not found. Skipping."
fi

# --------------------------------------------------
# 2. LazyVim 設定の展開 (シンボリックリンク)
# --------------------------------------------------
if [ -d "$DOTFILES_DIR/nvim" ]; then
  echo "==> Configuring LazyVim..."
  link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
else
  echo "Notice: $DOTFILES_DIR/nvim directory not found. Skipping."
fi

# --------------------------------------------------
# 3. Git 設定の復号・配置 (SOPS)
# --------------------------------------------------
if [ -f "$DOTFILES_DIR/git/gitconfig.enc" ]; then
  echo "==> Decrypting Git configuration via SOPS..."
  if command -v sops >/dev/null 2>&1; then
    sops -d --input-type ini --output-type ini "$DOTFILES_DIR/git/gitconfig.enc" > "$HOME/.gitconfig"
    echo "Generated: $HOME/.gitconfig"
  else
    echo "Warning: 'sops' command not found. Skipping Git decryption."
  fi
else
  echo "Notice: $DOTFILES_DIR/git/gitconfig.enc not found. Skipping."
fi

echo "==> Dotfiles setup completed successfully!"
