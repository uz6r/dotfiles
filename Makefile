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

# -------------------
# lint + format (auto-install tools if missing)
# -------------------

SHELL_SCRIPTS := $(shell find . -type f -name "*.sh")
YAML_FILES    := $(shell find . -type f -name "*.yml" -o -name "*.yaml")
JSON_FILES    := $(shell find . -type f -name "*.json")

format: ## lint and format everything (auto-install tools if missing)
	@command -v shellcheck >/dev/null 2>&1 || { echo "→ installing shellcheck"; sudo apt-get update && sudo apt-get install -y shellcheck; }
	@command -v shfmt >/dev/null 2>&1 || { echo "→ installing shfmt"; sudo apt-get update && sudo apt-get install -y shfmt; }
	@command -v yamllint >/dev/null 2>&1 || { echo "→ installing yamllint"; sudo apt-get update && sudo apt-get install -y yamllint; }
	@command -v jq >/dev/null 2>&1 || { echo "→ installing jq"; sudo apt-get update && sudo apt-get install -y jq; }
	@command -v prettier >/dev/null 2>&1 || { echo "→ installing prettier"; npm install -g prettier; }

	@echo "→ linting shell scripts"
	@[ -z "$(SHELL_SCRIPTS)" ] || shellcheck $(SHELL_SCRIPTS) || true

	@echo "→ syntax checking .zshrc"
	@zsh -n zsh/.zshrc || true

	@echo "→ linting yaml"
	@[ -z "$(YAML_FILES)" ] || yamllint $(YAML_FILES)

	@echo "→ linting json"
	@for f in $(JSON_FILES); do \
		[ -f $$f ] && jq empty $$f || true; \
	done

	@echo "→ formatting shell scripts with shfmt"
	@[ -z "$(SHELL_SCRIPTS)" ] || shfmt -i 2 -ci -w $(SHELL_SCRIPTS)

	@echo "→ formatting yaml/json/md with prettier"
	@prettier -w $(YAML_FILES) $(JSON_FILES) *.md || true
