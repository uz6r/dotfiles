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
- ✓ Shell startup profiling (v1.1) — `bin/profile-zsh` script
- ✓ Neovim plugin audit (v1.1) — `bin/audit-nvim-plugins` script  
- ✓ Automated dotfiles tests (v1.1) — `make test` validates zsh, git, nvim configs

### Out of Scope

- [Windows WSL] — not using, no need
- [Shell integration for iTerm2] — default terminal fine
- [Brewfile generation] — manual brew install sufficient

## Current State (v1.1 Shipped)

**Shipped:** 2026-04-14

- Shell profiling: `bin/profile-zsh` — measures startup time (~950ms), identifies slow components
- Plugin audit: `bin/audit-nvim-plugins` — lists 23 plugins, identifies candidates for removal
- Test suite: `make test` — validates zsh, git, nvim configs

## Context

Currently using Ubuntu on a desktop. Planning to get a MacBook and dual-boot. Need dotfiles that work on both.

**Existing structure:**
- `zsh/` — .zshrc, oh-my-zsh plugins, p10k config
- `git/` — .gitconfig
- `nvim/` — .config/nvim/init.lua + lua modules
- `tmux/` — .tmux.conf
- `bin/` — profile-zsh, audit-nvim-plugins, sinar-pi-setup, sinar-pi-wifi-setup
- `Makefile` — bootstrap, update, clean, status, lint/format, test
- `install.sh` — stow setup, git hooks

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
| `make test` for validation | Simple, fast feedback | ✓ Good |

## Next Milestone Goals

- Lazy-load non-critical plugins based on profiling data
- Cross-platform validation (test on macOS when available)
- Test stow symlink creation

---
*Last updated: 2026-04-14 after v1.1 milestone complete*