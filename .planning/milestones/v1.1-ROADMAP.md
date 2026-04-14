# Roadmap: Dotfiles Shell Optimization

**Phases:** 3 | **Requirements:** 10 | **Created:** 2026-04-14

## Phase 3: Shell Profiling

**Goal:** Create shell startup profiling to identify slow loads

### Requirements (3)
- PROF-01: zsh startup timing script
- PROF-02: Profiler identifies slow plugins/sources
- PROF-03: Profiler outputs actionable suggestions

### Success Criteria
1. `zsh -x -i -c exit 2>&1 | tail -20` captures timing data
2. Script can identify top 5 slowest components
3. Output clearly shows which plugins/sources are slowest

---

## Phase 4: Neovim Plugin Audit

**Goal:** Audit neovim plugins to find unused ones

### Requirements (3)
- NVIM-01: Script analyzes Neovim plugin usage
- NVIM-02: Identify plugins loaded but not used
- NVIM-03: Provide recommendations for removal

### Success Criteria
1. Script reads Neovim lazy.nvim state JSON
2. Identifies plugins with no :h calls, no keybindings, no autocmds
3. Outputs list of candidates for removal

---

## Phase 5: Automated Tests

**Goal:** Add automated test suite for dotfiles validation

### Requirements (4)
- TEST-01: zsh syntax validation
- TEST-02: Neovim config validation
- TEST-03: Git config validation
- TEST-04: Makefile test target

### Success Criteria
1. `make test` runs all validations
2. `zsh -n` passes for all .zshrc files
3. `nvim --headless +qa` exits without error
4. Git config parses correctly

---

## Phase Summary

| Phase | Goal | Requirements | Success Criteria |
|-------|------|--------------|-------------------|
| 3 | Shell Profiling | 3/3 ✓ | 2026-04-14 |
| 4 | Neovim Audit | 3/3 ✓ | 2026-04-14 |
| 5 | Automated Tests | 4/4 ✓ | 2026-04-14 |

---

## Milestone: v1.1 Shell Optimization ✓

**Status:** Complete (2026-04-14)

**Done means:**
- Shell startup profiling script identifies slow components
- Neovim plugin audit identifies unused plugins
- Automated tests validate all dotfiles configs
- All tests run via `make test`

---

## Future Improvements

- Lazy-load non-critical plugins based on profiling
- Cross-platform validation (if Mac available)
- Test stow symlink creation

---

*Roadmap created: 2026-04-14 | Updated: 2026-04-14*