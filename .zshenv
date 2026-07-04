# Environment for all zsh invocations (login and non-login).
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export HOMEBREW_NO_AUTO_UPDATE="1"
export HOMEBREW_NO_ENV_HINTS="1"
export XDG_CONFIG_HOME="$HOME/.config"
export PNPM_HOME="$HOME/.local/share/pnpm"
export NVM_DIR="$HOME/.nvm"

export PATH="$HOME/.opencode/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:/usr/local/sbin:$PNPM_HOME:$PATH"

# Cursor agent terminals call this after each command to capture shell state.
# Stub it to avoid "command not found" noise (harmless elsewhere).
dump_zsh_state() { :; }
