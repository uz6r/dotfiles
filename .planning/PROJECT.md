# Dotfiles Cross-Platform Compatibility

## What This Is

Personal dotfiles configured for dual-boot use between Ubuntu (Linux) and macOS. One repository, works seamlessly on both platforms with platform-specific guards where needed.

## Core Value

Dotfiles that "just work" regardless of which OS I'm booted into. No surprises, no manual tweaks needed when switching.

## Requirements

### Validated

- ✓ zsh shell config with Powerlevel10k theme — existing
- ✓ Git config with aliases and global ignore — existing
- ✓ Neovim Lua-based config — existing
- ✓ Tmux config — existing
- ✓ GNU stow symlink management — existing
- ✓ Makefile with apt/brew detection — existing
- ✓ Bootstrap script (install.sh) — existing

### Active

- [ ] Add platform detection to zsh (Darwin vs Linux)
- [ ] Configure Homebrew paths for both platforms (linuxbrew + homebrew)
- [ ] Fix/update platform-specific tool aliases (clipboard, network tools)
- [ ] Update install.sh for macOS (brew paths, optional packages)
- [ ] Document Linux ↔ macOS tool equivalents
- [ ] Ensure all bin scripts work on both platforms

### Out of Scope

- [Windows WSL] — not using, no need
- [Shell integration for iTerm2] — default terminal fine
- [Brewfile generation] — manual brew install sufficient

## Context

Currently using Ubuntu on a desktop. Planning to get a MacBook and dual-boot. Need dotfiles that work on both.

**Existing structure:**
- `zsh/` — .zshrc, oh-my-zsh plugins, p10k config
- `git/` — .gitconfig
- `nvim/` — .config/nvim/init.lua + lua modules
- `tmux/` — .tmux.conf
- `bin/` — sinar-pi-setup, sinar-pi-wifi-setup (project-specific)
- `Makefile` — bootstrap, update, clean, status, lint/format
- `install.sh` — stow setup, git hooks

**Platform-specific current issues:**
- `xclip` alias (Linux only) — macOS uses `pbcopy`/`pbpaste`
- `ip addr` for localip (Linux) — macOS uses `ifconfig`
- `netstat -tulanp` flags (Linux) — macOS syntax differs
- Homebrew paths differ between platforms
- `localdev` function references Courtsite paths (can keep as-is, Linux-only project)

## Constraints

- **Shell:** zsh only — no bash compatibility needed
- **Terminal:** VS Code integrated terminal + system terminal
- **Editor:** Neovim for config, VS Code for project work
- **Package managers:** apt (Ubuntu) + Homebrew (macOS)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Unified dotfiles with guards | Single source of truth, easier to maintain | — Pending |
| Homebrew for macOS | Standard macOS package manager, Linux version available | — Pending |
| Platform detection via `uname -s` | Reliable, no external dependencies | — Pending |

---
*Last updated: 2026-04-13 after initial scope definition*
