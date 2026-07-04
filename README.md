# Weeblet's dotfiles

Personal macOS dotfiles for Apple Silicon Macs. Configs are deployed with [GNU Stow](https://www.gnu.org/software/stow/) and packages are installed via Homebrew.

## What's included

| Area | Location | Notes |
|---|---|---|
| Shell | `.zshrc`, `.zshenv`, `.zprofile`, `.p10k.zsh` | zsh + Powerlevel10k |
| Terminal | `.config/kitty/` | Tokyo Night theme, tmux key forwarding |
| Tmux | `.config/tmux/` | Auto-starts in Kitty only |
| Neovim | `.config/nvim/` | lazy.nvim, Mason LSP |
| Yazi | `.config/yazi/` | File manager with git plugin |
| Git | `.config/git/config` | Global git identity |
| Window manager | `rectangle.json` | Copied on install (not symlinked) |
| Packages | `Brewfile` | Formulae + casks |
| macOS prefs | `scripts/macos-defaults.sh` | Dock, Finder, trackpad, dark mode |

Fonts (MesloLGS NF) are bundled in `Library/Fonts/` and stowed to `~/Library/Fonts/`. Sourced from [powerlevel10k-media](https://github.com/romkatv/powerlevel10k-media) — the recommended font for Powerlevel10k.

## Fresh install

```bash
curl -fsSL https://raw.githubusercontent.com/ankushKun/dotfiles/main/bootstrap.sh | bash
```

This will:

1. Install Xcode Command Line Tools
2. Install Homebrew
3. Clone this repo to `~/.dotfiles`
4. Run `scripts/install.sh`

## Manual install / update

If the repo is already cloned:

```bash
cd ~/.dotfiles
git pull
bash scripts/install.sh
```

## SSH key for GitHub

`install.sh` runs `scripts/setup-ssh.sh`, which:

* Creates `~/.ssh/id_ed25519` if it doesn't exist
* Adds the key to `ssh-agent`
* Prints the public key to add at [github.com/settings/ssh/new](https://github.com/settings/ssh/new)

You can also run it standalone:

```bash
bash ~/.dotfiles/scripts/setup-ssh.sh
```

Then test:

```bash
ssh -T git@github.com
```

## What gets symlinked

Stow deploys these into `$HOME`:

```
~/.zshrc
~/.zshenv
~/.zprofile
~/.p10k.zsh
~/.config/{git,kitty,nvim,tmux,yazi}/
```

These stay in the repo only (not symlinked):

```
Brewfile, bootstrap.sh, scripts/, rectangle.json, README.md, AGENTS.md
```

Rectangle config is **copied** to `~/Library/Application Support/Rectangle/RectangleConfig.json` because the app requires a real file.

## Tmux auto-start

Tmux starts automatically only inside **Kitty**. To enable it in other terminals:

```bash
export DOTFILES_TMUX=1
```

## Individual scripts

| Script | Purpose |
|---|---|
| `scripts/install.sh` | Full setup: brew, stow, fonts, SSH, Rectangle, defaults |
| `scripts/setup-ssh.sh` | Generate SSH key and print public key for GitHub |
| `scripts/register-fonts.sh` | Register Meslo font with CoreText (macOS 27 workaround) |
| `scripts/macos-defaults.sh` | Apply macOS system preferences |

## Requirements

* macOS on Apple Silicon (`/opt/homebrew`)
* Xcode Command Line Tools
* Internet access for Homebrew and package downloads
