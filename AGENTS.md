# AGENTS.md

Instructions for AI coding agents working in this repository.

## Purpose

Personal dotfiles repo for macOS (Apple Silicon). Not an application codebase — changes here affect the user's live shell, terminal, editor, and system preferences.

## Layout

```
.dotfiles/
├── .zshrc, .zshenv, .zprofile, .p10k.zsh   # Shell (stowed to ~/)
├── .config/
│   ├── git/config
│   ├── kitty/
│   ├── nvim/init.lua          # Single-file lazy.nvim config (~2500 lines)
│   ├── tmux/
│   └── yazi/
├── Brewfile                    # Homebrew packages (NOT stowed)
├── bootstrap.sh                # curl | bash entry point (NOT stowed)
├── rectangle.json              # Copied on install (NOT stowed)
└── scripts/
    ├── install.sh              # Main installer
    ├── setup-ssh.sh            # SSH key generation for GitHub
    ├── register-fonts.sh     # CoreText font registration (macOS 27)
    └── macos-defaults.sh       # defaults write preferences
```

## Deployment

- **GNU Stow** symlinks repo contents into `$HOME`.
- Run from repo root: `stow -d ~/.dotfiles -t ~ --restow .`
- Files matching `.stow-local-ignore` are excluded from stow (scripts, Brewfile, README, etc.).
- `rectangle.json` is copied (not symlinked) because Rectangle rejects symlinks.

## Conventions

- **Apple Silicon only** — Homebrew paths use `/opt/homebrew`, not `/usr/local`.
- **Theming** — Tokyo Night palette across kitty, tmux, nvim, and yazi. Keep colors consistent.
- **Fonts** — `MesloLGS NF` bundled in `Library/Fonts/` (stowed to `~/Library/Fonts/`). From powerlevel10k-media. Do not use the Homebrew `font-meslo-lg-nerd-font` cask — different font build with different metrics.
- **Tmux** — Auto-starts only when `TERM_PROGRAM=kitty` or `DOTFILES_TMUX=1`.
- **Yazi git plugin** — Vendored at `.config/yazi/plugins/git.yazi/`. Do not add `package.toml` (duplicates the vendored copy).
- **Git identity** — Stored in `.config/git/config` intentionally (public info).

## Do not

- Add Intel Mac `/usr/local` fallbacks unless explicitly requested.
- Symlink `rectangle.json` — always copy it in `install.sh`.
- Shadow `grep`/`find` with aliases in `.zshrc` — breaks scripts.
- Auto-attach tmux in all terminals — Kitty only by default.
- Commit secrets (.env, tokens, private keys). SSH private keys live in `~/.ssh/`, never in this repo.

## Safe change patterns

| Task | Where to edit |
|---|---|
| New CLI tool | `Brewfile` |
| Shell alias/function | `.zshrc` (interactive) or `.zshenv` (env vars) |
| PATH / editor | `.zshenv` |
| Homebrew env | `.zprofile` |
| Terminal appearance | `.config/kitty/kitty.conf` |
| Tmux behavior | `.config/tmux/tmux.conf` |
| Neovim plugins/LSP | `.config/nvim/init.lua` |
| macOS system prefs | `scripts/macos-defaults.sh` |
| New install step | `scripts/install.sh` (use `try` helper for non-fatal steps) |

## Install flow

```
bootstrap.sh → clone ~/.dotfiles → scripts/install.sh
  → brew bundle → nvm → stow → register-fonts → setup-ssh → rectangle copy → macos-defaults
```

## Testing changes

After editing stowed configs:

```bash
stow -d ~/.dotfiles -t ~ --restow .
source ~/.zshrc
tmux source ~/.config/tmux/tmux.conf   # if in tmux
```

Do not run `scripts/macos-defaults.sh` casually — it modifies system-wide preferences and may prompt for sudo.
