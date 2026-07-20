# AGENTS.md

Instructions for AI coding agents working in this repository.

## Purpose

Personal dotfiles repo for macOS (Apple Silicon). Not an application codebase — changes here affect the user's live shell, terminal, editor, and system preferences.

## Layout

```
.dotfiles/
├── Makefile, README.md         # NOT stowed
├── .zshrc, .zshenv, .zprofile, .p10k.zsh
├── .npmrc, .bunfig.toml, .yarnrc.yml, .nvmrc   # Node supply chain (Layer 1+2)
├── .config/
│   ├── git/config              # pull.rebase = true
│   ├── pnpm/config.yaml        # global pnpm supply chain settings
│   ├── kitty/
│   ├── ghostty/                # cmux terminal look (Tokyo Night + miku)
│   ├── cmux/                   # cmux.json app settings
│   ├── nvim/
│   │   ├── init.lua            # thin entry (requires config/*)
│   │   ├── lazy-lock.json
│   │   └── lua/
│   │       ├── config/         # options, colors, keymaps, autocmds, lazy
│   │       └── plugins/        # ui, navigation, git, treesitter, lsp, etc.
│   ├── tmux/
│   └── yazi/
├── .pi/                            # pi coding-agent config (allowlisted only)
│   ├── ascii.txt, eyes.txt, miku.txt
│   └── agent/
│       ├── AGENTS.md, APPEND_SYSTEM.md, keybindings.json
│       ├── settings.example.json   # template; live settings.json is local-only
│       ├── themes/, agents/, prompts/
│       └── extensions/             # local extension source + tool-display config
├── Brewfile
├── bootstrap.sh
├── rectangle.json
└── scripts/
    ├── install.sh
    ├── setup-ssh.sh
    ├── register-fonts.sh
    ├── macos-defaults.sh
    └── doctor.sh
```

## Deployment

- **GNU Stow** symlinks repo contents into `$HOME`.
- `make stow` or `stow -d ~/.dotfiles -t ~ --restow .`
- Files matching `.stow-local-ignore` are excluded (scripts, Brewfile, Makefile, README, etc.).
- `rectangle.json` is copied (not symlinked) because Rectangle rejects symlinks.

## Pi (`~/.pi`)

Stow allowlists config only. Runtime data and secrets stay as real files under `~/.pi` (never in git).

**Stowed (symlinked from `.dotfiles/.pi/`):**

| Path | Role |
| `~/.pi/{ascii,eyes,miku}.txt` | Art / banners |
| `~/.pi/agent/AGENTS.md`, `APPEND_SYSTEM.md` | Global agent rules |
| `~/.pi/agent/keybindings.json` | Keybindings |
| `~/.pi/agent/themes/` | Themes (tokyo-night) |
| `~/.pi/agent/agents/*.md` | Subagent prompts |
| `~/.pi/agent/extensions/` | Local extension source + `pi-tool-display/config.json` |
| `~/.pi/agent/settings.example.json` | Settings template |
| `~/.pi/agent/prompts/.gitkeep` | Prompts dir marker |

**Local-only (do not commit / do not stow):**

| Path | Why |
| `agent/auth.json` | API keys / provider secrets |
| `agent/settings.json` | Machine-local settings (copy from example) |
| `agent/trust.json`, `telemetry.json`, `models-store.json`, `cursor-sdk-context-windows.json` | Machine / session state |
| `agent/sessions/`, `agent/npm/`, `agent/cache/` | Conversations, installs, caches |
| `agent/pi-hermes-memory/`, `agent/projects-memory/`, `*.sqlite*` | Memory DBs / indexes |
| `agent/ayu/`, `agent/pi-crash.log` | Checkpoints / logs |

**Fresh machine:**

1. `make stow`
2. `cp ~/.pi/agent/settings.example.json ~/.pi/agent/settings.json` and expand `$HOME` paths to absolute paths
3. Re-auth providers so `auth.json` is recreated (never restore secrets from backup into git)
4. Launch pi so npm packages reinstall from the `packages` list

## Make targets

| Target          | Action                              |
| --------------- | ----------------------------------- |
| `make install`  | Full setup via `scripts/install.sh` |
| `make stow`     | Deploy symlinks only                |
| `make doctor`   | Run health checks                   |
| `make ssh`      | Generate/show GitHub SSH key        |
| `make defaults` | Apply macOS preferences             |
| `make fonts`    | Register MesloLGS NF with CoreText  |

## Neovim module map

| File                      | Contents                                    |
| ------------------------- | ------------------------------------------- |
| `lua/config/options.lua`  | vim.opt, leader keys                        |
| `lua/config/colors.lua`   | Tokyo Night ui_colors + highlight overrides |
| `lua/config/buffers.lua`  | close_buffer helpers                        |
| `lua/config/keymaps.lua`  | Non-plugin keymaps                          |
| `lua/config/autocmds.lua` | Autocommands                                |
| `lua/config/lazy.lua`     | lazy.nvim bootstrap                         |
| `lua/config/neovide.lua`  | Neovide-only settings                       |
| `lua/config/qol.lua`      | Post-plugin vim.opt tweaks                  |
| `lua/plugins/*.lua`       | Plugin specs by category                    |

After editing nvim config: `nvim --headless +"Lazy! sync" +qa`

## Conventions

- **Apple Silicon only** — Homebrew paths use `/opt/homebrew`.
- **Theming** — Tokyo Night; base bg `#101015` across kitty, yazi, nvim, ghostty/cmux (miku wallpaper in ghostty).
- **Fonts** — `MesloLGS NF` bundled in `Library/Fonts/` from powerlevel10k-media.
- **Tmux** — Auto-starts only in Kitty (`TERM_PROGRAM=kitty`) or `DOTFILES_TMUX=1`. cmux uses Ghostty env and does not auto-attach.
- **cmux** — Terminal look in `.config/ghostty/`; app settings in `.config/cmux/cmux.json`. Reload: `cmux reload-config`. CLI: `/Applications/cmux.app/Contents/Resources/bin` (on PATH via `.zshenv`).
- **Yazi** — 3-pane ratio `[1, 3, 4]`; built-in `size` linemode; git plugin vendored.
- **Git** — `pull.rebase = true` in stowed git config.
- **Node supply chain** — 10-day release cooldown on npm/pnpm/yarn/bun; pnpm blocks dep lifecycle scripts unless `allowBuilds` permits. See [Node supply chain security](#node-supply-chain-security-layer-12).

## Node supply chain security (Layer 1+2)

Global configs stowed to `$HOME`. Requires Node LTS >= 22 (npm `min-release-age` needs npm CLI >= 11.10.0).

| Tool | Setting             | 10-day value       | File                         |
| ---- | ------------------- | ------------------ | ---------------------------- |
| npm  | `min-release-age`   | `10` (days)        | `~/.npmrc`                   |
| pnpm | `minimumReleaseAge` | `14400` (minutes)  | `~/.config/pnpm/config.yaml` |
| Yarn | `npmMinimalAgeGate` | `10d`              | `~/.yarnrc.yml`              |
| Bun  | `minimumReleaseAge` | `864000` (seconds) | `~/.bunfig.toml`             |

pnpm also sets `strictDepBuilds`, `trustPolicy: no-downgrade`, `blockExoticSubdeps`, `ignoreScripts`. Bun uses built-in `trustedDependencies` allowlist for lifecycle scripts.

`XDG_CONFIG_HOME=$HOME/.config` in `.zshenv` so pnpm reads the stowed global config (not `~/Library/Preferences/pnpm`).

**Emergency bypass** (critical CVE patch younger than 10 days):

| Tool | Command                                            |
| ---- | -------------------------------------------------- |
| npm  | `npm install pkg --min-release-age=0`              |
| pnpm | `pnpm add pkg --config.minimumReleaseAge=0`        |
| yarn | Lower `npmMinimalAgeGate` in project `.yarnrc.yml` |
| bun  | `bun add pkg --minimum-release-age 0`              |

Layers 3–5 (Socket Firewall, npq wrappers, `scan-deps`) are not yet implemented.

## Do not

- Add Intel Mac `/usr/local` fallbacks unless explicitly requested.
- Symlink `rectangle.json`.
- Shadow `grep`/`find` with aliases in `.zshrc`.
- Auto-attach tmux outside Kitty by default.
- Commit secrets or SSH private keys.
- Commit or stow `~/.pi/agent/auth.json`, live `settings.json`, sessions, npm installs, or sqlite/memory DBs.
- Use a bare `AGENTS.md` entry in `.stow-local-ignore` (blocks `.pi/agent/AGENTS.md`); keep the path-anchored `^/AGENTS\.md$` form.

## Install flow

```
bootstrap.sh (HTTPS clone) → scripts/install.sh
  → brew bundle → nvm → stow → node LTS + corepack → register-fonts → setup-ssh → rectangle → macos-defaults
```

After SSH key is on GitHub, `setup-ssh.sh` offers switching origin to SSH.

## Testing

```bash
make doctor
make stow && source ~/.zshrc
```

Do not run `macos-defaults.sh` casually — modifies system preferences.
