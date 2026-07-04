#!/bin/bash
# ============================================================================
# Remote Bootstrap — curl | bash
#   curl -fsSL https://raw.githubusercontent.com/ankushKun/dotfiles/main/bootstrap.sh | bash
#
# Clones dotfiles to ~/.dotfiles, installs prerequisites, and deploys configs.
# Idempotent — safe to re-run on an existing setup.
# ============================================================================

REPO="https://github.com/ankushKun/dotfiles.git"
TARGET="$HOME/.dotfiles"

info()  { printf "  \033[1;34m→\033[0m  %s\n" "$*"; }
ok()    { printf "  \033[1;32m✔\033[0m  %s\n" "$*"; }
fail()  { printf "  \033[1;31m✗\033[0m  %s\n" "$*" >&2; }

# ---- Xcode CLT ----
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode CLT..."
  xcode-select --install 2>/dev/null || true
  echo "  ⏳ Waiting for Xcode CLT installation to complete..."
  until xcode-select -p &>/dev/null; do sleep 5; done
  ok "Xcode CLT installed"
else
  ok "Xcode CLT already installed"
fi

# ---- Homebrew ----
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

# ---- Git (needed for clone) ----
if ! command -v git &>/dev/null; then
  info "Installing git..."
  brew install git 2>/dev/null && ok "git installed" || fail "git install failed"
fi

# ---- Clone / Pull repo ----
if [ -d "$TARGET" ]; then
  info "Updating existing dotfiles repo..."
  cd "$TARGET" && git pull --ff-only 2>/dev/null && ok "dotfiles updated" || fail "git pull failed"
else
  info "Cloning dotfiles to $TARGET..."
  git clone "$REPO" "$TARGET" 2>/dev/null && ok "dotfiles cloned" || fail "clone failed"
fi

# ---- Delegate to install.sh ----
if [ -f "$TARGET/scripts/install.sh" ]; then
  echo ""
  bash "$TARGET/scripts/install.sh"
else
  fail "install.sh not found in $TARGET"
  exit 1
fi
