# Requirements: Dotfiles Cross-Platform Compatibility

**Defined:** 2026-05-26
**Core Value:** Dotfiles that "just work" regardless of OS — no surprises, no manual tweaks

## v1 Requirements

Requirements for v1.3 milestone. Each maps to roadmap phases.

### Sanitization

- [ ] **SANI-01**: Remove ZTE_EC382D.nmconnection from git tracking and add *.nmconnection to .gitignore
- [ ] **SANI-02**: Remove lazygit binary and lazygit.tar.gz from git tracking and .gitignore
- [ ] **SANI-03**: Replace hardcoded /home/uzer with $HOME (3 locations: .zshrc:3, .zshrc:365, bin/audit-nvim-plugins:7)
- [ ] **SANI-04**: Expand .gitignore with security patterns (.env*, *.pem, *.key, *.pfx, credentials, .aws/, private/)
- [ ] **SANI-05**: Install Gitleaks v8.30.1 with custom .gitleaks.toml configuration
- [ ] **SANI-06**: Create make sanitize comprehensive zero-tolerance scan target
- [ ] **SANI-07**: Extend pre-commit hook with secret scanning and binary detection
- [ ] **SANI-08**: Create bin/audit-secrets dual-mode (REPORT/STRICT) script

### macOS Compatibility

- [ ] **MACO-01**: Fix duh alias with platform guard for Linux (--max-depth=1) and macOS (-d 1)
- [ ] **MACO-02**: Fix readlink -f in Makefile with greadlink fallback chain
- [ ] **MACO-03**: Fix grep -oP in bin/audit-nvim-plugins for portable regex
- [ ] **MACO-04**: Fix date +%s%N in bin/profile-zsh with macOS-compatible fallback
- [ ] **MACO-05**: Create bin/verify-macos static analysis script for Linux-only flags
- [ ] **MACO-06**: Create make macos-check target wrapping bin/verify-macos

### Maintainability

- [ ] **MAIN-01**: Remove stale scripts/ PATH entry from .zshrc:80 and delete empty scripts/ directory
- [ ] **MAIN-02**: Update CONCERNS.md (remove resolved v1.2 items, add v1.3 audit concerns)
- [ ] **MAIN-03**: Create .zshrc.local.example template with placeholder patterns
- [ ] **MAIN-04**: Verify install.sh idempotency (runs multiple times without errors)
- [ ] **MAIN-05**: Create make doctor comprehensive health check aggregating all targets

### Workflow Preservation

- [ ] **WORK-01**: Create bin/audit-workflow shell history profiler (top commands, functions, scripts)
- [ ] **WORK-02**: Generate WORKFLOW.md from shell history with anonymized paths
- [ ] **WORK-03**: Audit undocumented aliases and functions in shell for preservation

### Public-Safe Review

- [ ] **PUBS-01**: Create private/ directory as public/private boundary with README.md
- [ ] **PUBS-02**: Create PRE-RESET-CHECKLIST.md for local cleanup before machine wipe
- [ ] **PUBS-03**: Create make public-ready pre-open-source aggregator target
- [ ] **PUBS-04**: Create make audit-home home-directory scan target

## Deferred

- **GIT-01**: git-filter-repo history rewrite (only needed if repo goes public)
- **CI macOS runner**: macOS CI in GitHub Actions (deferred to v1.4+)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Modular nvim init.lua split | Defer to future milestone |
| Courtsite source directory cleanup (~/Courtsite/) | User's local machine responsibility — documented in PRE-RESET-CHECKLIST.md |
| git-filter-repo full history scrub | Only needed if repo goes public (GIT-01) |
| Brewfile generation | Manual brew install sufficient |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SANI-01 | — | Pending |
| SANI-02 | — | Pending |
| SANI-03 | — | Pending |
| SANI-04 | — | Pending |
| SANI-05 | — | Pending |
| SANI-06 | — | Pending |
| SANI-07 | — | Pending |
| SANI-08 | — | Pending |
| MACO-01 | — | Pending |
| MACO-02 | — | Pending |
| MACO-03 | — | Pending |
| MACO-04 | — | Pending |
| MACO-05 | — | Pending |
| MACO-06 | — | Pending |
| MAIN-01 | — | Pending |
| MAIN-02 | — | Pending |
| MAIN-03 | — | Pending |
| MAIN-04 | — | Pending |
| MAIN-05 | — | Pending |
| WORK-01 | — | Pending |
| WORK-02 | — | Pending |
| WORK-03 | — | Pending |
| PUBS-01 | — | Pending |
| PUBS-02 | — | Pending |
| PUBS-03 | — | Pending |
| PUBS-04 | — | Pending |

**Coverage:**
- v1 requirements: 28 total
- Mapped to phases: 0
- Unmapped: 28

---
*Requirements defined: 2026-05-26*
*Last updated: 2026-05-26 after milestone v1.3 research and scoping*
