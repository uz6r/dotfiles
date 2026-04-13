# CONVENTIONS.md — Code Style & Patterns

**Focus:** Code style, naming conventions, patterns, and error handling

## Shell Scripts (install.sh)

- Shebang: `#!/bin/sh` (POSIX-compatible)
- Variable assignment: `var="value"` (no spaces around `=`)
- Functions: `function_name() { ... }` (no `function` keyword)
- Conditionals: `[ "$var" = "value" ]` (space required)
- Error handling: `set -e` at top

Example from `install.sh`:
```sh
#!/bin/sh
set -e

backup_dir="$HOME/dotfiles_backup"
mkdir -p "$backup_dir"

platform() {
  uname -s
}

if [ "$(platform)" = "Darwin" ]; then
  install_homebrew
fi
```

## Zsh Configuration (.zshrc)

- Comments: `# descriptive comment`
- Booleans: `true`/`false` strings (`export IS_MACOS=false`)
- Functions: `function_name() { ... }` or `name() { ... }`
- Conditionals: `if is_darwin; then ... fi`

Key patterns:
```zsh
# Platform detection
case "$(uname -s)" in
  Darwin*) export IS_MACOS=true ;;
  Linux*) export IS_LINUX=true ;;
esac

# Helper functions
is_darwin() { [[ "$IS_MACOS" == "true" ]]; }
is_linux() { [[ "$IS_LINUX" == "true" ]]; }

# Conditional aliases
if is_darwin; then
  alias ll='ls -lahG'
else
  alias ll='ls -lah --color=auto'
fi
```

## Neovim Lua (init.lua)

- Style: 2-space indentation
- Keymaps: `vim.keymap.set(mode, key, rhs, opts)`
- Options: `vim.opt.number = true` or `vim.opt_local`
- Plugins: `require("lazy").setup({...})`

Example:
```lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.keymap.set("n", "<leader>w", ":w<cr>")
require("lazy").setup({
  { "nvim-telescope/telescope.nvim" },
})
```

## Git Configuration (.gitconfig)

- INI format with `[section]` headers
- Indentation: tabs
- Commands use abbreviations (st, ci, br, co)

## Tmux Configuration (.tmux.conf)

- Directives: `set -g option value`
- Key bindings: `bind key command`
- Comments: `# comment`

## Error Handling

| File | Approach |
|------|----------|
| `install.sh` | `set -e` (exit on error) |
| `.zshrc` | Graceful fallbacks (`command -v X >/dev/null`) |
| `init.lua` | Try/catch via `pcall`, plugin lazy-loading |
| Makefile | `|| true` for optional tools |

## No Hard-Coded Secrets

- Machine-specific values in `.zshrc.local` and `.gitconfig.local`
- These files are gitignored and not in the repo