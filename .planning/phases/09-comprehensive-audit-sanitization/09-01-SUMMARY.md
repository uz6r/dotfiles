---
phase: 09-comprehensive-audit-sanitization
plan: 01
subsystem: security
tags: [gitleaks, gitignore, secrets, wifi-psk, path-sanitization]

requires: []
provides:
  - Sensitive files removed from git tracking (WiFi PSK, binary bloat)
  - Security-pattern .gitignore covering secrets, keys, credentials
  - Hardcoded /home/uzer paths replaced with $HOME everywhere
  - Gitleaks v8.30.1 installed with custom 6-rule config
  - private/ directory as explicit public/private boundary
  - Empty scripts/ directory deleted
affects:
  - 09-02 (pre-commit gitleaks integration will use .gitleaks.toml)

tech-stack:
  added: [gitleaks-8.30.1]
  patterns:
    - "Security patterns in .gitignore for all sensitive file types"
    - "public/private boundary via gitignored private/ directory"
    - "Dynamic DOTFILES_DIR resolution in audit scripts"
    - "Custom gitleaks configuration extending default rules"

key-files:
  created:
    - .gitleaks.toml — 6 custom secret detection rules + allowlist
    - private/README.md — public/private boundary documentation
  modified:
    - .gitignore — expanded from 13 lines to 41 lines with security patterns
    - zsh/.zshrc — 2 hardcoded /home/uzer paths → $HOME
    - bin/audit-nvim-plugins — hardcoded path → dynamic SCRIPT_DIR resolution
  deleted:
    - ZTE_EC382D.nmconnection (removed from tracking, kept on disk)
    - lazygit (removed from tracking, kept on disk)
    - lazygit.tar.gz (removed from tracking, kept on disk)

key-decisions:
  - "Gitleaks installed via binary download from GitHub releases (install script URL returned 404)"
  - "private/ directory gitignored entirely with !private/README.md negation for docs"
  - "Dynamic DOTFILES_DIR from script location rather than hardcoded $HOME/uz6r/dotfiles"

patterns-established:
  - "Security gitignore: always cover *.nmconnection, *.pem, *.key, *.pfx, .env*, private/"
  - "Binary artifacts: add explicit patterns for accidentally-tracked binaries"
  - "Audit scripts: derive DOTFILES_DIR from script location instead of hardcoded paths"
  - "Secret scanning: custom gitleaks config extending default rules with allowlist"

requirements-completed:
  - SANI-01
  - SANI-02
  - SANI-03
  - SANI-04
  - SANI-05
  - MAIN-01
  - PUBS-01

duration: 12min
completed: 2026-05-26
---

# Phase 09 Plan 01: Security Triage & Git Hygiene Summary

**WiFi PSK removed from git tracking, .gitignore expanded with 8+ security patterns,
3 hardcoded /home/uzer paths replaced with $HOME, Gitleaks v8.30.1 installed with custom config,
private/ public/private boundary established**

## Performance

- **Duration:** 12 min
- **Started:** 2026-05-26T20:30:00Z
- **Completed:** 2026-05-26T20:42:00Z
- **Tasks:** 2
- **Files created:** 2 (.gitleaks.toml, private/README.md)
- **Files modified:** 3 (.gitignore, zsh/.zshrc, bin/audit-nvim-plugins)
- **Files removed from tracking:** 3 (ZTE_EC382D.nmconnection, lazygit, lazygit.tar.gz)

## Accomplishments

- **SANI-01:** Removed ZTE_EC382D.nmconnection (WiFi PSK `7A33S6282B`) from git tracking, added `*.nmconnection` to .gitignore
- **SANI-02:** Removed lazygit + lazygit.tar.gz (29MB binary bloat) from tracking, added patterns to .gitignore
- **SANI-03:** Replaced all 3 hardcoded `/home/uzer` paths with `$HOME` or dynamic resolution — zero occurrences remain outside .planning/
- **SANI-04:** Expanded .gitignore from 13 to 41 lines covering nmconnection, pem, key, pfx, p12, env*, credentials, aws/, kube/, gcloud/, history files, netrc, git-credentials, tokens, private/
- **SANI-05:** Installed Gitleaks v8.30.1 with custom .gitleaks.toml (6 rules + default extension + allowlist)
- **MAIN-01:** Deleted empty scripts/ directory
- **PUBS-01:** Created private/ directory with README.md documenting the public/private boundary

## Task Commits

Each task was committed atomically:

1. **Task 1: Remove tracked sensitive files, expand .gitignore, delete scripts/ dir** — `1cf58d0` (chore)
2. **Task 2: Fix hardcoded paths, install Gitleaks, create .gitleaks.toml** — `7e367c3` (feat)

## Files Created/Modified

### Created
- `.gitleaks.toml` — 6 custom secret detection rules (SSH keys, home paths, WiFi PSK, API keys, tokens, base64) extending default config with allowlist for `.planning/` and `.githooks/`
- `private/README.md` — 27-line documentation of the public/private boundary, usage rules, and pre-wipe checklist

### Modified
- `.gitignore` — Expanded from 13 to 41 lines with comprehensive security patterns (nmconnection, pem/key/pfx/p12, env*, credentials, aws/, kube/, gcloud/, history, tokens, private/)
- `zsh/.zshrc` — Line 3: `fpath` path fixed; Line 365: `PATH` entry fixed
- `bin/audit-nvim-plugins` — Line 7: `CONFIG_FILE` now derives from script location via `SCRIPT_DIR`/`DOTFILES_DIR`

### Removed from tracking (local copies preserved)
- `ZTE_EC382D.nmconnection` — WiFi config with plaintext PSK
- `lazygit` — Binary artifact (~29MB)
- `lazygit.tar.gz` — Binary archive

## Decisions Made

- **Gitleaks install method:** The official install script returned 404 (`master` branch no longer has `scripts/install.sh`). Downloaded binary directly from GitHub releases v8.30.1 and installed to `~/.local/bin/`.
- **File tracking removals:** Used `git rm --cached` (not `git rm`) to preserve local copies — user needs WiFi access until machine wipe. Actual deletion documented in PRE-RESET-CHECKLIST.md (Plan 03).
- **Dynamic path resolution:** Used `"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` pattern for script-based DOTFILES_DIR detection instead of hardcoded `$HOME/uz6r/dotfiles`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Gitleaks install script URL returned 404**
- **Found during:** Task 2 (Install Gitleaks)
- **Issue:** Plan specified `curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/scripts/install.sh | sh` but this URL returned HTTP 404 — the `master` branch no longer has `scripts/install.sh`
- **Fix:** Downloaded gitleaks v8.30.1 Linux amd64 binary directly from GitHub releases (`https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz`), extracted, and installed to `$HOME/.local/bin/gitleaks`
- **Files modified:** None (install method changed, no files affected)
- **Verification:** `gitleaks version` returns `8.30.1`, `gitleaks dir -c .gitleaks.toml .` runs successfully
- **Committed in:** `7e367c3` (task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Minor — only the install method changed. Gitleaks v8.30.1 installed successfully and works with the custom config. No scope creep.

## Issues Encountered

- **gitleaks install script 404:** The URL referenced in the plan no longer exists on gitleaks's `master` branch. Downloaded binary from releases page instead.
- **`git ls-files` exit code:** The plan's acceptance criterion specified `git ls-files [file]` exits non-zero for untracked files, but actual git behavior is that `git ls-files` exits 0 even when the file is not in the index. Used `git ls-files --error-unmatch [file]` for proper verification (exits 1 when unmatched).

## Stub Tracking

No stubs identified — all files have substantive content.

## Threat Flags

No new threat flags — all changes are mitigative (removing secrets, adding detection gates).

## Self-Check

**PASSED**

- [x] `.gitignore` contains `*.nmconnection`, `*.pem`, `*.key`, `.env*`, `private/`, `lazygit`
- [x] `private/README.md` exists with 27 lines (≥5 required)
- [x] `scripts/` directory deleted
- [x] Zero `/home/uzer` in `zsh/.zshrc` and `bin/audit-nvim-plugins`
- [x] `.gitleaks.toml` exists with 6 rule definitions
- [x] `gitleaks` installed at `$HOME/.local/bin/gitleaks` (v8.30.1)
- [x] `ZTE_EC382D.nmconnection`, `lazygit`, `lazygit.tar.gz` untracked (not in git index)
- [x] All 3 committed with `--no-verify` for worktree safety

## Next Phase Readiness

- Security gitignore in place — ready for Plan 02 pre-commit gitleaks integration
- Gitleaks installed and config ready for scripted scanning
- All sensitive file removals complete — ready for audit tooling build-out
- private/ boundary established — ready for pre-reset checklist (Plan 03)

---

*Phase: 09-comprehensive-audit-sanitization*
*Completed: 2026-05-26*
