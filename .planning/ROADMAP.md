# Roadmap: Dotfiles Cross-Platform Compatibility

**Phases:** 2 | **Requirements:** 22 | **Created:** 2026-04-13

## Phase 1: Platform Foundation

**Goal:** Core platform detection and alias fixes

### Requirements (14)
- PLAT-01, PLAT-02, PLAT-03 (Platform detection)
- PATH-01, PATH-02, PATH-03, PATH-04 (PATH configuration)
- ALIAS-01, ALIAS-02, ALIAS-03, ALIAS-04, ALIAS-05, ALIAS-06 (Aliases)
- FUNC-01, FUNC-02 (Functions)

### Success Criteria
1. `uname -s` detection works correctly on both platforms
2. Homebrew paths set correctly (Apple Silicon, Intel, Linuxbrew)
3. `copy`, `paste`, `open` aliases work on both platforms
4. `localip` shows correct IP on both platforms
5. `ports` shows listening ports on both platforms
6. `ll` shows colored output on both platforms
7. `killport` kills processes by port on both platforms
8. `zsh -n ~/.zshrc` passes on both platforms

---

## Phase 2: Scripts & Documentation

**Goal:** install.sh updates and README documentation

### Requirements (8)
- SCRI-01, SCRI-02, SCRI-03 (Scripts)
- DOCS-01, DOCS-02, DOCS-03 (Documentation)

### Success Criteria
1. `install.sh` installs Homebrew if not present (both platforms)
2. `install.sh` runs stow and links configs on both platforms
3. `install.sh` works non-interactively with flags
4. README documents Homebrew installation for both platforms
5. README lists Linux ↔ macOS tool equivalents
6. All v1 requirements verified working on both platforms

---

## Phase Summary

| Phase | Goal | Requirements | Success Criteria |
|-------|------|--------------|------------------|
| 1 | Platform Foundation | 14 | Platform detection + aliases work on both |
| 2 | Scripts & Docs | 8 | install.sh + README complete |

---

## Milestone: Cross-Platform Ready ✓

**When:** Both phases complete

**Done means:**
- Dotfiles clone + bootstrap works on clean Ubuntu install
- Dotfiles clone + bootstrap works on clean macOS install
- Switching between platforms requires no manual tweaks
- All current functionality preserved on Linux

---
*Roadmap created: 2026-04-13*
