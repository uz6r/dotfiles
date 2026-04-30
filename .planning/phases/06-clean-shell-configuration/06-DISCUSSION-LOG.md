# Phase 6: Clean Shell Configuration - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-30
**Phase:** 06-clean-shell-configuration
**Areas discussed:** Courtsite guard test, Removal timing, Commented aliases cleanup, PATH scripts/ verification, scripts/update-migration-pr

---

## Courtsite Guard Test

| Option | Description | Selected |
|--------|-------------|----------|
| Makefile test target | Add 'courtsite-guard' to Makefile that runs rg check (integrates with existing make test) | |
| pre-commit hook | Add check to .githooks/pre-commit to block commits with Courtsite references | |
| Both | Add guard in both Makefile test and pre-commit hook for defense in depth | ✓ |

**User's choice:** Both — Makefile test target + pre-commit hook

**Notes:** User wants defense in depth — automated protection in both places to prevent Courtsite references from creeping back into the dotfiles.

---

## Removal Timing (sinar-pi-setup aliases)

| Option | Description | Selected |
|--------|-------------|----------|
| Remove now | Delete aliases in Phase 6 even though scripts remain until Phase 7 | ✓ |
| Wait for Phase 7 | Keep aliases until scripts are deleted in Phase 7 | |

**User's choice:** Remove now

**Notes:** User wants complete Courtsite removal in one phase (Phase 6), even though the actual script files in bin/ won't be deleted until Phase 7.

---

## Commented Aliases Cleanup (lines 311-328)

| Option | Description | Selected |
|--------|-------------|----------|
| Delete entirely | Remove all commented aliases and TODO markers — clean slate | ✓ |
| Keep as reference | Leave commented as pattern reference for multi-repo tmux layout | |

**User's choice:** Delete entirely

**Notes:** Phase goal is removal — user chose not to keep commented code as reference. The multi-repo tmux layout pattern from `start_tmux_layout()` was also removed with the `localdev()` function.

---

## PATH scripts/ Verification (line 80)

| Option | Description | Selected |
|--------|-------------|----------|
| Keep as-is | PATH entry is valid — scripts/ has legitimate content | |
| Review scripts/ | Check if update-migration-pr or other scripts should be cleaned up | ✓ |

**User's choice:** Review scripts/

**Notes:** Led to discovery that `scripts/update-migration-pr` is also Courtsite-specific (references Courtsite-Internal/enjin repos).

---

## scripts/update-migration-pr

| Option | Description | Selected |
|--------|-------------|----------|
| Remove it now | Delete in Phase 6 — it's Courtsite-specific like everything else being removed | ✓ |
| Remove in Phase 7 | Phase 7 covers script removal — keep consistent with bin/ script removal | |
| Keep for reference | Script is deprecated but has useful patterns (infrastructure PR automation) | |

**User's choice:** Remove it now

**Notes:** Script is deprecated and Courtsite-specific — references `Courtsite-Internal/enjin` repos and `INFRA_DIR` with `$HOME/Courtsite/infrastructure` default. Removing in Phase 6 completes the cleanup scope.

---

## OpenCode's Discretion

Areas where user deferred to OpenCode:
- Order of removal operations (function first, then aliases, then comments — or vice versa)
- Exact error message text for Courtsite guard test failure
- Whether to delete `scripts/` directory entirely after removing `update-migration-pr`, or keep it for future use

---

## Deferred Ideas

- Remove scripts from `bin/` — Phase 7 (SCRIPT-01, SCRIPT-02)
- Update README.md — Phase 8 (DOC-01)
- Run `rg -i` verification — Phase 8 (DOC-02)
- Check `~/.zshrc.local` manually — Phase 8 (DOC-03)
- Git history rewriting — GIT-01, deferred until repo goes public
- Modular `.zshrc` with `conf.d/` — future requirement, deferred
