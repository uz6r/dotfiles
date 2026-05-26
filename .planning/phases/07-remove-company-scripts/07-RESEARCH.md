# Phase 7: Remove Company Scripts - Research

**Completed:** 2026-05-26
**Status:** Complete

## Symlink Verification & Stow State

| Option | Pros | Cons | Complexity | Recommendation |
|--------|------|------|------------|----------------|
| `stow -D bin && stow bin` cycle | Verifies clean state; integrated with `make clean` pattern | Needs stow installed | 2 commands | ✓ Recommended |
| `make status` | Already implemented (checks `bin/*` → `~/.<name>` targets) | Not a live check | 0 new code | ✓ Final validation |
| `ls -la ~/bin/` | Visual confirmation | Subjective | Manual | ⚠ After stow cycle |

**Primary verification:** `stow -D bin` (remove all `bin/` symlinks), then `stow bin` (re-link — nothing to link since source is empty). Then `make status` to confirm no broken targets.

**Final path:** After both `stow -D bin && stow bin` and `make status` pass, no further verification needed.

## Files to Modify

- `bin/sinar-pi-setup` — delete (Courtsite-specific)
- `bin/sinar-pi-wifi-setup` — delete (Courtsite-specific)
- `zsh/.zshrc` line 80 — remove `$HOME/uz6r/dotfiles/scripts` from PATH
- `Makefile` — update `courtsite-guard` to no longer skip `bin/` (now clean)

## Files to Verify

- `~/bin/` — no broken symlinks after removal
- `stow -D bin && stow bin` — stow clean state
- `make status` — `~/bin/` targets all healthy