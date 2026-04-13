# INTEGRATIONS.md — External Services & APIs

**Focus:** External APIs, databases, auth providers, and integrations

## External Services

| Service | Integration | Notes |
|---------|-------------|-------|
| GitHub | SSH URL rewriting (`git@github.com:`) | Configured in `.gitconfig` |
| Homebrew | Package installation | Auto-installs on macOS/Linux |
| oh-my-zsh | Shell framework | Loaded via `$ZSH/oh-my-zsh.sh` |

## Neovim Plugin Sources

| Plugin | Source | Purpose |
|--------|--------|---------|
| lazy.nvim | github.com/folke/lazy.nvim | Plugin manager |
| telescope.nvim | github.com/nvim-telescope/telescope.nvim | Fuzzy finder |
| nvim-treesitter | github.com/nvim-treesitter/nvim-treesitter | Syntax highlighting |
| nvim-tree.lua | github.com/nvim-tree/nvim-tree.lua | File explorer |
| nvim-cmp | github.com/hrsh7th/nvim-cmp | Autocomplete |
| nvim-lspconfig | github.com/neovim/nvim-lspconfig | LSP support |
| toggleterm.nvim | github.com/akinsho/toggleterm.nvim | Terminal integration |
| claudecode.nvim | github.com/coder/claudecode.nvim | Claude Code AI |
| gemini-cli.nvim | github.com/jonroosevelt/gemini-cli.nvim | Gemini CLI |
| ollama.nvim | github.com/nomnivore/ollama.nvim | Ollama local AI |

## Optional External Tools

| Tool | Used By | Notes |
|------|---------|-------|
| Docker | `d`, `dc` aliases | Docker CLI shortcuts |
| pnpm | Node.js projects | Package management |
| nvm | Node version manager | Auto-loaded in `.zshrc` |
| fzf | Fuzzy finder | Optional, sourced if installed |

## No Direct API Integrations

This is a dotfiles repository — no external APIs are called directly. All integrations are through installed tools and plugins.