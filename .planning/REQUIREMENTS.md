# Milestone v1.2 Requirements: Cleanup & Decoupling

**Milestone Goal:** Remove Courtsite/company-specific configuration since leaving the company

## Milestone v1.2 Requirements

### Shell Configuration

- [ ] **SHELL-01**: User can use dotfiles without Courtsite-specific `localdev()` function (remove function and nested `start_tmux_layout()` from .zshrc)
- [ ] **SHELL-02**: User can use dotfiles without commented Courtsite aliases (remove lines 311-328 and TODO markers from .zshrc)
- [ ] **SHELL-03**: User can use dotfiles without COURTSITE_DIR variable references (clean up all `${COURTSITE_DIR:-$HOME/Courtsite}` usage)
- [ ] **SHELL-04**: User can use dotfiles with cross-platform detection logic preserved (keep `is_darwin()`, `is_linux()`, and `case "$(uname -s)"` block lines 36-77)

### Scripts & Binaries

- [ ] **SCRIPT-01**: User can use dotfiles without Courtsite-specific scripts (unstow then delete `bin/sinar-pi-setup` and `bin/sinar-pi-wifi-setup`)
- [ ] **SCRIPT-02**: User can verify no broken symlinks exist in `~/bin/` after script removal (run stow cleanup verification)
- [ ] **SCRIPT-03**: User can use dotfiles with correct PATH configuration (audit line 80 `$HOME/uz6r/dotfiles/scripts` reference, verify scripts/ directory exists)

### Documentation & Verification

- [ ] **DOC-01**: User can read README.md without Courtsite references (update documentation to remove sinar script mentions)
- [ ] **DOC-02**: User can verify no remaining Courtsite/sinar/enjin references in repo (use ripgrep: `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"`)
- [ ] **DOC-03**: User can check local machine's `~/.zshrc.local` for Courtsite references (manual verification, not in git)

### Git History (Future)

- [ ] **GIT-01**: User can share repo publicly without Courtsite paths in git history (use git-filter-repo to rewrite history — only if repo goes public)

## Future Requirements (Deferred)

- Lazy-load non-critical plugins based on profiling data (from v1.1 planning)
- Cross-platform validation on macOS (when available)
- Test stow symlink creation
- Modular `.zshrc` with numeric prefixes (`conf.d/` directory structure)
- Centralized `~/.config/exports/` for environment variables

## Out of Scope

- [Windows WSL] — not using, no need
- [Shell integration for iTerm2] — default terminal fine
- [Brewfile generation] — manual brew install sufficient
- [Courtsite features in dotfiles] — leaving company, removing all company-specific config

## Traceability

| REQ-ID | Phase | Status |
|---------|-------|--------|
| SHELL-01 | — | Pending |
| SHELL-02 | — | Pending |
| SHELL-03 | — | Pending |
| SHELL-04 | — | Pending |
| SCRIPT-01 | — | Pending |
| SCRIPT-02 | — | Pending |
| SCRIPT-03 | — | Pending |
| DOC-01 | — | Pending |
| DOC-02 | — | Pending |
| DOC-03 | — | Pending |
| GIT-01 | — | Deferred |

---
*Requirements defined: 2026-04-30 for milestone v1.2*
