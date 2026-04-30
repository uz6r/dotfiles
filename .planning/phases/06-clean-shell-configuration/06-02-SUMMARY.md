---
phase: 06-clean-shell-configuration
plan: 02
subsystem: shell
tags: [courtsite, guard, makefile, pre-commit, security]

# Dependency graph
requires:
  - phase: 06-01
    provides: Cleaned .zshrc with no Courtsite references
provides:
  - Courtsite guard in Makefile (courtsite-guard target)
  - Courtsite reference blocker in pre-commit hook
affects: [all future phases - prevents Courtsite references from being reintroduced]

# Tech tracking
tech-stack:
  added: [rg (ripgrep) for Courtsite pattern matching]
  patterns: [Guard pattern - defensive check in Makefile + pre-commit hook]
  
key-files:
  created: []
  modified: [Makefile, .githooks/pre-commit]

key-decisions:
  - "D-06: Add courtsite-guard in both Makefile and pre-commit hook with rg -i pattern"
  - "Exclude guard definition files (Makefile, .githooks) from the Courtsite check to avoid self-matching"
  - "Exclude .planning/, bin/, README.md from courtsite-guard as they have separate cleanup plans"

patterns-established:
  - "Guard pattern: Add defensive checks in both Makefile test target and pre-commit hook"
  - "Use rg with --hidden and -g exclude flags for precise file matching"

requirements-completed: [SHELL-03]

# Metrics
duration: 8 min
completed: 2026-04-30
---

# Phase 6 Plan 2: Courtsite Guard Summary

**Add Courtsite guard to Makefile and pre-commit hook to prevent future Courtsite references from being introduced**

## Performance

- **Duration:** 8 min
- **Started:** 2026-04-30T08:05:11Z
- **Completed:** 2026-04-30T08:13:32Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added `courtsite-guard` target to Makefile that checks for Courtsite references using `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"`
- Integrated courtsite-guard into existing `make test` workflow
- Added Courtsite reference blocker to `.githooks/pre-commit` hook
- Properly excluded guard definition files and cleanup-targeted files from the check

## Task Commits

Each task was committed atomically:

1. **Task 1: Add courtsite-guard to Makefile and pre-commit hook** - `36353b4` (feat)
2. **Task 1 fix: Fix courtsite-guard to exclude guard definitions** - `28361f3` (fix)
3. **Task 2: Update pre-commit hook with same exclusions** - `b82c5f4` (fix)

**Plan metadata:** `pending` (docs: complete plan)

_Note: Task 2 verification was done via manual testing rather than a separate commit._

## Files Created/Modified

- `Makefile` - Added courtsite-guard target, updated test target to include courtsite-guard step
- `.githooks/pre-commit` - Added Courtsite reference blocker before formatting step

## Decisions Made

- D-06 (from context): Add courtsite-guard in both Makefile and pre-commit hook using pattern `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"`
- Exclude Makefile, .githooks, .planning/, bin/, README.md from courtsite-guard check because:
  - Guard definitions themselves contain the search pattern (self-matching issue)
  - `.planning/` files are for planning and have separate cleanup plans
  - `bin/` scripts are removed in Phase 7 (SCRIPT-01, SCRIPT-02)
  - `README.md` updates are in Phase 8 (DOC-01)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fix courtsite-guard self-matching issue**
- **Found during:** Task 2 (Verify courtsite-guard works)
- **Issue:** The `courtsite-guard` target in Makefile and the pre-commit hook both contain the search pattern `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"`, causing the guard to always fail (self-matching)
- **Fix:** Added exclusion flags to rg: `--hidden -g '!.git' -g '!.planning' -g '!Makefile' -g '!bin' -g '!README.md' -g '!.githooks'`
- **Files modified:** Makefile, .githooks/pre-commit
- **Verification:** `make courtsite-guard` passes, pre-commit hook blocks test file with Courtsite reference
- **Committed in:** `28361f3` and `b82c5f4`

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** The self-matching issue would have made the courtsite-guard unusable. Fix was essential for correctness.

## Issues Encountered

- **Pre-commit hook not triggering initially:** The `core.hooksPath` was not configured in the test environment. Fixed by running `git config core.hooksPath .githooks`. Note: The `bootstrap` target in Makefile already does this, so end users won't encounter this issue.
- **Self-matching issue:** The courtsite-guard pattern matched the guard definition itself. This is a classic "guard clause self-match" problem that required excluding the defining files.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Courtsite guard is active and preventing Courtsite references from being committed
- Ready for Phase 7 (Script Removal) - `bin/sinar-pi-setup` and `bin/sinar-pi-wifi-setup` still contain Courtsite references but are excluded from courtsite-guard (they have their own removal plan)
- After Phase 7, the courtsite-guard exclusions for `bin/` can be removed

---
*Phase: 06-clean-shell-configuration*
*Completed: 2026-04-30*

## Self-Check: PASSED

- [✅] 06-02-SUMMARY.md exists
- [✅] Commit 36353b4 found (feat: add courtsite-guard)
- [✅] Commit 28361f3 found (fix: courtsite-guard exclusions)
- [✅] Commit b82c5f4 found (fix: pre-commit hook exclusions)
- [✅] `make courtsite-guard` passes
- [✅] `make test` passes (includes courtsite-guard)
