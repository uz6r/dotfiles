# Phase 6: Clean Shell Configuration - Context

**Gathered:** 2026-04-30
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase removes all Courtsite/company-specific configuration from `.zshrc` while preserving cross-platform detection logic. The scope is limited to shell configuration cleanup — script removal happens in Phase 7, documentation update in Phase 8.

**Goal:** User can use dotfiles with zero Courtsite references in .zshrc while preserving cross-platform detection

**In scope:**
- Remove `localdev()` function and nested `start_tmux_layout()` (lines 153-184)
- Delete commented Courtsite aliases and TODO markers (lines 311-328)
- Remove active sinar-pi-setup and sinar-pi-wifi-setup aliases (lines 321-322)
- Remove `scripts/update-migration-pr` (Courtsite-specific)
- Add Courtsite guard test (Makefile + pre-commit hook)
- Verify PATH configuration (line 80 `$HOME/uz6r/dotfiles/scripts` reference)

**Out of scope:**
- Removing scripts from `bin/` (Phase 7: SCRIPT-01, SCRIPT-02)
- Documentation updates (Phase 8: DOC-01, DOC-02)
- Git history rewriting (GIT-01: deferred)

</domain>

<decisions>
## Implementation Decisions

### Removal Scope
- **D-01:** Remove `localdev()` function and `start_tmux_layout()` from `.zshrc` — function is Courtsite-specific and no longer needed
- **D-02:** Delete all commented Courtsite aliases (lines 311-328) entirely — not keeping as reference patterns
- **D-03:** Remove active sinar-pi-setup and sinar-pi-wifi-setup aliases from `.zshrc` in Phase 6 (not waiting for Phase 7 script deletion)
- **D-04:** Remove `scripts/update-migration-pr` file — confirmed Courtsite-specific (references Courtsite-Internal/enjin repos, infrastructure)

### PATH Configuration
- **D-05:** Keep `$HOME/uz6r/dotfiles/scripts` in PATH (line 80) — after removing `update-migration-pr`, the `scripts/` directory will be empty but the PATH entry is valid for future utility scripts

### Courtsite Guard Test
- **D-06:** Add Courtsite guard in **both** Makefile and pre-commit hook:
  - **Makefile:** Add `courtsite-guard` test target that runs `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"` and fails if matches found
  - **Pre-commit hook:** Block commits containing Courtsite references
  - Integrates with existing `make test` workflow

### Preservation Requirements
- **D-07:** Preserve cross-platform detection logic (lines 36-77) — `is_darwin()`, `is_linux()`, and `case "$(uname -s)"` block must remain
- **D-08:** Preserve Homebrew PATH configuration (lines 60-77) — works on both macOS and Linux

### OpenCode's Discretion
- Order of removal operations (function first, then aliases, then comments — or vice versa)
- Exact error message text for Courtsite guard test failure
- Whether to delete `scripts/` directory entirely after removing `update-migration-pr`, or keep it for future use

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase Requirements
- `.planning/REQUIREMENTS.md` § SHELL-01 through SHELL-04 — shell configuration cleanup requirements
- `.planning/ROADMAP.md` § Phase 6: Clean Shell Configuration — goal, success criteria, dependencies

### Codebase Conventions
- `.planning/codebase/CONVENTIONS.md` § Zsh Configuration — shell script patterns, commenting style, function definitions
- `.planning/codebase/STRUCTURE.md` § Key Locations — `.zshrc` location, `scripts/` directory purpose

### Files to Modify
- `zsh/.zshrc` — main shell config (415 lines, target of cleanup)
- `scripts/update-migration-pr` — Courtsite-specific script to delete
- `Makefile` — add courtsite-guard test target
- `.githooks/pre-commit` — add Courtsite reference blocker

### Files to Preserve (DO NOT MODIFY)
- `zsh/.zshrc` lines 36-77 — cross-platform detection logic
- `zsh/.zshrc` lines 60-77 — Homebrew PATH configuration
- `zsh/.zshrc` lines 408-413 — local overrides and opencode PATH

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Cross-platform detection pattern:** `case "$(uname -s)"` with `is_darwin()` and `is_linux()` helper functions — established pattern to preserve
- **Conditional aliases pattern:** `if is_darwin; then ... else ... fi` — used for platform-specific aliases, can be reused for future platform differences
- **Local overrides:** `.zshrc.local` sourcing at line 411-413 — machine-specific configs kept separate

### Established Patterns
- **Commenting:** `# descriptive comment` style (line 33, 52, 82, etc.)
- **Function definition:** `function_name() { ... }` style (lines 49-50, 137, 143, etc.)
- **Boolean exports:** `export IS_MACOS=false` / `export IS_LINUX=false` (lines 37-38)
- **Optional loading:** `if command -v X >/dev/null 2>&1; then ... fi` pattern (lines 69, 201, 211, 381)

### Integration Points
- **PATH configuration:** Line 80 adds `$HOME/uz6r/dotfiles/scripts` — after cleanup, `scripts/` directory will be empty but PATH entry remains valid
- **oh-my-zsh plugins:** Lines 22-29 load git, sudo, web-search, copyfile, copybuffer, dirhistory — not Courtsite-related, preserve
- **Powerlevel10k:** Lines 19, 347-348 — theme configuration, preserve
- **Optional plugins:** Lines 351-376 — autosuggestions, syntax-highlighting, fzf, nvm — conditional loading pattern, preserve

</code_context>

<specifics>
## Specific Ideas

- **Courtsite guard test pattern:** Use `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"` — case-insensitive search for all variants
- **Multi-repo tmux layout:** The `start_tmux_layout()` function (lines 164-175) shows a pattern for multi-repo development — user chose NOT to keep as reference, but the pattern itself (tmux split-window with multiple directories) could be useful for future non-Courtsite projects
- **Guard test integration:** Add `courtsite-guard` as a new test in existing `make test` target alongside current zsh/git/nvim validation

</specifics>

<deferred>
## Deferred Ideas

- **Remove scripts from `bin/`** — Phase 7 (SCRIPT-01, SCRIPT-02)
- **Update README.md to remove sinar script mentions** — Phase 8 (DOC-01)
- **Run `rg -i` verification for remaining references** — Phase 8 (DOC-02)
- **Check `~/.zshrc.local` manually** — Phase 8 (DOC-03), not in git
- **Git history rewriting with git-filter-repo** — GIT-01, deferred until repo goes public
- **Delete `scripts/` directory** — not explicitly requested; directory kept for future utility scripts after `update-migration-pr` removal
- **Modular `.zshrc` with `conf.d/` directory structure** — listed in Future Requirements, deferred

### Reviewed Todos (not folded)
None — no todos were matched for Phase 6.

</deferred>

---
*Phase: 06-clean-shell-configuration*
*Context gathered: 2026-04-30*
