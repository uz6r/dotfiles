# Phase 8: Verify & Update Documentation - Context

**Gathered:** 2026-05-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Final verification and documentation update after all cleanup phases. Update README.md to reflect current state, fix documentation references to deleted scripts, and add verification tooling that proves the repo is clean. No code cleanup — all cleanup phases (6, 7) are complete.

**Requirements:** DOC-01, DOC-02, DOC-03

**Success criteria:**
1. User can read README.md without any Courtsite/sinar/enjin references
2. User can run `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"` with zero matches in the repository
3. User has clear instructions to check `~/.zshrc.local` manually for any remaining Courtsite references

</domain>

<decisions>
## Implementation Decisions

### README Update
- **D-01:** Full README refresh — fix both Courtsite references and generic stale content (git clone URL)
- **D-02:** Remove sinar-pi-setup and sinar-pi-wifi-setup from README directory tree (lines 97-98) — these scripts were deleted in Phase 7
- **D-03:** Remove "Some Courtsite-related aliases are being phased out" note (line 132) — all aliases were removed in Phase 6
- **D-04:** Fix git clone URL (line 68) — currently shows `yourname`, update to actual repo identifier
- **D-05:** Replace stale directory tree `bin/` and `scripts/` entries with current content

### Guard Exclusions
- **D-06:** Remove `README.md` from courtsite-guard exclusion list in Makefile (line 228) — README will be clean after update and should stay that way
- **D-07:** Remove `README.md` from pre-commit hook exclusion list — consistent with Makefile guard

### Planning Docs
- **D-08:** Update `.planning/codebase/STRUCTURE.md` directory tree — replace sinar script entries with current `bin/` contents (audit-nvim-plugins, profile-zsh), remove `scripts/` entry (directory empty after Phase 7)

### Pre-commit Hook Consistency
- **D-09:** Remove `-g '!bin'` from pre-commit hook (line 8) — matches the Makefile guard which already removed `bin/` exclusion in Phase 7. `bin/` is clean.

### Verification
- **D-10:** Add `make verify-cleanup` target to Makefile that:
  - Runs `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"` with no exclusions (full repo scan)
  - Prints instructions for manual `~/.zshrc.local` check
- **D-11:** Integrate `verify-cleanup` into `make test` workflow

### OpenCode's Discretion
- Exact wording and formatting of README changes
- Order of operations (README first, then STRUCTURE.md, then guard updates, then verify target)
- Whether to also review other sections of README for freshness during the full refresh

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase Requirements
- `.planning/REQUIREMENTS.md` § DOC-01, DOC-02, DOC-03 — README cleanup, rg verification, zshrc.local check
- `.planning/ROADMAP.md` § Phase 8 — goal, success criteria, dependencies

### Files to Modify
- `README.md` — full refresh: sinar/Courtsite refs removal, git clone URL fix, stale content cleanup
- `.planning/codebase/STRUCTURE.md` — update directory tree (lines 41-47)
- `Makefile` — remove `README.md` from guard exclusions (line 228), add `verify-cleanup` target
- `.githooks/pre-commit` — remove `-g '!bin'` (line 8), remove `-g '!README.md'` (line 8)

### Files to Preserve
- All code files (Phases 6 + 7 are complete, no code changes needed)

### Prior Context
- `.planning/phases/06-clean-shell-configuration/06-CONTEXT.md` — guard decisions, zshrc cleanup scope
- `.planning/phases/07-remove-company-scripts/07-CONTEXT.md` — script removal decisions, guard exclusion history

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **`make courtsite-guard`** (Makefile:226) — existing rg-based reference check. Pattern can be re-used for `verify-cleanup` target
- **`make test`** (Makefile:218) — existing test workflow that chains checks. `verify-cleanup` should integrate here

### Established Patterns
- **Guard exclusion pattern:** `-g '!dir'` flags in rg commands — used in both Makefile and pre-commit hook
- **Test chaining:** `make test` runs `zsh-n`, `git-config`, `nvim-config`, then `courtsite-guard` serially

### Integration Points
- `Makefile` courtsite-guard target (line 226) — remove `-g '!README.md'` from exclusion list
- `.githooks/pre-commit` (line 8) — remove both `-g '!bin'` and `-g '!README.md'` exclusions
- `make test` (line 218) — add `verify-cleanup` before or after `courtsite-guard`

</code_context>

<specifics>
## Specific Ideas

- "Full README refresh" — review the entire README for freshness, not just the Courtsite-specific lines
- `verify-cleanup` target should be self-contained: one command that proves the repo is clean of all Courtsite references AND tells the user what to check outside git

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

### Reviewed Todos (not folded)
No todos were matched for Phase 8.

</deferred>

---

*Phase: 08-verify-update-documentation*
*Context gathered: 2026-05-26*
