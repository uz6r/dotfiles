---
phase: 07-remove-company-scripts
plan: 07-01
subsystem: bin, zsh, Makefile
tags:
  - cleanup
  - courtsite
  - scripts
  - stow
  - PATH
  - guard
dependency_graph:
  requires: []
  provides:
    - SCRIPT-01: sinar-pi-setup and sinar-pi-wifi-setup removed from bin/
    - SCRIPT-02: No broken symlinks after removal
    - SCRIPT-03: scripts/ PATH reference cleaned up
  affects:
    - bin/: two remaining scripts (audit-nvim-plugins, profile-zsh) stowed correctly
    - Makefile: status target fixed, courtsite-guard no longer excludes bin/
    - .zshrc: PATH no longer references scripts/ directory
tech-stack:
  added: []
  patterns:
    - stow -t "$HOME" for proper symlink placement (install.sh pattern)
key-files:
  created: []
  modified:
    - Makefile (status target fix + courtsite-guard -g '!bin' removal)
    - zsh/.zshrc (PATH cleanup line 80)
  deleted:
    - bin/sinar-pi-setup
    - bin/sinar-pi-wifi-setup
decisions:
  - D-01: Pre-existing bug in `make status` — bin/ files checked at `$HOME/.<name>` but stow creates at `$HOME/<name>`. Fixed in this plan to allow correct verification.
  - D-02: stow requires `-t "$HOME"` flag for cross-machine testing (default target differs from install.sh invocation)
metrics:
  duration_minutes: ~5
  completed_date: "2026-05-26"
  commits: 5
---

# Phase 7 Plan 1: Remove Courtsite Scripts from bin/ & Verify Stow

**One-liner:** Deleted `sinar-pi-setup` and `sinar-pi-wifi-setup` from `bin/`, removed `scripts/` PATH reference, updated courtsite-guard to no longer exclude `bin/`, and fixed a pre-existing bug in `make status` for the `bin/` stow package.

## Completed Tasks

| Task | Description | Commit | Files |
|------|-------------|--------|-------|
| 1 | Delete sinar-pi-setup from bin/ | `32f1e76` | bin/sinar-pi-setup |
| 2 | Delete sinar-pi-wifi-setup from bin/ | `0c764d9` | bin/sinar-pi-wifi-setup |
| 3 | Verify stow state — no broken symlinks | `5ea7e80` | Makefile |
| 4 | Update PATH — remove scripts/ reference | `1927897` | zsh/.zshrc |
| 5 | Update courtsite-guard — remove bin/ exclusion | `6403f23` | Makefile |
| 6 | Final verification — make test passes | (verified) | N/A |

## Requirements Satisfied

- **SCRIPT-01** ✓ — `sinar-pi-setup` and `sinar-pi-wifi-setup` removed
- **SCRIPT-02** ✓ — `stow -t "$HOME" bin` creates clean symlinks; `make status` shows all ✅
- **SCRIPT-03** ✓ — `$HOME/uz6r/dotfiles/scripts` removed from PATH in `.zshrc`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 — Bug] Fixed `make status` target for bin/ symlink check**
- **Found during:** Task 3
- **Issue:** The `make status` target checked `$HOME/.<name>` (with dot prefix) for all packages, but the `bin/` stow package creates files at `$HOME/<name>` (no dot). This caused false ❌ entries that prevented verifying the plan's acceptance criteria.
- **Fix:** Added per-package prefix logic — `bin/` uses `$HOME/` prefix (no dot), all other packages use `$HOME/.` prefix.
- **Files modified:** `Makefile` (lines 32-38)
- **Commit:** `5ea7e80`

### Pre-existing Issues (noted, not fixed)

- The `make status` target does not check `nvim/` package (its `.config` file is a dotfile, skipped by glob). Out of scope — not addressed here.
- The `make clean` target (`stow -D zsh git nvim bin tmux`) uses default target without `-t "$HOME"`, which differs from `install.sh`. Out of scope — not addressed here.

## Verification Results

```
=== Running Dotfiles Tests ===
→ Testing zsh config syntax          ✅
→ Testing git config syntax           ✅
→ Testing Neovim config (headless)    ✅
→ Running courtsite guard             ✅ No Courtsite references found
=== All tests passed ===
```

## Known Stubs

None identified. All modified files have been fully wired.

## Threat Flags

None — no new network endpoints, auth paths, file access patterns, or schema changes introduced.

## Self-Check

- [x] `bin/sinar-pi-setup` deleted — confirmed via `ls` (exit 2)
- [x] `bin/sinar-pi-wifi-setup` deleted — confirmed via `ls` (exit 2)
- [x] `make status` — no ❌ entries (healthy symlinks with `-t "$HOME"`)
- [x] `grep '$HOME/uz6r/dotfiles/scripts' zsh/.zshrc` — empty (no match)
- [x] `grep "\-g '!bin'" Makefile` — empty (no match)
- [x] `make test` — exit 0 (all tests pass)

## Self-Check: PASSED
