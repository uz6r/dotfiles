# Requirements: Dotfiles Cross-Platform Compatibility

**Defined:** 2026-04-13
**Core Value:** Dotfiles that "just work" regardless of which OS I'm booted into

## v1 Requirements

### Platform Detection

- [ ] **PLAT-01**: .zshrc detects Darwin vs Linux via `uname -s`
- [ ] **PLAT-02**: Helper functions `is_darwin()` and `is_linux()` available
- [ ] **PLAT-03**: Platform stored in `$IS_LINUX` / `$IS_MACOS` variable

### PATH Configuration

- [ ] **PATH-01**: Homebrew bin in PATH for both platforms
- [ ] **PATH-02**: Apple Silicon (/opt/homebrew) vs Intel (/usr/local) detection on macOS
- [ ] **PATH-03**: Linuxbrew (~/.linuxbrew or /home/linuxbrew/.linuxbrew) detection on Linux
- [ ] **PATH-04**: Standard paths (~/bin, ~/.local/bin) work on both

### Aliases

- [ ] **ALIAS-01**: `copy` alias works (pbcopy on macOS, xclip on Linux)
- [ ] **ALIAS-02**: `paste` alias works (pbpaste on macOS, xclip on Linux)
- [ ] **ALIAS-03**: `open` alias works (native on macOS, xdg-open on Linux)
- [ ] **ALIAS-04**: `localip` works on both (ifconfig on macOS, ip addr on Linux)
- [ ] **ALIAS-05**: `ports` uses lsof (works on both) instead of Linux netstat flags
- [ ] **ALIAS-06**: `ll` uses `-G` on macOS, `--color=auto` on Linux

### Functions

- [ ] **FUNC-01**: `killport()` works on both platforms (lsof works on both)
- [ ] **FUNC-02**: `localdev()` wrapped in Linux check (Courtsite is Linux-only)

### Scripts

- [ ] **SCRI-01**: install.sh detects and uses brew on macOS
- [ ] **SCRI-02**: install.sh detects and uses apt on Linux
- [ ] **SCRI-03**: install.sh works non-interactively on both platforms

### Documentation

- [ ] **DOCS-01**: README.md documents Homebrew requirement for macOS
- [ ] **DOCS-02**: README.md documents Linuxbrew requirement for Linux
- [ ] **DOCS-03**: Linux ↔ macOS tool equivalents documented

## Out of Scope

| Feature | Reason |
|---------|--------|
| Windows WSL support | Not using |
| iTerm2 specific config | Using VS Code terminal |
| Brewfile generation | Manual brew install fine |
| Linux distribution-specific tweaks | Ubuntu assumed |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PLAT-01 | Phase 1 | ✓ Complete |
| PLAT-02 | Phase 1 | ✓ Complete |
| PLAT-03 | Phase 1 | ✓ Complete |
| PATH-01 | Phase 1 | ✓ Complete |
| PATH-02 | Phase 1 | ✓ Complete |
| PATH-03 | Phase 1 | ✓ Complete |
| PATH-04 | Phase 1 | ✓ Complete |
| ALIAS-01 | Phase 1 | ✓ Complete |
| ALIAS-02 | Phase 1 | ✓ Complete |
| ALIAS-03 | Phase 1 | ✓ Complete |
| ALIAS-04 | Phase 1 | ✓ Complete |
| ALIAS-05 | Phase 1 | ✓ Complete |
| ALIAS-06 | Phase 1 | ✓ Complete |
| FUNC-01 | Phase 1 | ✓ Complete |
| FUNC-02 | Phase 1 | ✓ Complete |
| SCRI-01 | Phase 2 | Pending |
| SCRI-02 | Phase 2 | Pending |
| SCRI-03 | Phase 2 | Pending |
| DOCS-01 | Phase 2 | Pending |
| DOCS-02 | Phase 2 | Pending |
| DOCS-03 | Phase 2 | Pending |

**Coverage:**
- v1 requirements: 22 total
- Mapped to phases: 22
- Phase 1: 15/15 complete ✓
- Phase 2: 0/7 complete (pending)
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-13*
*Last updated: 2026-04-13 after Phase 1 completion*
