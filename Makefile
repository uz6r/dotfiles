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
# lint + format (cross-platform auto-install)
# -------------------

SHELL_SCRIPTS := $(shell find . -type f -name "*.sh")
YAML_FILES    := $(shell find . -type f -name "*.yml" -o -name "*.yaml")
JSON_FILES    := $(shell find . -type f -name "*.json")

define ensure_tool
	@command -v $(1) >/dev/null 2>&1 || { \
		if command -v apt-get >/dev/null 2>&1; then \
			echo "→ installing $(1) with apt"; \
			sudo apt-get update && sudo apt-get install -y $(2); \
		elif command -v brew >/dev/null 2>&1; then \
			echo "→ installing $(1) with brew"; \
			brew install $(2); \
		else \
			echo "❌ package manager not found, install $(1) manually"; \
			exit 1; \
		fi; \
	}
endef

lint: ## run only linters (no auto-fix)
	$(call ensure_tool,shellcheck,shellcheck)
	$(call ensure_tool,yamllint,yamllint)
	$(call ensure_tool,jq,jq)

	@echo "→ linting shell scripts"
	@[ -z "$(SHELL_SCRIPTS)" ] || shellcheck $(SHELL_SCRIPTS) || true

	@echo "→ syntax checking .zshrc"
	@zsh -n zsh/.zshrc || true

	@echo "→ validating json"
	@for f in $(JSON_FILES); do \
		[ -f $$f ] && jq empty $$f || true; \
	done

	@echo "→ linting yaml"
	@[ -z "$(YAML_FILES)" ] || yamllint $(YAML_FILES) || true

format: ## lint and format everything (auto-fix)
	$(call ensure_tool,shellcheck,shellcheck)
	$(call ensure_tool,shfmt,shfmt)
	$(call ensure_tool,yamllint,yamllint)
	$(call ensure_tool,jq,jq)
	$(call ensure_tool,prettier,prettier)

	@echo "→ linting shell scripts"
	@[ -z "$(SHELL_SCRIPTS)" ] || shellcheck $(SHELL_SCRIPTS) || true

	@echo "→ syntax checking .zshrc"
	@zsh -n zsh/.zshrc || true

	@echo "→ validating json"
	@for f in $(JSON_FILES); do \
		[ -f $$f ] && jq empty $$f || true; \
	done

	@echo "→ formatting shell scripts with shfmt"
	@[ -z "$(SHELL_SCRIPTS)" ] || shfmt -i 2 -ci -w $(SHELL_SCRIPTS)

	@echo "→ formatting yaml/json/md with prettier"
	@prettier -w $(YAML_FILES) $(JSON_FILES) *.md || true

	@echo "→ linting yaml (post-format, non-blocking)"
	@[ -z "$(YAML_FILES)" ] || yamllint $(YAML_FILES) || true

ci-check: ## run formatters + strict lint checks (used in CI)
	@echo "→ running make format"
	@$(MAKE) format

	@echo "→ running strict yamllint"
	@yamllint .

	@echo "→ checking for uncommitted diffs"
	@git diff --exit-code || (echo "❌ run 'make format' locally before committing" && exit 1)
