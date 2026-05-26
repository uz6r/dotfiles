---
phase: 09-comprehensive-audit-sanitization
plan: 02
subsystem: tooling, security
tags: [audit, secrets, binaries, macos-compat, precommit, makefile]

# Dependency graph
requires:
  - phase: 09-01
    provides: initial remediation, .gitignore patterns, gitleaks setup
provides:
  - 4 dual-mode audit scripts (REPORT/STRICT) for secrets, binaries, hardcoded paths, stale configs
  - make sanitize enforcement target (STRICT mode, exit 1 on findings)
  - Extended pre-commit hook with binary detection and secret scanning
  - 4 macOS compatibility fixes (duh alias, readlink, grep -oP, date +%s%N)
  - bin/verify-macos static analysis for GNU-only patterns
  - make macos-check wrapper target
  - zsh/.zshrc.local.example template for machine-specific overrides
affects: [09-03, future maintenance, macOS cross-platform testing]

# Tech tracking
tech-stack:
  added: [rg-based pattern scanning, cross-platform timing via perl]
  patterns: [dual-mode audit scripts (REPORT/STRICT), pre-commit as fast security gate]

key-files:
  created:
    - bin/audit-secrets: Dual-mode secret scanner (psk, API keys, tokens, SSH keys)
    - bin/audit-binaries: Dual-mode binary detector (respects .gitignore)
    - bin/audit-hardcoded: Dual-mode hardcoded path/IP/email scanner
    - bin/audit-stale: Dual-mode stale config/empty dir finder
    - bin/verify-macos: Static analysis for GNU-only patterns (106 lines, 9+ checks)
    - zsh/.zshrc.local.example: 23-line local override template
  modified:
    - .githooks/pre-commit: Extended to 4 sections (+binary detection, +secret scanning)
    - Makefile: Added audit, sanitize, macos-check targets (~40 lines added)
    - zsh/.zshrc: duh alias platform guard (BSD -d 1 / GNU -d 1)
    - bin/audit-nvim-plugins: grep -oP → grep -oE (portable)
    - bin/profile-zsh: date +%s%N → perl/cross-platform timing

key-decisions:
  - "audit-binaries uses git ls-files (respects .gitignore) instead of bare find to avoid flagging gitignored binaries"
  - "verify-macos uses REPORT mode (exits 0) by default, not blocking — advisory static analysis per R-02"
  - "Pre-commit hook checks staged files with fast regex (not full gitleaks) to keep latency under 2 seconds"

patterns-established:
  - "Dual-mode scripts: REPORT prints findings exits 0, STRICT exits 1 on any finding"
  - "Pre-commit as fast gate: binary detection + secret regex on staged files only; full audit in CI"
  - "Makefile target semantics: audit-* use || true (non-blocking), sanitize uses direct calls (blocking)"

requirements-completed:
  - SANI-06
  - SANI-07
  - SANI-08
  - MACO-01
  - MACO-02
  - MACO-03
  - MACO-04
  - MACO-05
  - MACO-06
  - MAIN-03

# Metrics
duration: 67min
completed: 2026-05-26
---

# Phase 09 Plan 02: Audit Tooling, Enforcement & macOS Compatibility Summary

**4 dual-mode audit scripts (secrets, binaries, hardcoded paths, stale configs) + make sanitize enforcement + extended pre-commit hook + 4 macOS compat fixes + bin/verify-macos static analyzer + .zshrc.local.example template**

## Performance

- **Duration:** 67 min
- **Started:** 2026-05-26T07:35:00Z
- **Completed:** 2026-05-26T08:42:00Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments

- **4 dual-mode audit scripts created** — bin/audit-secrets (6 pattern categories: SSH keys, WiFi PSK, API keys, GitHub tokens, OpenAI keys, AWS keys), bin/audit-binaries (ELF/Mach-O detection + large file check, respects .gitignore), bin/audit-hardcoded (/home/* paths, internal IPs, emails), bin/audit-stale (empty dirs, non-stow directories)
- **make sanitize enforcement** — STRICT mode chaining audit-secrets, audit-binaries, audit-hardcoded. Exits 1 on any finding. Verified clean.
- **Pre-commit hook extended** — binary detection (file type check on staged files) and secret scanning (fast regex on staged files) added as sections 2 and 3, preserving existing Courtsite (section 1) and format check (section 4)
- **4 macOS incompatibilities fixed** — duh alias platform guard (zsh/.zshrc), readlink greadlink fallback (Makefile), grep -oP → grep -oE (bin/audit-nvim-plugins), date +%s%N → perl fallback (bin/profile-zsh)
- **bin/verify-macos created** — 106-line static analyzer checking 9+ patterns (grep -oP, readlink -f, date +%s%N, du --max-depth, stat -c, sed -i, sort -h, /home/ paths, apt-get)
- **make macos-check target** — wraps bin/verify-macos as advisory check
- **zsh/.zshrc.local.example** — 23-line template documenting the local override pattern

## Task Commits

Each task was committed atomically:

1. **task 1: Create bin/audit-* scripts, add make targets (audit, sanitize), extend pre-commit hook** - `e251097` (feat)
2. **task 2: Fix macOS incompatibilities, create verify-macos, macos-check, .zshrc.local.example** - `d383ee6` (feat)

## Files Created/Modified

- `bin/audit-secrets` — 56-line dual-mode secret scanner, 6 pattern categories, `.githooks`/`Makefile` exclusion
- `bin/audit-binaries` — 47-line dual-mode binary detector, respects `.gitignore` via `git ls-files`
- `bin/audit-hardcoded` — 34-line dual-mode hardcoded path/IP/email scanner
- `bin/audit-stale` — 38-line dual-mode stale config finder (empty dirs, non-stow dirs)
- `bin/verify-macos` — 106-line static analyzer for 9 GNU-only pattern categories
- `zsh/.zshrc.local.example` — 23-line local override template
- `.githooks/pre-commit` — Extended from 24 lines to 40+ lines with 4 check sections
- `Makefile` — Added audit, audit-secrets, audit-binaries, audit-hardcoded, audit-stale, sanitize, macos-check targets
- `zsh/.zshrc` — duh alias now has platform guard (BSD -d 1 / GNU -d 1)
- `bin/audit-nvim-plugins` — grep -oP → portable grep -oE
- `bin/profile-zsh` — date +%s%N → cross-platform perl/date fallback

## Decisions Made

- **audit-binaries uses `git ls-files`** instead of bare `find` — respects `.gitignore` so gitignored files (like `lazygit`) don't cause false positives in strict mode
- **verify-macos uses REPORT mode (exits 0)** — advisory static analysis per R-02 (no macOS runner available); flags potential issues but doesn't block
- **Pre-commit keeps fast checks only** — regex scan on staged files (< 2s), not full gitleaks or audit scripts; full audit runs via `make sanitize` in CI
- **audit-secrets excludes `.githooks/`** — pre-commit hook contains regex patterns that match secret-like strings; hook is the enforcement layer, not a source of secrets

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed unbound variable in audit-secrets scan() function**
- **Found during:** task 1 (script creation)
- **Issue:** `scan()` function declared 3 parameters (`$1`, `$2`, `$3`) but was called with only 2. With `set -euo pipefail`, referencing unset `$3` caused fatal error
- **Fix:** Removed unused 3rd parameter; rewrote scan to use `rg -l | wc -l || true` instead of `rg -c | wc -l || echo 0` (pipefail double-count bug)
- **Files modified:** `bin/audit-secrets`
- **Verification:** `make audit-secrets` and `make sanitize` both work correctly
- **Committed in:** `e251097` (task 1 commit)

**2. [Rule 1 - Bug] audit-binaries false positives on shell scripts**
- **Found during:** task 1 (script creation)
- **Issue:** `file` command returns "Bourne-Again shell script, ... executable" for shell scripts, matching the "executable" pattern
- **Fix:** Added `&& ! echo "$filetype" | grep -qi 'shell script'` filter; switched from `find` to `git ls-files` to respect `.gitignore`
- **Files modified:** `bin/audit-binaries`
- **Verification:** `make sanitize` no longer flags shell scripts as binaries
- **Committed in:** `e251097` (task 1 commit)

**3. [Rule 1 - Bug] audit-secrets flagged pre-commit hook's own regex patterns**
- **Found during:** task 1 (verification)
- **Issue:** audit-secrets matched `psk=.*` pattern inside pre-commit hook's secret scan regex; hook is the enforcement layer not a source of secrets
- **Fix:** Added `.githooks/` and `Makefile` to audit-secrets exclusion list
- **Files modified:** `bin/audit-secrets`
- **Verification:** `make sanitize` no longer fails on hook's own regex patterns
- **Committed in:** `e251097` (task 1 commit)

**4. [Rule 1 - Bug] audit-hardcoded flagged intentional emails in .gitconfig and README**
- **Found during:** task 1 (verification)
- **Issue:** Email regex caught `uzairzahari@yahoo.com` in `.gitconfig` and `git@github.com:uz6r/dotfiles.git` in README.md — both intentional public info
- **Fix:** Added `-g !*.gitconfig -g !*.md` exclusions to email pattern check
- **Files modified:** `bin/audit-hardcoded`
- **Verification:** `make sanitize` no longer flags intentional emails
- **Committed in:** `e251097` (task 1 commit)

**5. [Rule 1 - Bug] audit-hardcoded flagged placeholder email in .zshrc.local.example**
- **Found during:** task 2 (verification)
- **Issue:** Template contains `export GIT_AUTHOR_EMAIL="you@example.com"` as example — intentional placeholder, not real data
- **Fix:** Added `-g !*.example` exclusion to email pattern check
- **Files modified:** `bin/audit-hardcoded`
- **Verification:** `make sanitize` passes with .zshrc.local.example present
- **Committed in:** `d383ee6` (task 2 commit)

---

**Total deviations:** 5 auto-fixed (Rule 1 — all bugs in plan code)
**Impact on plan:** All fixes necessary for correct script behavior. No scope creep — scripts now work correctly with clean repo state.

## Issues Encountered

- **`set -o pipefail` interaction with `||` fallbacks:** Shell pipeline with `set -euo pipefail` causes `wc -l || echo 0` to double-count when `rg` exits non-zero (no matches). Switched to `rg -l | wc -l || true` pattern and `rg -c '.*'` line counting for robustness.
- **`make sanitize` failing on lazygit binary:** The lazygit binary file exists on disk but is `.gitignore`-d. Original `find`-based binary scanner found it anyway. Switched to `git ls-files` which respects `.gitignore`, making the scan accurate for tracked/untracked-non-ignored files.
- **`date` command parsing in this shell:** Different `date` behavior across timezones — used `date -ud` for UTC parsing.

## Known Stubs

None — all created files have substantive implementations.

## Threat Surface Scan

No new threat surfaces beyond those documented in the plan's threat model:
- Pre-commit binary/secret scanning (T-09-05): mitigated
- audit-secrets dual-mode (T-09-06): mitigated with exclusions
- audit-hardcoded exclusions (T-09-07): mitigated
- verify-macos advisory-only (T-09-08): accepted
- Makefile audit vs sanitize semantics (T-09-09): mitigated

## User Setup Required

None — all changes are self-contained within the dotfiles repo.

## Next Phase Readiness

- **make audit** provides comprehensive repo inspection
- **make sanitize** enforces zero-tolerance gate
- **make macos-check** provides cross-platform advisory
- **Pre-commit** blocks secrets, binaries, and Courtsite references
- **macOS compat fixes** make duh, Makefile status, audit-nvim-plugins, and profile-zsh work on macOS
- All requirements (SANI-06/07/08, MACO-01/02/03/04/05/06, MAIN-03) completed
- Phase 09-03 ready to build on this tooling foundation

## Self-Check: PASSED

- All 6 created files exist
- Both commits verified (e251097, d383ee6)
- All 10 acceptance criteria pass
- SUMMARY.md written to plan directory

---

*Phase: 09-comprehensive-audit-sanitization*
*Completed: 2026-05-26*
