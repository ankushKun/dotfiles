#!/bin/bash
# ============================================================================
# Dotfiles Bootstrap Installer
# ============================================================================
# This script installs prerequisites and deploys dotfiles via GNU Stow.
# It is intentionally failsafe — each step is attempted independently and
# errors are collected but do not halt execution.
# ============================================================================

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
errors=0

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------
info()  { printf "  \033[1;34m→\033[0m  %s\n" "$*"; }
ok()    { printf "  \033[1;32m✔\033[0m  %s\n" "$*"; }
fail()  { printf "  \033[1;31m✗\033[0m  \033[1;31mERROR:\033[0m %s\n" "$*" >&2; ((errors++)); }
skip()  { printf "  \033[1;33m–\033[0m  %s\n" "$*"; }
header(){ printf "\n\033[1;36m%s\033[0m\n" "━━━ $* ━━━"; }

# Run a command, capture its stderr on failure, and always continue.
try() {
  local desc="$1"; shift
  local tmp; tmp=$(mktemp)
  if "$@" 2>"$tmp"; then
    ok "$desc"
    rm -f "$tmp"
  else
    local rc=$?
    local err; err=$(<"$tmp"); rm -f "$tmp"
    fail "$desc (exit $rc)"
    [ -n "$err" ] && printf "      %s\n" "$err" >&2
  fi
}

# ------------------------------------------------------------------
header "Xcode Command Line Tools"
# ------------------------------------------------------------------
if xcode-select -p &>/dev/null; then
  ok "Xcode CLT already installed"
else
  info "Installing Xcode CLT (may prompt for sudo)..."
  xcode-select --install 2>/dev/null && ok "Xcode CLT installed" || skip "Xcode CLT deferred (run 'xcode-select --install' manually)"
fi

# ------------------------------------------------------------------
header "Homebrew"
# ------------------------------------------------------------------
if command -v brew &>/dev/null; then
  ok "Homebrew already installed at $(brew --prefix)"
else
  info "Installing Homebrew (may prompt for sudo)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && ok "Homebrew installed" || fail "Homebrew installation failed"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ------------------------------------------------------------------
header "Brew Bundle (packages, casks, fonts)"
# ------------------------------------------------------------------
if [ -f "$DOTFILES/Brewfile" ]; then
  info "Installing from Brewfile (this may take a while)..."
  if brew bundle --file="$DOTFILES/Brewfile"; then
    ok "Brew bundle completed"
  else
    fail "Brew bundle failed — check output above"
  fi
else
  skip "Brewfile not found at $DOTFILES/Brewfile"
fi

# ------------------------------------------------------------------
header "NVM (Node Version Manager)"
# ------------------------------------------------------------------
if [ -d "$HOME/.nvm" ]; then
  ok "NVM already installed at ~/.nvm"
else
  info "Installing NVM..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh)" && ok "NVM installed" || fail "NVM installation failed"
fi

# ------------------------------------------------------------------
header "Stow (dotfile deployment)"
# ------------------------------------------------------------------
if ! command -v stow &>/dev/null; then
  info "Installing stow via Homebrew..."
  brew install stow 2>/dev/null && ok "stow installed" || fail "Failed to install stow"
fi

if command -v stow &>/dev/null; then
  try "Stow dotfiles" stow -d "$DOTFILES" -t "$HOME" --restow .
else
  fail "stow not available — skip stow packages"
fi

# Remove broken font symlinks (e.g. after fonts were temporarily removed from the repo)
for legacy in "$HOME/Library/Fonts"/MesloLGS\ NF*.ttf; do
  if [ -L "$legacy" ] && [ ! -e "$legacy" ]; then
    rm "$legacy"
    ok "Removed broken font symlink: $(basename "$legacy")"
  fi
done

# ------------------------------------------------------------------
header "Font Registration"
# ------------------------------------------------------------------
if [ -f "$DOTFILES/scripts/register-fonts.sh" ]; then
  try "Register Meslo Nerd Font with CoreText" bash "$DOTFILES/scripts/register-fonts.sh"
else
  skip "register-fonts.sh not found"
fi

# ------------------------------------------------------------------
header "SSH Key (GitHub)"
# ------------------------------------------------------------------
if [ -f "$DOTFILES/scripts/setup-ssh.sh" ]; then
  bash "$DOTFILES/scripts/setup-ssh.sh"
else
  skip "setup-ssh.sh not found"
fi

# ------------------------------------------------------------------
header "Rectangle Config"
# ------------------------------------------------------------------
RECT_TARGET="$HOME/Library/Application Support/Rectangle/RectangleConfig.json"
if [ -f "$DOTFILES/rectangle.json" ]; then
  mkdir -p "$(dirname "$RECT_TARGET")"
  if cp "$DOTFILES/rectangle.json" "$RECT_TARGET"; then
    ok "Rectangle config copied (not symlinked — app requires a real file)"
  else
    fail "Failed to copy Rectangle config"
  fi
else
  skip "rectangle.json not found in dotfiles"
fi

# ------------------------------------------------------------------
header "macOS Defaults"
# ------------------------------------------------------------------
if [ -f "$DOTFILES/scripts/macos-defaults.sh" ]; then
  try "Apply macOS defaults" bash "$DOTFILES/scripts/macos-defaults.sh"
else
  skip "macos-defaults.sh not found"
fi

# ------------------------------------------------------------------
header "Summary"
# ------------------------------------------------------------------
if [ "$errors" -eq 0 ]; then
  printf "\n  \033[1;32mAll done! Dotfiles deployed successfully.\033[0m\n\n"
  echo "  Next steps:"
  echo "    • Add the SSH public key (printed above) to GitHub"
  echo "    • Restart your terminal or run: source ~/.zshrc"
  echo "    • Restart kitty to pick up font/shell changes"
  echo "    • Some macOS defaults may require logout/restart"
  echo "    • Run 'tmux source ~/.config/tmux/tmux.conf' in tmux"
  echo ""
else
  printf "\n  \033[1;33mCompleted with %d error(s). Check the messages above.\033[0m\n\n" "$errors" >&2
  exit 1
fi
