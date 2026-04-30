# Dotfiles Cross-Platform Compatibility

## What This Is

Personal dotfiles configured for dual-boot use between Ubuntu (Linux) and macOS. One repository, works seamlessly on both platforms with platform-specific guards where needed.

## Core Value

Dotfiles that "just work" regardless of which OS I'm booted into. No surprises, no manual tweaks needed when switching.

## Current Milestone: v1.2 Cleanup & Decoupling

**Goal:** Remove Courtsite/company-specific configuration since leaving the company

**Target features:**
- Remove Courtsite references from .zshrc (commented TODOs, localdev function, COURTSITE_DIR usage)
- Move Courtsite aliases to .zshrc.local (already there, ensure not in .zshrc)
- Remove Courtsite-related scripts from bin/ (sinar-pi-setup, sinar-pi-wifi-setup)
- Clean up any remaining Courtsite-specific configuration

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

Currently using Ubuntu on a desktop. Leaving the company — removing all Courtsite/company-specific configuration from personal dotfiles to keep them generic and portable.

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

- Complete removal of Courtsite-specific configuration
- Ensure dotfiles remain cross-platform compatible after cleanup

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-30 after v1.2 milestone started*