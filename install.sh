#!/bin/bash
set -e

NVIM_PATH=$(command -v nvim)

. /etc/os-release
echo "Ubuntu バージョン: $VERSION_ID"

if [ -n "$NVIM_PATH" ]; then
  echo "✅ nvim はここにあります: $NVIM_PATH"
else
  echo "⚠️ nvim がインストールされていません。"
  read -p "neovim をインストールしますか？ [y/n] " ANSWER

  case "$ANSWER" in
  [yY])
    echo "Neovim をインストールします..."

    # 数値比較は `-ge` を使う
    if (($(echo "$VERSION_ID >= 22.04" | bc -l))); then
      echo "Ubuntu $VERSION_ID のため、PPA からインストールを行います..."
      sudo add-apt-repository ppa:neovim-ppa/unstable -y
      sudo apt update
      sudo apt install neovim -y
    else
      echo "Ubuntu $VERSION_ID のため、AppImage によるインストールを行います..."
      cd /tmp
      wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
      chmod u+x nvim.appimage
      sudo mv nvim.appimage /usr/local/bin/nvim
    fi
    ;;
  [nN])
    echo "インストールをキャンセルしました。"
    ;;
  *)
    echo "不正な入力です。y または n を入力してください。"
    ;;
  esac
fi
