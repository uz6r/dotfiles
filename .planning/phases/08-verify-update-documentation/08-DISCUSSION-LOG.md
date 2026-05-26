# Phase 8: Verify & Update Documentation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-26
**Phase:** 08-verify-update-documentation
**Areas discussed:** README update scope, Guard exclusions after cleanup, Stale planning docs, Pre-commit hook drift, Verification checklist

---

## README update scope

| Option | Description | Selected |
|--------|-------------|----------|
| Courtsite-only fix | Only fix sinar/Courtsite references. Don't touch git URL. | |
| Full README refresh | Fix Courtsite refs AND git clone URL. Review for other stale content. | ✓ |

**User's choice:** Full README refresh
**Notes:** Broader scope — review entire README for freshness, not just Courtsite-specific items.

---

## Guard exclusions after cleanup

| Option | Description | Selected |
|--------|-------------|----------|
| Keep README excluded | Guard skips README so docs can reference cleanup history. | |
| Remove README exclusion | Strictest protection — README must be fully clean. | ✓ |

**User's choice:** Remove README exclusion
**Notes:** Remove from both Makefile guard and pre-commit hook.

---

## Stale planning docs

| Option | Description | Selected |
|--------|-------------|----------|
| Update STRUCTURE.md | Current architecture documentation should reflect actual state. | ✓ |
| Leave as historical context | .planning/ is excluded from guard, docs capture past state. | |

**User's choice:** Update STRUCTURE.md
**Notes:** Replace sinar entries with current bin/ contents and remove scripts/ entry.

---

## Pre-commit hook drift

| Option | Description | Selected |
|--------|-------------|----------|
| Fix pre-commit hook | Remove -g '!bin' to match Makefile guard. | ✓ |
| Leave as-is | Minor drift — not blocking. | |

**User's choice:** Fix pre-commit hook
**Notes:** Remove both `-g '!bin'` and `-g '!README.md'` exclusions from pre-commit hook.

---

## Verification checklist

| Option | Description | Selected |
|--------|-------------|----------|
| Docs verify target (Recommended) | Add `make verify-cleanup` target with full rg scan + zshrc.local instructions. | ✓ |
| Manual verification only | Run rg manually, add zshrc.local instructions to README. | |

**User's choice:** Docs verify target
**Notes:** Integrate into `make test`. Target should be self-contained (one command proves repo is clean + tells user about zshrc.local).

---

## OpenCode's Discretion

- Exact wording and formatting of README changes
- Order of operations (README first, then STRUCTURE.md, then guard updates, then verify target)
- Whether to also review other sections of README for freshness during the full refresh

## Deferred Ideas

None — discussion stayed within phase scope.
