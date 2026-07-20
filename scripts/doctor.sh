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

# Zoxide
if command -v zoxide &>/dev/null || [ -x /opt/homebrew/bin/zoxide ]; then
  ok "Zoxide installed"
else
  fail "Zoxide not found"
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

# Node.js supply chain (Layer 1 + 2)
echo ""
echo "==> Node supply chain security"

if grep -q 'XDG_CONFIG_HOME' "$HOME/.zshenv" 2>/dev/null; then
  ok "XDG_CONFIG_HOME set in ~/.zshenv"
else
  fail "XDG_CONFIG_HOME missing in ~/.zshenv (run: make stow)"
fi

for pm_config in .npmrc .bunfig.toml .yarnrc.yml .nvmrc; do
  check_symlink "$HOME/$pm_config"
done

if [ -L "$HOME/.config/pnpm/config.yaml" ] && readlink "$HOME/.config/pnpm/config.yaml" | grep -q ".dotfiles"; then
  ok "Symlink OK: $HOME/.config/pnpm/config.yaml"
elif [ -f "$HOME/.config/pnpm/config.yaml" ] && grep -q "minimumReleaseAge: 14400" "$HOME/.config/pnpm/config.yaml" 2>/dev/null; then
  ok "pnpm config present: $HOME/.config/pnpm/config.yaml"
else
  fail "pnpm config missing (run: make stow)"
fi

node_bin=""
npm_bin=""
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  command -v node &>/dev/null && node_bin=$(command -v node)
  command -v npm &>/dev/null && npm_bin=$(command -v npm)
fi

if [ -n "$node_bin" ]; then
  node_major=$("$node_bin" -p "process.versions.node.split('.')[0]" 2>/dev/null || echo 0)
  if [ "$node_major" -ge 22 ] 2>/dev/null; then
    ok "Node installed ($("$node_bin" --version), npm min-release-age requires >= 22)"
  else
    warn "Node $("$node_bin" --version) — upgrade to LTS >= 22 for npm min-release-age (run: nvm install)"
  fi
else
  warn "Node not found via nvm (run: make install or nvm install)"
fi

if [ -n "$npm_bin" ]; then
  min_age=$("$npm_bin" config get min-release-age 2>/dev/null | tr -d '[:space:]')
  if [ "$min_age" = "10" ]; then
    ok "npm min-release-age = 10 days"
  else
    fail "npm min-release-age is '$min_age' (expected 10; run: make stow)"
  fi
fi

pnpm_bin=""
if command -v pnpm &>/dev/null; then
  pnpm_bin=$(command -v pnpm)
elif [ -x /opt/homebrew/bin/pnpm ]; then
  pnpm_bin=/opt/homebrew/bin/pnpm
fi

if [ -n "$pnpm_bin" ]; then
  pnpm_age=$("$pnpm_bin" config get minimumReleaseAge 2>/dev/null | tr -d '[:space:]')
  if [ "$pnpm_age" = "14400" ]; then
    ok "pnpm minimumReleaseAge = 14400 minutes (10 days)"
  else
    fail "pnpm minimumReleaseAge is '$pnpm_age' (expected 14400; run: make stow)"
  fi
  pnpm_trust=$("$pnpm_bin" config get trustPolicy 2>/dev/null | tr -d '[:space:]')
  if [ "$pnpm_trust" = "no-downgrade" ]; then
    ok "pnpm trustPolicy = no-downgrade"
  else
    warn "pnpm trustPolicy is '$pnpm_trust' (expected no-downgrade)"
  fi
else
  warn "pnpm not found"
fi

if command -v corepack &>/dev/null; then
  ok "Corepack available (Yarn)"
else
  warn "Corepack not available — run: corepack enable"
fi

# Pi coding-agent config
echo ""
echo "==> Pi (~/.pi)"

check_symlink "$HOME/.pi/ascii.txt"
check_symlink "$HOME/.pi/eyes.txt"
check_symlink "$HOME/.pi/miku.txt"
check_symlink "$HOME/.pi/agent/AGENTS.md"
check_symlink "$HOME/.pi/agent/APPEND_SYSTEM.md"
check_symlink "$HOME/.pi/agent/keybindings.json"
check_symlink "$HOME/.pi/agent/settings.example.json"
# Stow may link whole dirs (themes/, agents/, extensions/*/) rather than each file.
check_symlink "$HOME/.pi/agent/themes"
check_symlink "$HOME/.pi/agent/agents"
check_symlink "$HOME/.pi/agent/extensions/plan-mode"
check_symlink "$HOME/.pi/agent/extensions/quiet-tool-chrome"
check_symlink "$HOME/.pi/agent/extensions/tokyonight-chrome.ts"

check_pi_local() {
  local path="$1"
  local label="${2:-$path}"
  if [ -L "$path" ] && readlink "$path" | grep -q ".dotfiles"; then
    fail "Should be local-only (not stowed): $label"
  elif [ -e "$path" ]; then
    ok "Local-only OK: $label"
  else
    warn "Missing local file (expected after first pi run): $label"
  fi
}

check_pi_local "$HOME/.pi/agent/auth.json" "auth.json (secrets)"
check_pi_local "$HOME/.pi/agent/settings.json" "settings.json"
check_pi_local "$HOME/.pi/agent/sessions" "sessions/"
check_pi_local "$HOME/.pi/agent/npm" "npm/"

if [ -e "$DOTFILES/.pi/agent/auth.json" ] || [ -e "$DOTFILES/.pi/agent/settings.json" ]; then
  fail "Secrets/local settings present under $DOTFILES/.pi/agent/ (remove before commit)"
else
  ok "No auth.json/settings.json in dotfiles .pi tree"
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
