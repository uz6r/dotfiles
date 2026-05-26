# Phase 7: Remove Company Scripts - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-26
**Phase:** 07-remove-company-scripts
**Areas discussed:** Script removal order, Verification method, Guard update, PATH audit

---

## Script Removal Order

| Option | Description | Selected |
|--------|-------------|----------|
| Unstow, then delete | Run `stow -D bin` first to remove symlinks, then delete source files | |
| Delete, then verify | Delete files from bin/ first, then verify no broken symlinks remain | ✓ |

**User's choice:** Delete, then verify
**Notes:** Simpler approach — stow -D isn't needed if files don't exist on disk

---

## Verification Method

| Option | Description | Selected |
|--------|-------------|----------|
| `ls -la ~/bin/` check | Simple check for broken symlinks | |
| `stow -D + stow bin` cycle | Stow cleanly removes and re-links the package | ✓ |
| Both | Run both for thorough verification | |

**User's choice:** `stow -D bin && stow bin` cycle
**Notes:** Verifies stow state is healthy after removal

---

## Guard Update

| Option | Description | Selected |
|--------|-------------|----------|
| Remove `bin/` exclusion | Remove `-g '!bin'` from courtsite-guard rule | |
| Keep `bin/` exclusion | `bin/` still has legit non-Courtsite scripts | ✓ |

**User's choice:** Keep `bin/` exclusion
**Notes:** bin/ still has audit-nvim-plugins and profile-zsh — legit scripts that should stay

---

## PATH / Scripts Audit

| Option | Description | Selected |
|--------|-------------|----------|
| Keep PATH entry | Keep `$HOME/uz6r/dotfiles/scripts` in PATH | |
| Audit only, keep as-is | Document line 80 is fine, scripts/ exists | |
| Remove PATH entry | Remove since scripts/ is empty | ✓ |

**User's choice:** Remove PATH entry
**Notes:** scripts/ is empty after `update-migration-pr` deletion

## OpenCode's Discretion

- Order of `stow -D` vs `stow -R` operations
- Error output formatting if stow fails
- Whether to run `make test` after removal

## Deferred Ideas

- Full repo `rg -i` scan — Phase 8
- README.md update — Phase 8
- Manual `~/.zshrc.local` CourtSite check — Phase 8