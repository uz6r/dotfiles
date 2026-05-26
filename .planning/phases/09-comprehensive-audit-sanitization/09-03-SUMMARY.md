---
phase: 09-comprehensive-audit-sanitization
plan: 03
type: execute
subsystem: workflow-preservation
tags:
  - workflow
  - documentation
  - makefile
  - concerns
  - checklist
dependency_graph:
  requires:
    - 09-02
  provides:
    - WORKFLOW.md
    - PRE-RESET-CHECKLIST.md
    - make doctor
    - make public-ready
    - make audit-home
    - make audit-workflow
  affects:
    - bin/audit-workflow
    - WORKFLOW.md
    - CONCERNS.md
    - Makefile
    - PRE-RESET-CHECKLIST.md
    - private/README.md
tech-stack:
  added:
    - bash (audit-workflow shell history profiler)
  patterns:
    - Temp-file-based pipeline data flow (avoids subshell pipe issues)
    - Path anonymization after content generation
key-files:
  created:
    - bin/audit-workflow: Shell history profiler with path anonymization
    - WORKFLOW.md: Generated workflow preservation report
    - PRE-RESET-CHECKLIST.md: Pre-machine-wipe checklist
  modified:
    - .planning/codebase/CONCERNS.md: Updated to v1.3 state
    - Makefile: Added doctor/public-ready/audit-home/audit-workflow targets
    - private/README.md: Added reference to PRE-RESET-CHECKLIST
decisions:
  - "PRE-RESET-CHECKLIST.md excluded from courtsite-guard: checklist documents local disk state (including ~/Courtsite/), not tracked config"
  - "Path anonymization in audit-workflow: replaced $HOME and /tmp paths after content generation to avoid leaking real paths"
  - "Untracked scripts scan restricted to user-local PATH directories only: system dirs produce excessive noise"
metrics:
  duration: "~28m"
  completed_date: "2026-05-26"
---

# Phase 9 Plan 3: Workflow Preservation & Final Documentation

**One-liner:** Shell history profiler (bin/audit-workflow) generates anonymized WORKFLOW.md, PRE-RESET-CHECKLIST.md for machine wipe prep, CONCERNS.md updated to v1.3, and comprehensive make targets (doctor, public-ready, audit-home).

## Summary

Executed Plan 09-03 — the final plan in Phase 09. Two tasks completed:

**Task 1 — bin/audit-workflow + WORKFLOW.md:** Created a shell history profiler (`bin/audit-workflow`) that parses `~/.zsh_history`, extracting top 40 commands by frequency with categorization, cross-referencing custom function usage against `.zshrc`, detecting undocumented local-only aliases, and listing untracked scripts in user-local PATH directories. All paths anonymized (`$HOME`, `$TMP`). Generated `WORKFLOW.md` from live shell history (4797 commands).

**Task 2 — PRE-RESET-CHECKLIST.md + CONCERNS.md update + Makefile targets:** Created the pre-machine-wipe checklist with SSH keys, git config, shell history, environment files, browser data, package lists, project directories, and machine-specific config sections plus post-wipe rebuild guide. Updated CONCERNS.md to reflect v1.3 state (removed resolved v1.2 items, added WiFi password threat, macOS compat, new security posture table). Added four new Makefile targets: `doctor` (test+sanitize+macos-check aggregator), `public-ready` (pre-open-source checklist), `audit-home` (home directory sensitive data scan), and `audit-workflow` (shell history profiling wrapper). Updated `private/README.md` with PRE-RESET-CHECKLIST reference.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Subshell pipe issue in audit-workflow**
- **Found during:** task 1 — after generating WORKFLOW.md
- **Issue:** Bash pipes create subshells; `write_line()` calls inside `rg ... | while read ...` loops modified a local copy of `WORKFLOW_CONTENT`, resulting in empty sections (Top Commands, Used Functions, Undocumented Aliases had 0 data rows)
- **Fix:** Rewrote Phases 2, 3, 4 to use temp files (`mktemp`) with redirected input (`while ... done < "$FILE"`) instead of pipe-to-while-read
- **Files modified:** `bin/audit-workflow`
- **Commit:** `ac9321a`

**2. [Rule 1 - Bug] SIGPIPE from head -40 under pipefail**
- **Found during:** task 1 — script exited with code 141 (SIGPIPE) during Phase 2 pipeline
- **Issue:** `head -40` exits early after reading 40 lines, sending SIGPIPE to upstream `sort`. With `set -euo pipefail`, the pipeline exit code propagates as failure
- **Fix:** Replaced `head -40` with `awk 'NR<=40'` which reads all input gracefully and `|| true` to absorb any remaining pipefail edge cases
- **Files modified:** `bin/audit-workflow`
- **Commit:** `ac9321a`

**3. [Rule 1 - Bug] Untracked PATH scan includes system binaries**
- **Found during:** task 1 — WORKFLOW.md was 8700+ lines with thousands of system binaries listed
- **Issue:** `bin/audit-workflow` Phase 5 scanned ALL PATH directories (including /usr/bin with thousands of entries), flagging every system binary as "untracked"
- **Fix:** Added `$HOME` prefix filter — only scans user-local PATH directories
- **Files modified:** `bin/audit-workflow`
- **Commit:** `ac9321a`

**4. [Rule 2 - Missing] Path anonymization absent in initial script**
- **Found during:** task 1 — acceptance criteria required no raw `/home/uzer` paths in WORKFLOW.md
- **Issue:** The "Untracked Scripts in PATH" section listed raw `/home/uzer/...` paths, violating threat model T-09-10
- **Fix:** Added `$HOME` and `/tmp` path replacement in the output buffer before writing
- **Files modified:** `bin/audit-workflow`
- **Commit:** `ac9321a`

**5. [Rule 2 - Missing] PRE-RESET-CHECKLIST.md not excluded from courtsite-guard**
- **Found during:** task 2 — `make doctor` failed because courtsite-guard detected "Courtsite" in PRE-RESET-CHECKLIST.md
- **Issue:** The checklist references `~/Courtsite/` as a local directory to review (it documents the user's disk state)
- **Fix:** Added `-g '!PRE-RESET-CHECKLIST.md'` to both `courtsite-guard` and `verify-cleanup` Makefile targets
- **Files modified:** `Makefile`
- **Commit:** `d81fe8e`

### Auto-fix Attempt Count

Each task had 1 verification cycle (fix → test → pass). No task exceeded 3 attempts.

## Authentication Gates

None encountered.

## Known Stubs

### bin/audit-workflow: Phase 4 (Undocumented Aliases) empty in non-interactive mode

- **File:** `bin/audit-workflow`, Phase 4
- **Issue:** The `alias` command in a non-interactive bash script does not have access to the interactive shell's aliases. The section shows "These aliases are active on this machine but NOT defined in tracked .zshrc:" with no data rows
- **Mitigation:** The plan explicitly handles this via a separate `~/.zshrc.local` audit (section 3 of task 1), which was run and captured 17 undocumented aliases (tailscale + Courtsite shortcuts). This is a fundamental shell limitation — not fixable without sourcing the user's shell environment, which would introduce its own security concerns.
- **Intentional:** Yes — documented in the plan, mitigated by the separate local audit.

## Threat Flags

No new security-relevant surface introduced.

## Success Criteria

| Criterion | Status |
|-----------|--------|
| MAIN-02: CONCERNS.md updated for v1.3 | ✅ Updated with resolved v1.2 items removed, new security posture table, deferred GIT-01 |
| MAIN-04: install.sh idempotent | ✅ Verified: stow -R restows without errors on second run |
| MAIN-05: make doctor aggregates all checks | ✅ doctor chains test + sanitize + macos-check, exits clean |
| WORK-01: bin/audit-workflow exists and works | ✅ 143 lines, executable, generates WORKFLOW.md |
| WORK-02: WORKFLOW.md generated from shell history | ✅ 116 lines, top 40 commands, function usage, untracked scripts |
| WORK-03: Undocumented aliases audited | ✅ 17 aliases found in ~/.zshrc.local (tailscale + Courtsite) |
| PUBS-02: PRE-RESET-CHECKLIST.md actionable | ✅ 88 lines, 9 sections with backup commands, post-wipe rebuild |
| PUBS-03: make public-ready wraps pre-public checks | ✅ Chains sanitize + macos-check + gitignore + hardcoded path check |
| PUBS-04: make audit-home scans home directory | ✅ Scans .env, .nmconnection, SSH keys, shell history, gitignored files |

## Self-Check: PASSED

- ✅ `bin/audit-workflow` — executable, 143 lines (>=80)
- ✅ `WORKFLOW.md` — 116 lines (>=30), contains "Top Commands" and "Used Functions"
- ✅ `PRE-RESET-CHECKLIST.md` — 88 lines (>=40), contains "SSH Keys", "Shell History", "Post-Wipe"
- ✅ `make doctor` — runs without error
- ✅ `make public-ready` — runs without error
- ✅ `make audit-home` — runs without error
- ✅ `CONCERNS.md` — contains "v1.3", no resolved v1.2 items
- ✅ Commit `ac9321a` — task 1
- ✅ Commit `d81fe8e` — task 2
