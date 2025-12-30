#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔧 Installing dotfiles from $DOTFILES_DIR"

# zsh
ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile"
ln -sf "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv"

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📦 Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "✅ Done"
