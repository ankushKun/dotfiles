# Environment for all zsh invocations (login and non-login).
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export HOMEBREW_NO_AUTO_UPDATE="1"
export HOMEBREW_NO_ENV_HINTS="1"
export XDG_CONFIG_HOME="$HOME/.config"
export PNPM_HOME="$HOME/.local/share/pnpm"
export NVM_DIR="$HOME/.nvm"

export PATH="/Applications/cmux.app/Contents/Resources/bin:$HOME/.opencode/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:/usr/local/sbin:$PNPM_HOME:$PATH"

# Cursor agent terminals call this after each command to capture shell state.
# Stub it to avoid "command not found" noise (harmless elsewhere).
dump_zsh_state() { :; }

# cmux sets this before shell init when replaying prior scrollback on relaunch.
# Stash a flag here — cmux unsets the path once it cats the file (after .zshenv).
if [[ -n ${CMUX_RESTORE_SCROLLBACK_FILE-} ]]; then
  export CMUX_DID_RESTORE_SCROLLBACK=1
fi
