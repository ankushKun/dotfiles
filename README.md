# Weeblet's dotfiles

Personal macOS dotfiles for Apple Silicon. Deployed with [GNU Stow](https://www.gnu.org/software/stow/).

## Fresh install

```bash
curl -fsSL https://raw.githubusercontent.com/ankushKun/dotfiles/main/bootstrap.sh | bash
```

## Update

```bash
cd ~/.dotfiles && git pull && make install
```

## Common commands

```bash
make install   # full setup
make stow      # symlinks only
make doctor    # health check
make ssh       # GitHub SSH key
make defaults  # macOS preferences
```

Run `make help` for all targets.

## SSH

Install prints your public key for [GitHub SSH settings](https://github.com/settings/ssh/new). After adding it, setup offers switching the dotfiles remote to `git@github.com:ankushKun/dotfiles.git`.

## More detail

See [AGENTS.md](AGENTS.md) for repo layout, conventions, and Neovim module structure.
