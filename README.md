# dotfiles

WSL2 / Linux (ARM64 / x86_64) 環境向けの、**Nix Flakes** と **SOPS (age)** を活用した再現性・安全性の高い dotfiles です。

---

## 📌 特徴

- **Nix Flakes による一元管理**: CLI ツールや開発ランタイムを宣言的に管理。
- **SOPS + age によるシークレット管理**: Git 設定や AWS 認証情報などの機密ファイルを暗号化してリポジトリ内で安全に管理。
- **安全なインストーラスクリプト (`install.sh`)**: 既存ファイルが存在する場合は自動で `.bak` バックアップを作成し、競合を防止。
- **モダンな CLI 環境**: Neovim (LazyVim), tmux (`Ctrl-a`), zsh (Vi モード), Starship, eza, bat, zoxide などの快適な開発環境。
- **AI / 開発エージェント連携**: Google Antigravity CLI (`agy`) 設定や Devbox テンプレートを同梱。

---

## 📁 ディレクトリ構成

```text
dotfiles/
├── flake.nix              # Nix Flakes によるグローバルパッケージ定義
├── flake.lock
├── install.sh             # シンボリックリンク展開 & シークレット復号スクリプト
├── .sops.yaml             # SOPS 暗号化設定 (age 公開鍵)
├── aws/                   # AWS CLI 設定 (config, credentials.enc)
├── config/
│   └── antigravity/       # Antigravity CLI (agy) 設定 (config.yaml)
├── git/                   # Git 設定 (gitconfig.enc)
├── nvim/                  # Neovim (LazyVim) 設定
├── templates/
│   └── devbox-base/       # Devbox 開発環境テンプレート & エージェントガイドライン
├── tmux/                  # tmux 設定 (.tmux.conf)
└── zsh/                   # zsh 設定 (.zshrc)
```

---

## 🛠 前提要件

1. **Nix** (Flakes が有効化されていること)
2. **age 秘密鍵** (SOPS で暗号化された設定を復号するために必要)
   - 通常は `~/.config/sops/age/keys.txt` に配置するか、環境変数 `SOPS_AGE_KEY_FILE` または `SOPS_AGE_KEY` を設定してください。

---

## 🚀 セットアップ手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Nix パッケージの適用 (ツール類のインストール)

Flake で定義された CLI ツール群をグローバルプロファイルに適用します。

```bash
# Nix profile へのインストール
nix profile install .
```

> **含まれる主なツール**:
> `neovim`, `tmux`, `sops`, `age`, `awscli2`, `starship`, `eza`, `bat`, `ripgrep`, `zoxide`, `devbox`, `direnv`, `antigravity-cli`

### 3. age 鍵の配置 (シークレット復号用)

SOPS 復号用の鍵を配置します。

```bash
mkdir -p ~/.config/sops/age
# 既存の age 秘密鍵を keys.txt に配置
cp /path/to/your/key.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### 4. 設定のリンク & 復号配置

`install.sh` を実行して、シンボリックリンクの作成と暗号化ファイルの復号を行います。

```bash
./install.sh
```

このスクリプトは以下の処理を行います：
- `~/.tmux.conf` のシンボリックリンク作成
- `~/.config/nvim` のシンボリックリンク作成
- `git/gitconfig.enc` を復号して `~/.gitconfig` を生成
- `aws/config` のリンク作成 & `aws/credentials.enc` を復号して `~/.aws/credentials` (パーミッション 600) を生成
- `~/.zshrc` のシンボリックリンク作成
- `~/.config/antigravity/` への設定ファイルリンク作成
- `~/.config/starship.toml` のリンク作成 (ファイルが存在する場合)

---

## ⚙️ 各コンポーネントの詳細

### Neovim (LazyVim)
- **構成**: [LazyVim](https://www.lazyvim.org/) ベース
- **カスタマイズ**:
  - `jj` でインサートモードを抜けてノーマルモードへ移行
  - システムクリップボードとの連携

### tmux
- **プレフィックスキー**: デフォルトの `Ctrl-b` から `Ctrl-a` に変更
- `Ctrl-a` を 2 回押すことでシェルの行頭移動などの本来の `Ctrl-a` を送信

### Zsh
- **ヒストリ**: 端末間での即時履歴共有 (`SHARE_HISTORY`)、重複除外
- **キーバインド**: Vi モード (`bindkey -v`)
- **エイリアス**:
  - `ls` / `ll` / `tree` → `eza`
  - `cat` → `bat`
  - `v` → `nvim`
  - `g` → `git`
  - `cd` → `zoxide` (z)

### SOPS 暗号化ファイル
機密情報は `sops` コマンドで編集・暗号化します。

```bash
# Git 設定の編集
sops git/gitconfig.enc

# AWS 認証情報の編集
sops aws/credentials.enc
```

---

## 📝 ライセンス

各ディレクトリおよび設定ファイルのライセンスに従います。
- Neovim 設定: [Apache License 2.0](nvim/LICENSE)
