# Requirements: Dotfiles Shell Optimization

**Defined:** 2026-04-14
**Core Value:** Dotfiles that "just work" regardless of which OS I'm booted into

## v1 Requirements

### Shell Profiling

- [ ] **PROF-01**: zsh startup timing script measures load time of .zshrc
- [ ] **PROF-02**: Profiler identifies which plugins/sources take the most time
- [ ] **PROF-03**: Profiler outputs actionable suggestions for slow components

### Neovim Plugin Audit

- [ ] **NVIM-01**: Script analyzes Neovim plugin usage via :Lazy (or JSON output)
- [ ] **NVIM-02**: Plugin audit identifies plugins loaded but not used (via standard indicators)
- [ ] **NVIM-03**: Audit provides recommendations for plugins to remove

### Automated Tests

- [ ] **TEST-01**: Test suite validates zsh syntax (`zsh -n`) for all zsh config files
- [ ] **TEST-02**: Test suite validates Neovim config loads without errors (`nvim --headless`)
- [ ] **TEST-03**: Test suite validates Git config syntax
- [ ] **TEST-04**: Test suite runs via Makefile (`make test` or `make lint`)

## v2 Requirements

### Shell Optimization

- **PROF-04**: Lazy-load non-critical plugins/functions based on profiling data
- **PROF-05**: Implement cached zshrc compilation (zcompdump)

### Test Expansion

- **TEST-05**: Cross-platform validation (test on both Linux and macOS if available)
- **TEST-06**: Test stow symlink creation

## Out of Scope

| Feature | Reason |
|---------|--------|
| Neovim startup profiling (vs plugin) | Plugin audit sufficient for v1 |
| CI/CD integration | Local test run sufficient |
| Test coverage reporting | Binary pass/fail sufficient |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PROF-01 | Phase 3 | ✓ Complete |
| PROF-02 | Phase 3 | ✓ Complete |
| PROF-03 | Phase 3 | ✓ Complete |
| NVIM-01 | Phase 4 | ✓ Complete |
| NVIM-02 | Phase 4 | ✓ Complete |
| NVIM-03 | Phase 4 | ✓ Complete |
| TEST-01 | Phase 5 | ✓ Complete |
| TEST-02 | Phase 5 | ✓ Complete |
| TEST-03 | Phase 5 | ✓ Complete |
| TEST-04 | Phase 5 | ✓ Complete |

**Coverage:**
- v1 requirements: 10 total
- Mapped to phases: 0
- Unmapped: 0 (will be mapped by roadmapper)

---
*Requirements defined: 2026-04-14*
*Last updated: 2026-04-14 after milestone v1.1 definition*