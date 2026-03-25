# Conventions

## Code Style

### Shell Scripts (Bash/Zsh)

- Use `#!/bin/sh` for portable scripts, `#!/usr/bin/env bash` for bash-specific
- Use `set -e` for error handling
- 2-space indentation in shfmt
- Follow ShellCheck guidelines

### Lua (Neovim)

- Use tabs for indentation (converted by stylua)
- Use `vim.` namespace for Neovim API
- Use `require()` for module loading

### YAML

- 2-space indentation
- Follow `.yamllint.yaml` strict rules in CI

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | Lowercase, hyphens | `sinar-pi-setup`, `.zshrc` |
| Directories | Lowercase | `zsh`, `nvim`, `bin` |
| Make targets | Lowercase | `bootstrap`, `format`, `ci-check` |
| Git aliases | Short, lowercase | `gs`, `ga`, `gc`, `gp` |
| Zsh aliases | Lowercase, descriptive | `ll`, `dotfiles`, `dev` |
| Zsh functions | Lowercase, camelCase | `mkcd`, `bak`, `killport`, `localdev`, `gql` |
| Neovim keymaps | Descriptive | `<leader>w`, `<leader>q`, `<leader>ff` |

## Patterns

### Error Handling
- Shell: `set -e` at script start
- Lua: Use `vim.fn` for functions that can fail

### Conditional Loading
- Zsh: Check if file exists before sourcing (e.g., `zsh-autosuggestions`, `.zshrc.local`)
- Neovim: Use `vim.loop.fs_stat()` for file existence

### Modular Configuration
- Neovim: Use lazy.nvim with plugin specs
- Zsh: Group related configs (aliases, functions, paths)

## Keymap Patterns (Neovim)

- `<leader>` is space
- Navigation: `C-h/j/k/l` for window movement
- Files: `ff` (find files), `fg` (live grep), `fb` (buffers)
- Git: `gs` (status), `gp` (push), `gg` (fugitive)
- Terminal: `gt` (toggle term), `ao` (open AI)

## Tool Versions

See `STACK.md` for specific tool versions.