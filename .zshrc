# Auto-start tmux in Kitty only. Set DOTFILES_TMUX=1 to enable elsewhere.
# Must run before p10k instant prompt or the kitty window closes on attach.
# Kitty does not set TERM_PROGRAM by default; KITTY_WINDOW_ID is always present.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]] && command -v tmux &>/dev/null; then
  if [[ "$TERM_PROGRAM" == "kitty" || -n "$KITTY_WINDOW_ID" || "$DOTFILES_TMUX" == 1 ]]; then
    exec tmux new-session -A -s main
  fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load p10k theme (Homebrew, Apple Silicon)
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# Load p10k config after theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Suppress p10k instant prompt warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Completion (matcher-list before compinit — paths with /; bare names use __dirs_ci_comp)
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

autoload -U compinit && compinit -C

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt autocd

# Case-insensitive fallback when autocd misses (e.g. `documents` → `Documents`)
__cd_insensitive() {
  emulate -L zsh
  local target="$1" current part dir segment
  local -a parts

  [[ -z "$target" ]] && return 1

  if [[ "$target" == "~" ]]; then
    cd ~ && return 0
  elif [[ "$target" == "~/"* ]]; then
    current="$HOME"
    target="${target#~/}"
  elif [[ "$target" == "/" ]]; then
    cd / && return 0
  elif [[ "$target" == /* ]]; then
    current="/"
    target="${target#/}"
  else
    current="$PWD"
  fi

  parts=(${(s:/:)target})
  for part in "${parts[@]}"; do
    [[ -z "$part" ]] && continue
    if [[ "$part" == ".." ]]; then
      current="${current:h}"
      [[ -d "$current" ]] || return 1
      continue
    fi
    [[ "$part" == "." ]] && continue

    segment=""
    for dir in "$current"/*(N); do
      [[ -d "$dir" && ${(L)dir:t} == ${(L)part} ]] || continue
      segment="$dir"
      break
    done
    [[ -z "$segment" ]] && return 1
    current="$segment"
  done

  cd "$current"
}

command_not_found_handler() {
  __cd_insensitive "$1" && return 0
  print -u2 "zsh: command not found: $1"
  return 127
}

# Zsh plugins (Homebrew)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Smart cd (cdi for interactive fzf picker)
if command -v zoxide &>/dev/null; then
  export _ZO_FZF_OPTS='--ignore-case'
  eval "$(zoxide init zsh --cmd cd)"
fi

# Case-insensitive directory tab completion when default matching is case-sensitive
# (autocd uses _command_names, not matcher-list, for bare names like `dev` → `Developer/`)
__dirs_ci_comp() {
  emulate -L zsh
  setopt localoptions extendedglob nullglob
  [[ "$PREFIX" == */* ]] && return 1

  local -a matches d
  local needle="${(L)PREFIX}"

  for d in *(N/); do
    [[ ${d%/} == ${PREFIX}* ]] && return 1
  done

  for d in *(N/); do
    [[ ${(L)${d%/}} == ${needle}* ]] && matches+=(${d%/}/)
  done

  (( ${#matches} )) && { compadd -Q -a matches; return 0 }
  return 1
}

autoload -Uz +X _autocd
functions[_autocd_orig]=$functions[_autocd]
function _autocd() {
  local ret=1
  (( CURRENT == 1 )) && __dirs_ci_comp && ret=0
  _autocd_orig "$@" && ret=0
  return ret
}

if (( $+functions[__zoxide_z_complete] )); then
  eval "function __zoxide_z_complete_orig() {
  ${functions[__zoxide_z_complete]}
  }"
  function __zoxide_z_complete() {
    local ret=1
    [[ "${#words[@]}" -eq 2 ]] && __dirs_ci_comp && ret=0
    __zoxide_z_complete_orig "$@" && ret=0
    return ret
  }
fi

# Performance tweaks
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Emacs line editing — kitty Option+arrow sends Meta+b/f (see kitty.conf).
# zsh defaults to vi mode when EDITOR/VISUAL contain "vi" (nvim).
bindkey -e
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
(( ${+ZSH_AUTOSUGGEST_MANUAL_REBIND} )) && _zsh_autosuggest_bind_widgets

# Aliases
alias ls='eza --icons=always'
alias la='ls -a'
alias ll='ls -l'
alias lal='ls -al'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias lg='lazygit'
alias files='yazi'
alias zshconfig='nvim ~/.zshrc'
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'

# Utility functions
portkill() {
  local pid=$(lsof -ti :"$1")
  if [ -n "$pid" ]; then
    echo "$pid" | xargs kill -9
    echo "Killed process(es) on port $1: $pid"
  else
    echo "No process found on port $1"
  fi
}

# Lazy-load NVM (only load when needed to speed up shell startup)
nvm() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}
npm() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/weeblet/.cli/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/weeblet/.cli/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/weeblet/.cli/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/weeblet/.cli/google-cloud-sdk/completion.zsh.inc'; fi
