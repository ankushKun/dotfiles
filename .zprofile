# Login shell — Homebrew environment (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# ~/.local/bin on PATH (Claude Code, grok, oof)
export PATH="$HOME/.local/bin:$PATH"
