# default target
all: help

help: ## show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

bootstrap: ## install stow + link dotfiles
	chmod +x install.sh
	./install.sh

update: ## pull latest and relink
	git pull origin main
	./install.sh

clean: ## remove symlinks created by stow
	stow -D zsh git nvim bin

status: ## show git status
	git status
