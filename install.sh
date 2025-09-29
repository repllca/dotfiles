#!/bin/bash
set -e
NVIM_PATH=$(command -v nvim)

. /etc/os-release
echo $VERSION_ID

if [ -n "$NVIM_PATH" ]; then
  echo "nvim はここにあります: $NVIM_PATH"
else
  #neovimがインストールされていない場合
  echo "nvimがインストールされていません"
  read -p "neovimをインストールしますか？[y/n]" ANSWER
  case "$ANSWER" in
  y | Y)
    echo "Neovimをインストールします！"
   #neovimがインストール 
      if $VERSION_ID>= 22.04; then
        #PPAでのインストール（20.04よりうえのバージョン）
        echo "Ubuntu $VERSION_ID のためPPAによるインストールを行います...."

      else
        #AppImageでのインストール(20.04以下のバージョン)
        
        echo "Ubuntu $VERSION_ID のためAppImageによるインストールを行います...."
    ;;
  y | Y)
    echo "nvimがインストールされていません"
    ;;
  esac
fi
