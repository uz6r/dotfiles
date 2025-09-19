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

status: ## show dotfiles + symlink status
	@echo "→ checking stow"
	$(call ensure_tool,stow,stow)

	@echo "→ verifying symlinks"
	@for d in zsh git nvim bin; do \
		if [ -d $$d ]; then \
			echo "scanning $$d ..."; \
			for f in $$d/*; do \
				[ -e "$$f" ] || continue; \
				target="$$HOME/.$$(basename $$f)"; \
				if [ -L "$$target" ]; then \
					if [ -e "$$(readlink -f $$target)" ]; then \
						echo "✅ $$target → $$(readlink $$target)"; \
					else \
						echo "❌ $$target is a broken symlink"; \
					fi; \
				elif [ -e "$$target" ]; then \
					echo "⚠️  $$target exists but is not a symlink"; \
				else \
					echo "❌ $$target missing"; \
				fi; \
			done; \
		else \
			echo "⚠️  dir $$d not found"; \
		fi; \
	done

# -------------------
# lint + format (cross-platform auto-install)
# -------------------

SHELL_SCRIPTS := $(shell find . -type f -name "*.sh")
YAML_FILES    := $(shell find . -type f -name "*.yml" -o -name "*.yaml")
JSON_FILES    := $(shell find . -type f -name "*.json")
LUA_FILES	 := $(shell find . -type f -name "*.lua")

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

setup: ## install all lint/format dependencies
	@echo "→ installing shellcheck"
	$(call ensure_tool,shellcheck,shellcheck)

	@echo "→ installing shfmt"
	@if ! command -v shfmt >/dev/null 2>&1; then \
		if command -v go >/dev/null 2>&1; then \
			go install mvdan.cc/sh/v3/cmd/shfmt@latest; \
		else \
			echo "⚠️  go not found, install shfmt manually"; \
		fi \
	fi

	@echo "→ installing yamllint"
	$(call ensure_tool,yamllint,yamllint)

	@echo "→ installing jq"
	$(call ensure_tool,jq,jq)

	@echo "→ installing prettier"
	@if ! command -v prettier >/dev/null 2>&1; then \
		if command -v npm >/dev/null 2>&1; then \
			npm install -g prettier; \
		else \
			echo "⚠️  npm not found, install prettier manually"; \
		fi \
	fi

	@echo "→ installing luacheck"
	@if ! command -v luacheck >/dev/null 2>&1; then \
		if command -v luarocks >/dev/null 2>&1; then \
			luarocks install luacheck; \
		else \
			echo "⚠️  luarocks not found, install luacheck manually"; \
		fi \
	fi

	@echo "→ installing stylua"
	@if ! command -v stylua >/dev/null 2>&1; then \
		if command -v cargo >/dev/null 2>&1; then \
			cargo install stylua; \
		else \
			echo "⚠️  cargo (rust) not found, install stylua manually"; \
		fi \
	fi

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
	$(call ensure_tool,luacheck,luacheck)
	$(call ensure_tool,stylua,stylua)

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

	@echo "→ linting lua files"
	@[ -z "$(LUA_FILES)" ] || luacheck $(LUA_FILES) || true

	@echo "→ formatting lua files with stylua"
	@[ -z "$(LUA_FILES)" ] || stylua $(LUA_FILES)

ci-check: ## run formatters + strict lint checks (used in CI)
	@echo "→ running make format"
	@$(MAKE) format

	@echo "→ running strict yamllint"
	@yamllint .

	@echo "→ checking for uncommitted diffs"
	@git diff --exit-code || (echo "❌ run 'make format' locally before committing" && exit 1)
