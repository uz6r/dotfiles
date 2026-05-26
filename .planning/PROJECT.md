# Dotfiles Cross-Platform Compatibility

## What This Is

Personal dotfiles configured for dual-boot use between Ubuntu (Linux) and macOS. One repository, works seamlessly on both platforms with platform-specific guards where needed. All Courtsite/company-specific configuration has been removed — dotfiles are purely personal and portable.

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
- ✓ Cross-platform shell compatibility — v1.0
- ✓ Shell startup profiling (`bin/profile-zsh`) — v1.1
- ✓ Neovim plugin audit (`bin/audit-nvim-plugins`) — v1.1
- ✓ Automated dotfiles tests (`make test`) — v1.1
- ✓ Shell config cleanup — v1.2 (zero Courtsite references in .zshrc, cross-platform detection preserved)
- ✓ Courtsite guard — v1.2 (`make courtsite-guard` + pre-commit hook prevents regressions)
- ✓ Company scripts removal — v1.2 (sinar-pi-setup, sinar-pi-wifi-setup deleted; PATH cleaned)
- ✓ Documentation cleanup — v1.2 (README.md + STRUCTURE.md with zero company references)
- ✓ verify-cleanup target — v1.2 (full-repo Courtsite scan integrated into `make test`)

### Deferred

- GIT-01 — git-filter-repo history rewrite (only if repo goes public)

### Out of Scope

- [Windows WSL] — not using, no need
- [Shell integration for iTerm2] — default terminal fine
- [Brewfile generation] — manual brew install sufficient

## Current State

**v1.2 Cleanup & Decoupling shipped** (2026-05-26)

- 3 phases (6-8), 5 plans, 13 tasks completed
- All Courtsite/sinar/enjin references removed from repo
- Zero company references in user-facing code (`rg -i "courtsite|sinar|enjin" --files-with-matches .` returns only planning/guard files)
- `make test` validates zsh syntax, git config, nvim config, courtsite-guard, and full verify-cleanup
- Pre-commit hook blocks any future Courtsite references from being committed
- 1065+ lines of Courtsite-specific code deleted (sinar-pi-setup 726 + sinar-pi-wifi-setup 339)
- Platform detection logic preserved: `is_darwin()`, `is_linux()`, Homebrew PATH for both OSes

## Context

Currently using Ubuntu on a desktop. Leaving the company — all Courtsite/company-specific configuration has been removed from personal dotfiles. The repo is clean, portable, and ready for the next phase.

**Current structure:**
- `zsh/` — .zshrc, oh-my-zsh plugins, p10k config
- `git/` — .gitconfig with aliases and global ignore
- `nvim/` — .config/nvim/init.lua + lua modules
- `tmux/` — .tmux.conf
- `bin/` — profile-zsh (~950ms timing), audit-nvim-plugins (23 plugins listed)
- `Makefile` — bootstrap, update, clean, status, lint/format, test (includes courtsite-guard + verify-cleanup)
- `install.sh` — stow setup, git hooks
- `.githooks/pre-commit` — lint + courtsite reference blocker

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
| Courtsite-guard in Makefile + pre-commit | Prevents regressions from reintroducing company refs (v1.2) | ✓ Good |
| Guard evolution: temp exclusions → permanent | Gradual tightening as cleanup phases complete (v1.2) | ✓ Good |
| verify-cleanup as stricter secondary check | Zero exclusions beyond .git for full-repo proof (v1.2) | ✓ Good |
| Per-package prefix logic in make status | bin/ uses $HOME/, others use $HOME/. — fixed pre-existing bug (v1.2) | ✓ Good |

## Current Milestone: v1.3 Final Audit & Sanitization before Laptop Reset

**Goal:** Comprehensive audit of the dotfiles repo and developer environment before the current machine is wiped — preserve all portable workflows, eliminate any remaining sensitive/proprietary traces, and ensure macOS compatibility.

**Target features:**
- Deep workflow preservation audit (aliases, functions, shell history, scripts, editor configs)
- Zero-tolerance sanitization (company refs, secrets, tokens, internal URLs, credentials)
- macOS compatibility review (Linux-only assumptions, package manager, filesystem, shell)
- Repository maintainability improvements (stale configs, idempotency, organization, docs)
- Portable/public-safe structure validation (separate public from private state)

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
*Last updated: 2026-05-26 after v1.2 milestone*
