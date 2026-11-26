DOTFILES := $(CURDIR)
STOW := stow -d $(DOTFILES) -t $(HOME) --restow .
# Real dirs, so stow links single files into them instead of the whole dir
AGENT_DIRS := $(HOME)/.claude $(HOME)/.grok $(HOME)/.config/opencode

.PHONY: help install stow agents agents-pull defaults ssh fonts doctor

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*## /  /'

install: ## Full setup (brew, stow, fonts, ssh, defaults)
	bash scripts/install.sh

stow: ## Deploy symlinks only
	mkdir -p $(AGENT_DIRS)
	$(STOW)

agents: ## Apply tracked Claude Code settings to ~/.claude/settings.json
	bash scripts/agents.sh apply

agents-pull: ## Copy live Claude Code settings back into the repo
	bash scripts/agents.sh pull

defaults: ## Apply macOS system preferences
	bash scripts/macos-defaults.sh

ssh: ## Generate/show GitHub SSH key
	bash scripts/setup-ssh.sh

fonts: ## Register MesloLGS NF with CoreText
	bash scripts/register-fonts.sh

doctor: ## Run health checks
	bash scripts/doctor.sh

.DEFAULT_GOAL := help
