# Stack

This is a dotfiles repository - infrastructure-as-code for personal development environment.

## Languages & Runtimes

| Language | Version | Usage |
|----------|---------|-------|
| **Shell (Bash/Zsh)** | - | Primary config files |
| **Lua** | 5.4 | Neovim configuration |
| **YAML** | - | GitHub Actions, configs |
| **JSON** | - | Package locks, lazy.nvim |

## Core Tools

| Tool | Purpose | Config Location |
|------|---------|-----------------|
| **GNU Stow** | Symlink manager for dotfiles | `Makefile` |
| **Make** | Task runner | `Makefile` |
| **Zsh** | Shell | `zsh/.zshrc` |
| **Oh My Zsh** | Zsh framework | Loaded in `.zshrc` |
| **Powerlevel10k** | Zsh theme | `zsh/.p10k.zsh` |
| **Neovim** | Editor | `nvim/.config/nvim/init.lua` |
| **Lazy.nvim** | Plugin manager | `nvim/.config/nvim/init.lua:146-158` |
| **Tmux** | Terminal multiplexer | `tmux/.tmux.conf` |
| **Git** | Version control | `git/.gitconfig` |

## Linting & Formatting Tools

| Tool | Purpose | Config |
|------|---------|--------|
| **shellcheck** | Shell script linting | `Makefile` |
| **shfmt** | Shell formatting | `Makefile` |
| **yamllint** | YAML linting | `.yamllint.yaml` |
| **jq** | JSON validation | `Makefile` |
| **prettier** | YAML/JSON/MD formatting | `Makefile` |
| **luacheck** | Lua linting | `.luacheckrc` |
| **stylua** | Lua formatting | `Makefile` |

## Neovim Plugins

Key plugins (from `nvim/.config/nvim/init.lua`):
- `nvim-telescope/telescope.nvim` - Fuzzy finder
- `nvim-treesitter/nvim-treesitter` - Syntax highlighting
- `nvim-tree/nvim-tree.lua` - File explorer
- `nvim-lualine/lualine.nvim` - Statusline
- `hrsh7th/nvim-cmp` - Autocomplete
- `akinsho/toggleterm.nvim` - Terminal integration
- `williamboman/mason.nvim` - LSP manager
- `neovim/nvim-lspconfig` - LSP support
- `tpope/vim-fugitive` - Git integration
- `gruvbox-community/gruvbox` - Color scheme

## Zsh Plugins

From `zsh/.zshrc`:
- `git` - Git aliases
- `sudo` - sudo prefix
- `web-search` - Web search
- `copyfile` - File copying
- `copybuffer` - Buffer copying
- `dirhistory` - Directory navigation
- Optional: `zsh-autosuggestions`, `zsh-syntax-highlighting`

## System Requirements

- Linux or macOS with GNU tools
- Package managers: apt (Debian/Ubuntu), brew (macOS), or manual
- Go (for shfmt), npm (for prettier), cargo (for stylua), luarocks (for luacheck)

## CI/CD

- GitHub Actions (`.github/workflows/ci.yml`)
- Runs: `make ci-check` on push to main and pull requests