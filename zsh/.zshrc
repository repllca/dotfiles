# --- Terminal Color Enforcement ---
# Devbox や direnv のサブシェル内でも 256 色/TrueColor を維持
if [ -z "$TERM" ] || [ "$TERM" = "dumb" ]; then
  export TERM="xterm-256color"
fi
export COLORTERM="truecolor"
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

# --- Keybindings (Vim-mode) ---
bindkey -v
export KEYTIMEOUT=1              # ESC キーの遅延を最小化 (10ms)

# --- Modern CLI Aliases ---
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons --git"
  alias ll="eza -la --icons --git"
  alias tree="eza --tree --icons"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
fi

alias v="nvim"
alias g="git"

# --- Zoxide (Smart cd) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

# --- Direnv (Auto Environment Loading) ---
if command -v direnv >/dev/null 2>&1; then
# eval "$(direnv hook zsh)"
fi

# --- Starship Prompt ---
if command -v starship >/dev/null 2>&1; then
# eval "$(starship init zsh)"
fi
