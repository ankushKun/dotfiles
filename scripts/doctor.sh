#!/bin/bash
# Health checks for dotfiles setup.

set -uo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
BREW="${BREW:-/opt/homebrew/bin/brew}"
NVIM="${NVIM:-/opt/homebrew/bin/nvim}"
errors=0
warnings=0

ok()   { printf "  \033[1;32m✔\033[0m  %s\n" "$*"; }
fail() { printf "  \033[1;31m✗\033[0m  %s\n" "$*"; ((errors++)); }
warn() { printf "  \033[1;33m!\033[0m  %s\n" "$*"; ((warnings++)); }

echo "==> Dotfiles doctor"

# Homebrew
if command -v brew &>/dev/null; then
  ok "Homebrew installed ($(brew --prefix))"
elif [ -x "$BREW" ]; then
  ok "Homebrew installed ($("$BREW" --prefix))"
else
  fail "Homebrew not found"
fi

# Stow symlinks
check_symlink() {
  local path="$1"
  if [ -L "$path" ] && readlink "$path" | grep -q ".dotfiles"; then
    ok "Symlink OK: $path"
  elif [ -L "$path" ]; then
    warn "Symlink exists but may not point to dotfiles: $path -> $(readlink "$path")"
  else
    fail "Not symlinked: $path (run: make stow)"
  fi
}

check_symlink "$HOME/.zshrc"
if [ -L "$HOME/.config/nvim" ] && readlink "$HOME/.config/nvim" | grep -q ".dotfiles"; then
  ok "Symlink OK: $HOME/.config/nvim"
elif [ -L "$HOME/.config/nvim/init.lua" ] && readlink "$HOME/.config/nvim/init.lua" | grep -q ".dotfiles"; then
  ok "Symlink OK: $HOME/.config/nvim/init.lua"
else
  fail "Not symlinked: $HOME/.config/nvim (run: make stow)"
fi

# Fonts
font_ok=0
for f in "$HOME/Library/Fonts"/MesloLGS\ NF*.ttf; do
  [ -f "$f" ] && font_ok=$((font_ok + 1))
done
if [ "$font_ok" -eq 4 ]; then
  ok "MesloLGS NF fonts installed ($font_ok/4)"
else
  fail "MesloLGS NF fonts missing ($font_ok/4 found)"
fi

# Kitty font
if [ -f "$HOME/.config/kitty/kitty.conf" ] && grep -q "MesloLGS NF" "$HOME/.config/kitty/kitty.conf" 2>/dev/null; then
  ok "Kitty configured for MesloLGS NF"
else
  fail "Kitty font not set to MesloLGS NF"
fi

# Zsh plugins
for plugin in powerlevel10k/powerlevel10k.zsh-theme zsh-autosuggestions/zsh-autosuggestions.zsh zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [ -f "/opt/homebrew/share/$plugin" ]; then
    ok "Zsh plugin: $(basename "$plugin")"
  else
    fail "Missing zsh plugin: /opt/homebrew/share/$plugin"
  fi
done

# Git SSH (warn-only)
if ssh -T git@github.com 2>&1 | grep -qi "successfully authenticated"; then
  ok "GitHub SSH authentication works"
else
  warn "GitHub SSH not verified (run: make ssh, then add key to GitHub)"
fi

# Dotfiles remote
if [ -d "$DOTFILES/.git" ]; then
  remote=$(git -C "$DOTFILES" remote get-url origin 2>/dev/null || true)
  if [[ "$remote" == git@github.com:* ]]; then
    ok "Dotfiles remote uses SSH: $remote"
  elif [ -n "$remote" ]; then
    warn "Dotfiles remote is HTTPS: $remote (run setup-ssh after adding key)"
  fi
fi

# Neovim + lazy
nvim_bin=""
if command -v nvim &>/dev/null; then
  nvim_bin=$(command -v nvim)
elif [ -x "$NVIM" ]; then
  nvim_bin="$NVIM"
fi
if [ -n "$nvim_bin" ]; then
  if "$nvim_bin" --headless -u "$HOME/.config/nvim/init.lua" +"lua assert(require('lazy'))" +qa 2>/dev/null; then
    ok "Neovim lazy.nvim loads"
  else
    fail "Neovim lazy.nvim failed to load"
  fi
else
  fail "Neovim not found"
fi

# Yazi
if command -v yazi &>/dev/null || [ -x /opt/homebrew/bin/yazi ]; then
  ok "Yazi installed"
else
  fail "Yazi not found"
fi
if [ -f "$HOME/.config/yazi/yazi.toml" ] && [ -f "$HOME/.config/yazi/theme.toml" ]; then
  ok "Yazi config present"
else
  fail "Yazi config missing (run: make stow)"
fi

# Git pull.rebase
if git config --global pull.rebase 2>/dev/null | grep -q true || \
   [ -f "$HOME/.config/git/config" ] && grep -q "rebase = true" "$HOME/.config/git/config" 2>/dev/null; then
  ok "git pull.rebase = true"
else
  warn "git pull.rebase not enabled"
fi

echo ""
if [ "$errors" -eq 0 ]; then
  printf "  \033[1;32mAll critical checks passed.\033[0m"
  [ "$warnings" -gt 0 ] && printf " (%d warning(s))" "$warnings"
  echo ""
  exit 0
else
  printf "  \033[1;31m%d error(s), %d warning(s).\033[0m\n" "$errors" "$warnings"
  exit 1
fi
