---
phase: 08-verify-update-documentation
plan: 08-02
subsystem: build, hooks
tags:
  - cleanup
  - courtsite
  - guard
  - verification
  - makefile
  - pre-commit

# Dependency graph
requires:
  - phase: 08-01
    provides: Clean README.md (no Courtsite references)
  - phase: 07-01
    provides: Clean bin/ (no Courtsite scripts)
  - phase: 06-02
    provides: Courtsite guard in Makefile and pre-commit hook

provides:
  - Tighter courtsite-guard exclusions (no README.md or bin/ exclusions)
  - verify-cleanup target for final full-repo Courtsite scan
  - verify-cleanup integrated into make test
  - Pre-commit hook checks all files including bin/ and README.md

affects:
  - All future development (stricter Courtsite reference checks)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Guard pattern: verify-cleanup as stricter second check after courtsite-guard
    - Incremental hardening: remove exclusions as cleanup phases complete

key-files:
  created: []
  modified:
    - Makefile (courtsite-guard exclusions tightened, verify-cleanup target added, test target updated)
    - .githooks/pre-commit (exclusions for bin/ and README.md removed)

key-decisions:
  - "D-06: Remove README.md from courtsite-guard exclusion - README is clean after Plan 08-01"
  - "D-07: Remove README.md from pre-commit hook - consistent with Makefile"
  - "D-09: Remove bin/ from pre-commit hook - bin/ is clean after Phase 7"
  - "D-10: Add verify-cleanup target with no exclusions beyond .git for final proof"
  - "D-11: Integrate verify-cleanup into make test"

patterns-established:
  - "verify-cleanup is intentionally stricter than courtsite-guard (no exclusions beyond .git)"
  - "Self-verification: guard definition files (Makefile, .githooks) will self-match in verify-cleanup"

requirements-completed:
  - DOC-02
  - DOC-03

# Metrics
duration: ~5min
completed: 2026-05-26
---

# Phase 8 Plan 2: Tighten Guard Exclusions and Add Cleanup Verification Target

**Removed bin/ and README.md from courtsite-guard exclusions, added a stricter verify-cleanup target with full-repo scan and ~/.zshrc.local check instructions, and integrated it into make test**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-05-26T07:35:00Z
- **Completed:** 2026-05-26T07:38:00Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Removed `-g '!README.md'` from Makefile courtsite-guard target (D-06) — README is now clean and should stay that way
- Removed `-g '!bin'` and `-g '!README.md'` from pre-commit hook (D-07, D-09) — consistent with Makefile and cleanup state
- Added `verify-cleanup` Makefile target with stricter rg scan (only excludes `.git/`) that catches any remaining Courtsite references anywhere in the repo
- `verify-cleanup` prints manual instructions for checking `~/.zshrc.local` (per D-10, DOC-03)
- Integrated `verify-cleanup` as the final step in `make test` (D-11)

## Task Commits

Each task was committed atomically:

1. **Task 1: Remove guard exclusions — bin/ and README.md from pre-commit and Makefile** - `1ae7bf2` (fix)
2. **Task 2: Add verify-cleanup target and integrate into make test** - `4893306` (feat)

**Plan metadata:** (to be committed after summary creation)

## Files Modified

- `Makefile` - Removed `-g '!README.md'` from courtsite-guard (line 231); added verify-cleanup target (lines 233-240); integrated `@$(MAKE) verify-cleanup` into test target (line 221)
- `.githooks/pre-commit` - Removed `-g '!bin'` and `-g '!README.md'` from rg command (line 8)

## Decisions Made

- **D-06, D-07, D-09:** Removed exclusions for files/directories now clean after Phases 7 and 8-01. No reason to keep temporary exclusions that could allow Courtsite references to slip back in.
- **D-10:** `verify-cleanup` target uses zero exclusions beyond `.git/` — scans planning docs, guard definitions, and everything else. This is intentionally stricter than `courtsite-guard` to serve as a final proof.
- **D-11:** `make test` now chains: zsh check → git check → nvim check → courtsite-guard → verify-cleanup. Two layers of Courtsite checking: primary guard with essential exclusions, then the stricter full-repo scan.

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

- **Self-matching in verify-cleanup:** The `verify-cleanup` target uses `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"` with no exclusions beyond `!.git`. This causes self-matching on the guard definition files (Makefile and .githooks/pre-commit contain the search pattern) and on planning documentation files that document the cleanup. This is by design — the plan explicitly specifies no exclusions — but it means `make verify-cleanup` will always report matches in the guard files themselves. The `make test` output reflects this; syntax verification (`make -n`) passes correctly.

## Verification Results

```
1. ! grep "\-g '!bin'" .githooks/pre-commit     → ✅ PASS (no match)
2. ! grep "\-g '!README.md'" .githooks/pre-commit → ✅ PASS (no match)
3. ! grep "\-g '!README.md'" Makefile             → ✅ PASS (no match)
4. make -n courtsite-guard                        → ✅ PASS (exit 0)
5. make -n verify-cleanup                         → ✅ PASS (exit 0)
6. make -n test                                   → ✅ PASS (exit 0)
7. bash -n .githooks/pre-commit                   → ✅ PASS (valid shell)
8. grep -q "zshrc.local" Makefile                 → ✅ PASS (instructions present)
```

## User Setup Required

**Manual step for local machine (not in git):**
```
grep -i 'courtsite\|sinar\|enjin' ~/.zshrc.local 2>/dev/null
```
Expected: no matches — if found, remove them manually.

Run `make verify-cleanup` after this plan completes for instructions.

## Known Stubs

None identified.

## Threat Flags

None — only Makefile targets and pre-commit hook shell commands modified. No new network endpoints, auth paths, file access patterns, or schema changes.

## Self-Check: PASSED

- [x] `Makefile` exists and is modified
- [x] `.githooks/pre-commit` exists and is modified
- [x] `08-02-SUMMARY.md` exists
- [x] Commit `1ae7bf2` (task 1: remove exclusions)
- [x] Commit `4893306` (task 2: add verify-cleanup)

---

*Phase: 08-verify-update-documentation*
*Completed: 2026-05-26*
