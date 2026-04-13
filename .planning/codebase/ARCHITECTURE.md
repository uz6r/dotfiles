# ARCHITECTURE.md — System Design & Patterns

**Focus:** Architecture pattern, layers, data flow, abstractions, and entry points

## Architecture Pattern

**Configuration as Code** — Dotfiles managed via GNU stow (symlink-based deployment)

```
dotfiles/          →  Source (stow packages)
    ├── zsh/       →  .zshrc
    ├── git/      →  .gitconfig
    ├── nvim/     →  .config/nvim/
    ├── bin/      →  ~/bin/
    └── tmux/     →  .tmux.conf

$HOME/             →  Target (symlinks created by stow)
```

## Layers

1. **Bootstrap Layer** (`install.sh`, `Makefile`)
   - Detects platform (Darwin/Linux)
   - Installs dependencies (stow, homebrew)
   - Runs stow to create symlinks

2. **Shell Layer** (`.zshrc`)
   - Platform detection
   - PATH configuration
   - Aliases and functions
   - Plugin loading (oh-my-zsh)

3. **Tool Layer** (git, nvim, tmux configs)
   - Tool-specific configuration
   - Loaded by respective tools

## Entry Points

| Entry Point | Trigger | Action |
|-------------|---------|--------|
| `install.sh` | `make bootstrap` | Install deps, run stow |
| `.zshrc` | Shell startup | Load all shell config |
| `init.lua` | Neovim startup | Load plugins and settings |
| `.tmux.conf` | tmux startup | Configure terminal |

## Data Flow

```
User runs: make bootstrap
    ↓
install.sh executes
    ↓
1. Platform detection (uname -s)
2. Homebrew install (if needed)
3. stow install (if needed)
4. Backup existing files
5. stow creates symlinks
6. git hooks configured

User starts shell:
    ↓
.zshrc loads
    ↓
1. oh-my-zsh base
2. Platform detection (IS_MACOS, IS_LINUX)
3. PATH setup (homebrew paths)
4. Aliases (platform-aware)
5. Functions (killport, localdev, etc.)
6. pnpm/nvm/optional plugins
7. Local overrides (.zshrc.local)
```

## Key Abstractions

| Abstraction | Location | Purpose |
|-------------|----------|---------|
| `is_darwin()` | `.zshrc:49` | Check if macOS |
| `is_linux()` | `.zshrc:50` | Check if Linux |
| `IS_MACOS` | `.zshrc:37` | Export for scripts |
| `IS_LINUX` | `.zshrc:38` | Export for scripts |
| `HOMEBREW_PREFIX` | `.zshrc:64-71` | Platform-specific path |
| `killport()` | `.zshrc:143` | Cross-platform port killing |
| `localdev()` | `.zshrc:155` | Courtsite multi-repo setup |

## Cross-Platform Patterns

- Platform detection via `uname -s`
- Conditional aliases based on `$IS_MACOS` / `$IS_LINUX`
- Tool fallbacks (xclip vs pbcopy, xdg-open vs open)