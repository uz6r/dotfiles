# Milestones

## v1.2 Cleanup & Decoupling (Shipped: 2026-05-26)

**Phases:** 3 phases (6-8), 5 plans, 13 tasks

**Key accomplishments:**

- Removed all Courtsite references from .zshrc — deleted localdev() function, commented aliases, COURTSITE_DIR usage. Cross-platform detection preserved.
- Added courtsite-guard to Makefile and pre-commit hook to prevent future Courtsite references from being introduced
- Deleted Courtsite scripts from bin/ — removed sinar-pi-setup (726 lines) and sinar-pi-wifi-setup (339 lines); fixed make status dot-prefix bug; cleaned PATH reference
- Updated README.md and STRUCTURE.md with zero Courtsite/sinar/enjin references, correct uz6r git URL, current bin/ scripts
- Tightened guard exclusions and added verify-cleanup target integrated into make test with ~/.zshrc.local check instructions

---

## v1.1 Shell Optimization (Shipped: 2026-04-14)

**Phases:** 3 phases (Phases 3-5), 10 requirements

**Key accomplishments:**

- Shell startup profiling script (`bin/profile-zsh` ~950ms timing)
- Neovim plugin audit script (`bin/audit-nvim-plugins` 23 plugins)
- Automated test suite (`make test` validates zsh, git, nvim)

---

## v1.0 Cross-Platform Compatibility (Shipped: 2026-04-13)

**Phases:** 2 phases (Phases 1-2), 22 requirements

**Key accomplishments:**

- Platform detection in zsh (.zshrc, Linux vs Darwin)
- Homebrew path configuration (Apple Silicon, Intel, Linuxbrew)
- Cross-platform aliases (copy, paste, open, localip, ports, ll)
- install.sh updated for both platforms
- README documentation

---
*Milestones updated: 2026-05-26*
