# Integrations

This dotfiles repository manages local development environment integrations.

## External Services & APIs

No external API integrations in dotfiles themselves. However, the zsh config includes shortcuts for:

| Service | Integration Type | Config Location |
|---------|------------------|-----------------|
| **yt-dlp** | YouTube/Video downloading | `zsh/.zshrc:265-273` |

## Package Managers

| Manager | Purpose | Config |
|---------|---------|--------|
| **apt** | Debian/Ubuntu packages | `Makefile`, `install.sh` |
| **brew** | macOS packages | `Makefile`, `install.sh` |
| **npm** | Node tools (prettier) | `Makefile` |
| **Go** | Go tools (shfmt) | `Makefile` |
| **Cargo** | Rust tools (stylua) | `Makefile` |
| **Luarocks** | Lua tools (luacheck) | `Makefile` |
| **pnpm** | Node package manager | `zsh/.zshrc:312-337` |

## Development Frameworks

Configured but external:
- **Neovim** - Editor (not a framework, but configured with LSP, treesitter, completion)
- **Lazy.nvim** - Plugin manager
- **Mason** - LSP/DAP/Linter installer

## Database Integrations

None in dotfiles directly. The `zsh/.zshrc` includes shortcuts to project directories that may contain database configs.

## Auth Providers

None directly in dotfiles. Machine-specific auth should be in:
- `~/.zshrc.local` - Shell overrides
- `~/.gitconfig.local` - Git overrides

## Webhooks

None configured in dotfiles.

## Notes

- All machine-specific secrets should go in `~/.zshrc.local` or `~/.gitconfig.local`
- The `git/.gitconfig` includes `~/.gitconfig.local` for overrides
- The `zsh/.zshrc` sources `~/.zshrc.local` for machine-specific settings