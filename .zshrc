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

# Completion
autoload -U compinit && compinit -C

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Zsh plugins (Homebrew)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Performance tweaks
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Emacs line editing — kitty Option+arrow sends Meta+b/f (see kitty.conf).
# zsh defaults to vi mode when EDITOR/VISUAL contain "vi" (nvim).
bindkey -e
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
