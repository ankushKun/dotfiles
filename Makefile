DOTFILES := $(CURDIR)
STOW := stow -d $(DOTFILES) -t $(HOME) --restow .

.PHONY: help install stow defaults ssh fonts doctor

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*## /  /'

install: ## Full setup (brew, stow, fonts, ssh, defaults)
	bash scripts/install.sh

stow: ## Deploy symlinks only
	$(STOW)

defaults: ## Apply macOS system preferences
	bash scripts/macos-defaults.sh

ssh: ## Generate/show GitHub SSH key
	bash scripts/setup-ssh.sh

fonts: ## Register MesloLGS NF with CoreText
	bash scripts/register-fonts.sh

doctor: ## Run health checks
	bash scripts/doctor.sh

.DEFAULT_GOAL := help
