# Login shell — Homebrew environment (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
