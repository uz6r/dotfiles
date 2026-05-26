---
phase: 07-remove-company-scripts
reviewed: 2026-05-26T14:45:00Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - Makefile
  - zsh/.zshrc
findings:
  critical: 0
  warning: 2
  info: 3
  total: 5
status: issues_found
---

# Phase 07: Code Review Report — Remove Company Scripts

**Reviewed:** 2026-05-26T14:45:00Z
**Depth:** standard
**Files Reviewed:** 2
**Status:** issues_found

## Summary

Reviewed `Makefile` and `zsh/.zshrc` for the Phase 07 changes (removing Courtsite/Sinar company scripts). The diff-introduced changes are correct and well-scoped:

- `status` target: fixed `bin/` prefix handling (`$HOME/` instead of `$HOME/.`)
- `courtsite-guard`: removed `-g '!bin'` exclusion now that sinar scripts are deleted
- `.zshrc` PATH: removed `$HOME/uz6r/dotfiles/scripts` entry (scripts directory is empty)

However, two pre-existing bugs were found in the `status` target (shell glob doesn't match dotfiles, and `rg` missing causes false success in the guard), plus minor quality issues.

## Warnings

### WR-01: `status` target glob does not match dotfiles — all symlinks silently skipped

**File:** `Makefile:27-54`
**Issue:** The `for f in $$d/*` glob on line 30 does **not** match files starting with `.` in POSIX sh (or bash without `dotglob`). All files in `zsh/`, `git/`, `nvim/`, and `tmux/` are dotfiles (`.zshrc`, `.gitconfig`, `.config`, `.tmux.conf`, etc.). The loop body silently skips every one of them, printing only `"scanning $$d ..."` with no file status lines afterward. Only `bin/*` (non-dotfile names) is checked correctly.

This makes `make status` report no symlink status for the primary dotfile packages, giving a misleading impression that everything is fine.

**Fix:** Use a glob that also matches dotfiles, and skip `.` and `..`:

```makefile
for d in zsh git nvim bin tmux; do \
    if [ -d $$d ]; then \
        echo "scanning $$d ..."; \
        for f in $$d/* $$d/.[!.]* $$d/..?*; do \
            [ -e "$$f" ] || continue; \
            basename="$$(basename $$f)"; \
            if [ "$$d" = "bin" ] || [ "$$d" = "tmux" ]; then \
                prefix="$$HOME/"; \
            else \
                prefix="$$HOME/."; \
            fi; \
            target="$${prefix}$$basename"; \
            ...
```

Alternatively, the `status` target could use `find` with `-maxdepth 1` to enumerate files reliably, or the recipe could set `shopt -s dotglob` if bash is guaranteed.

> **Note:** The `tmux` directory is also missing from the `status` loop (it is listed in `make clean` but not here). The fix above adds it.

### WR-02: `courtsite-guard` reports success if `rg` (ripgrep) is not installed

**File:** `Makefile:228`
**Issue:** The guard uses `! rg ... && echo success || { echo failure; exit 1; }`. If `rg` is not installed, its exit code is 127 (command not found). The `!` inverts this to 0, so the `&&` branch runs and prints `"✅ No Courtsite references found"` — a false negative. The guard would silently pass when it should fail.

**Fix:** Verify that `rg` is available before using it, or use a more portable grep:

```makefile
courtsite-guard: ## check for Courtsite references in repo
	@echo "→ Checking for Courtsite references..."
	@if ! command -v rg >/dev/null 2>&1; then \
		echo "❌ rg (ripgrep) not installed — cannot run courtsite guard"; \
		exit 1; \
	fi
	@! rg -i "courtsite|sinar|enjin|COURTSITE_DIR" --files-with-matches --hidden -g '!.git' -g '!.planning' -g '!Makefile' -g '!README.md' -g '!.githooks' . && echo "  ✅ No Courtsite references found" || { echo "❌ Courtsite references found"; exit 1; }
```

## Info

### IN-01: Hardcoded `/home/uzer/` path instead of `$HOME`

**File:** `zsh/.zshrc:364`
**Issue:** `export PATH=/home/uzer/.opencode/bin:$PATH` uses the literal path `/home/uzer/` instead of `$HOME`. The rest of `.zshrc` consistently uses `$HOME` (e.g., line 112: `${DOTFILES_DIR:-$HOME/uz6r/dotfiles}`, line 80: `$HOME/.local/bin`). Mixing conventions makes the file less portable.

**Fix:**
```zsh
export PATH=$HOME/.opencode/bin:$PATH
```

### IN-02: Inconsistent tab indentation on `LUA_FILES` variable

**File:** `Makefile:63`
**Issue:** The `LUA_FILES` variable uses a tab between the name and `:=`, while `SHELL_SCRIPTS`, `YAML_FILES`, and `JSON_FILES` (lines 60-62) use spaces. While functionally equivalent in GNU Make (outside recipe lines), this is inconsistent and could be confusing.

**Fix:** Replace the tab with spaces to match the other three variable assignments.

### IN-03: `scripts/` directory is empty and untracked

**File:** `zsh/.zshrc` (related), filesystem
**Issue:** The `scripts/` directory exists on disk but is empty (only `.` and `..`). It is not tracked by git. It was previously referenced in `.zshrc`'s PATH (now removed in this phase). It should be cleaned up to avoid confusion.

**Fix:** Remove the empty directory:
```bash
rmdir scripts/
```

---

_Reviewed: 2026-05-26T14:45:00Z_
_Reviewer: OpenCode (gsd-code-reviewer)_
_Depth: standard_
