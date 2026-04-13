# STACK.md — Technology Stack

**Focus:** Technologies, languages, runtimes, frameworks, and dependencies

## Languages & Runtimes

| Language | Version/Notes | Usage |
|----------|---------------|-------|
| Shell (sh/zsh) | zsh with oh-my-zsh | Shell configuration and scripts |
| Lua | neovim built-in | Neovim configuration |
| Make | GNU Makefile | Build automation and tasks |

## Package Managers

| Manager | Platform Support | Usage |
|---------|------------------|-------|
| Homebrew | macOS (Intel/Apple Silicon), Linux (Linuxbrew) | Primary package manager |
| apt | Linux | Fallback for system packages |
| pnpm | Cross-platform | Node.js package manager |
| npm | Cross-platform | Node.js (used as fallback) |
| cargo | Cross-platform | Rust packages (stylua) |
| go | Cross-platform | Go packages (shfmt) |

## Key Dependencies

### Shell/Tooling
- `stow` — symlink manager for dotfiles
- `shellcheck` — shell script linter
- `shfmt` — shell script formatter
- `yamllint` — YAML linter
- `jq` — JSON processor

### Neovim Plugins
- `lazy.nvim` — plugin manager
- `telescope.nvim` — fuzzy finder
- `nvim-treesitter` — syntax highlighting
- `nvim-tree.lua` — file explorer
- `nvim-cmp` — autocomplete
- `nvim-lspconfig` — LSP client
- `gruvbox` — color scheme
- `toggleterm` — terminal integration
- `claudecode.nvim` — AI assistant
- `gemini-cli.nvim` — Gemini CLI integration
- `ollama.nvim` — Ollama AI integration

### CLI Tools
- `lazygit` — git UI (in `bin/`)
- `yt-dlp` — youtube downloader
- `fzf` — fuzzy finder

## Configuration Files

| File | Purpose |
|------|---------|
| `Makefile` | Task automation (bootstrap, lint, format, ci-check) |
| `install.sh` | Bootstrap script (stow, homebrew, git hooks) |
| `.zshrc` | Shell configuration (aliases, functions, paths) |
| `init.lua` | Neovim configuration (plugins, keymaps, LSP) |
| `.tmux.conf` | Terminal multiplexer config |
| `.gitconfig` | Git configuration |

## Platform Support

- **macOS**: Darwin detection, Homebrew paths, pbcopy/pbpaste
- **Linux**: Linux detection, xclip/xdg-open fallback