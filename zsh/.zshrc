# --- Terminal Color Enforcement ---
# Devbox や direnv のサブシェル内でも 256 色/TrueColor を維持
if [ -z "$TERM" ] || [ "$TERM" = "dumb" ]; then
  export TERM="xterm-256color"
fi
export COLORTERM="truecolor"

# 非対話シェル（agy のサブシェルやスクリプト実行）はここで終了し、起動を最速化
[[ $- != *i* ]] && return

# ==============================================================================
# Zsh Configuration
# ==============================================================================

# --- History Configuration ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # タイムスタンプを記録
setopt HIST_EXPIRE_DUPS_FIRST    # 履歴上限時に重複行から削除
setopt HIST_IGNORE_DUPS          # 直前と同じコマンドは記録しない
setopt HIST_IGNORE_ALL_DUPS      # 重複するコマンドをすべて削除
setopt HIST_FIND_NO_DUPS         # 検索時に重複を表示しない
setopt HIST_IGNORE_SPACE         # 先頭スペースのコマンドは履歴に残さない
setopt HIST_SAVE_NO_DUPS         # ファイル保存時に重複を排除
setopt SHARE_HISTORY             # 別端末間で履歴を即時共有

# --- Directory Navigation ---
setopt AUTO_CD                   # ディレクトリ名を入力するだけで cd
setopt AUTO_PUSHD                # cd 時にディレクトリスタックへ自動保存
setopt PUSHD_IGNORE_DUPS         # スタック内の重複を無視
setopt INTERACTIVE_COMMENTS      # コマンドラインでの # コメントを許可

# --- Fast Completion System ---
autoload -Uz compinit
# 24時間に1回だけ .zcompdump を再生成して起動を高速化
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 小文字入力で大文字も補完
zstyle ':completion:*' menu select                  # 補完候補をメニュー選択
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- Keybindings (Vim-mode + Usability Fixes) ---
bindkey -v
export KEYTIMEOUT=1              # ESC キーの遅延を最小化 (10ms)

# Vim モードで殺されがちな便利な Emacs 系バインドを復元
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' backward-kill-word

# 補完メニュー内で Vim の hjkl 移動を許可
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Insert モード(縦棒) と Normal モード(ブロック) でカーソル形状を切り替え
function zle-keymap-select {
  case $KEYMAP in
    vicmd)      echo -ne '\e[2 q' ;; # ブロック
    viins|main) echo -ne '\e[6 q' ;; # 縦棒
  esac
}
zle -N zle-keymap-select
precmd_functions+=(zle-keymap-select)

# --- Modern CLI Aliases & Wrappers ---
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons --git"
  alias ll="eza -la --icons --git --time-style=long-iso"
  alias tree="eza --tree --icons -L 2"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
fi

alias v="nvim"
alias g="git"
alias lg="lazygit"

# Yazi ラッパー (終了時に移動先ディレクトリへ自動 cd)
if command -v yazi >/dev/null 2>&1; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# --- Antigravity CLI (agy) & Devbox Helpers ---
if command -v agy >/dev/null 2>&1; then
  # /mnt 配下での誤起動（WSL2ハング要因）を事前にブロック
  function agy() {
    if [[ "$PWD" == /mnt/* ]]; then
      echo "⚠️  Blocked: /mnt 配下での agy 実行は WSL2 I/O ハング防止のため禁止されています。"
      return 1
    fi
    command agy "$@"
  }

  # カレントディレクトリに templates/devbox-base の AGY.md と devbox.json を展開
  function agy-init() {
    local base_dir="$HOME/dotfiles/templates/devbox-base"
    if [ ! -d "$base_dir" ]; then
      echo "Error: $base_dir が見つかりません。"
      return 1
    fi

    for file in AGY.md devbox.json; do
      if [ -f "$file" ]; then
        echo "Skip: $file は既に存在します。"
      elif [ -f "$base_dir/$file" ]; then
        cp "$base_dir/$file" "./$file"
        echo "Created: ./$file"
      fi
    done
  }
fi

if command -v devbox >/dev/null 2>&1; then
  alias db="devbox"
  alias dbr="devbox run --"
  alias dba="devbox add"
  alias dbs="devbox shell"
fi

# --- Zoxide (Smart cd) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# --- Direnv (Auto Environment Loading) ---
if command -v direnv >/dev/null 2>&1; then
  export DIRENV_LOG_FORMAT=""    # 環境切り替え時の冗長な出力を抑制
  eval "$(direnv hook zsh)"
fi

# --- Minimal Prompt (Pure Zsh, Fast & Clean) ---
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=(precmd_vcs_info)
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt PROMPT_SUBST

# カレントディレクトリ + Git ブランチ + 終了コードに応じたプロンプト記号色
PROMPT='%F{cyan}%~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})❯%f '
