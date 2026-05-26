# Phase 7: Remove Company Scripts - Context

**Gathered:** 2026-05-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Remove Courtsite-specific scripts from `bin/` stow package and verify no broken symlinks. Script removal is the scope — verifying content cleanup (docs, README) is Phase 8.

**Scope:**
- Delete `bin/sinar-pi-setup` and `bin/sinar-pi-wifi-setup` from source
- Verify no broken symlinks remain after removal
- Update PATH audit for `scripts/` reference
- Update courtsite-guard exclusions if needed

**Out of scope:**
- README/docs cleanup (Phase 8)
- `~/.zshrc.local` manual check (Phase 8)
- `rg -i` full repo scan (Phase 8)

</domain>

<decisions>
## Implementation Decisions

### Script Removal
- **D-01:** Delete first, verify after — remove source files, then check stow state. No unstow-before-delete needed (stow -D fails if source is already gone; stow -R re-creates from nothing)
- **D-02:** Verify with `stow -D bin && stow bin` cycle — ensures stow can cleanly remove and re-link the package
- **D-03:** Remove `$HOME/uz6r/dotfiles/scripts` from PATH (line 80) — scripts/ directory is empty after `update-migration-pr` removal, no need for stale PATH entry

### Courtsite Guard
- **D-04:** Keep `bin/` exclusion from courtsite-guard — `bin/` still has legit non-Courtsite scripts (audit-nvim-plugins, profile-zsh) that should not be caught by the guard
- **D-05:** The guard already excludes `bin/`, `README.md`, `.githooks` — these exclusions remain valid after Phase 7

### OpenCode's Discretion
- Order of `stow -D` vs `stow -R` operations
- Error output format if stow fails
- Whether to run `make test` after removal as final verification

</decisions>

<canonical_refs>
## Canonical References

### Phase Requirements
- `.planning/REQUIREMENTS.md` § SCRIPT-01, SCRIPT-02, SCRIPT-03 — script removal, symlink verification, PATH audit
- `.planning/ROADMAP.md` § Phase 7: Remove Company Scripts — goal, success criteria, dependencies

### Codebase Conventions
- `.planning/codebase/CONVENTIONS.md` § Stow — stow symlink patterns, `-D` (unlink) vs `-R` (restow) semantics
- `.planning/codebase/STRUCTURE.md` § Key Locations — `bin/` stow package, `scripts/` directory

### Files to Modify
- `bin/sinar-pi-setup` — delete (Courtsite-specific)
- `bin/sinar-pi-wifi-setup` — delete (Courtsite-specific)
- `Makefile` — update courtsite-guard to no longer skip `bin/` (scripts now clean)
- `zsh/.zshrc` line 80 — remove `$HOME/uz6r/dotfiles/scripts` PATH entry

### Files to Verify
- `~/bin/` — no broken symlinks after removal
- `describe` result from stow — verify clean state

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **`make clean`** — `stow -D zsh git nvim bin tmux` — removes all symlinks. Can use `stow -D bin` for targeted removal
- **`make status`** — checks symlink health, reports broken/ missing targets
- **`make test`** — runs all validations including `courtsite-guard`

### Established Patterns
- **Stow operations:** `stow -D <package>` (unlink), `stow <package>` (link), `stow -R` (restow)
- **Guard exclusions:** `-g '!bin'` pattern in courtsite-guard — skips specific directories

### Integration Points
- After removing scripts: `stow -D bin` will remove symlinks, `stow bin` will re-link nothing (empty source)
- `make test` includes `courtsite-guard` which currently skips `bin/` — update or keep as-is post-Phase 7

</code_context>

<specifics>
## Specific Ideas

- "Delete, then verify" — don't fuss with `stow -D` before deleting. Just delete the source files and let `stow -R bin` confirm clean state
- `scripts/` PATH entry removal — `scripts/` is empty, no reason to keep the PATH reference

</specifics>

<deferred>
## Deferred Ideas

- **Full repo scan with `rg -i`** — Phase 8 (DOC-02, DOC-03). Phase 7 only handles `bin/` cleanup
- **README.md update** — Phase 8 (DOC-01)
- **Manual `~/.zshrc.local` check** — Phase 8 (DOC-03), not in git

### Reviewed Todos (not folded)
None — no todos matched for Phase 7.

</deferred>

---
*Phase: 07-remove-company-scripts*
*Context gathered: 2026-05-26*