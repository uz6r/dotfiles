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
- ✓ Cross-platform shell compatibility (v1.0) — platform detection, Homebrew paths, cross-platform aliases, install.sh, docs

## Current Milestone: v1.1 Shell Optimization

**Goal:** Profile shell startup, audit neovim plugins, add automated tests

**Target features:**
- Shell startup profiling to identify slow loads
- Neovim plugin audit to find and remove unused plugins
- Automated dotfiles tests

### Active

- [ ] Shell startup profiling to identify slow loads
- [ ] Neovim plugin audit to find and remove unused plugins
- [ ] Automated dotfiles tests

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
| Unified dotfiles with guards | Single source of truth, easier to maintain | ✓ Good |
| Homebrew for macOS | Standard macOS package manager, Linux version available | ✓ Good |
| Platform detection via `uname -s` | Reliable, no external dependencies | ✓ Good |

---
*Last updated: 2026-04-14 after v1.0 complete, starting v1.1 Shell Optimization*
