---
phase: 06-clean-shell-configuration
reviewed: 2026-04-30T12:00:00Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - zsh/.zshrc
  - Makefile
  - .githooks/pre-commit
findings:
  critical: 0
  warning: 9
  info: 4
  total: 13
status: issues_found
---

# Phase 6: Code Review Report

**Reviewed:** 2026-04-30T12:00:00Z
**Depth:** standard
**Files Reviewed:** 3
**Status:** issues_found

## Summary

Reviewed three source files from the shell configuration cleanup phase: `zsh/.zshrc`, `Makefile`, and `.githooks/pre-commit`. Found 9 warnings and 4 info items. No critical security vulnerabilities detected. Main concerns are around unquoted variables, missing input validation in shell functions, hardcoded paths that reduce portability, and a pre-commit hook that suppresses error output.

## Warnings

### WR-01: Unquoted variable in source command

**File:** `zsh/.zshrc:30`
**Issue:** `$ZSH` is unquoted in the source command. If the path contains special characters or spaces, the command will fail or behave unexpectedly.
**Fix:**
```zsh
source "$ZSH/oh-my-zsh.sh"
```

---

### WR-02: No error handling on `brew --prefix` command substitution

**File:** `zsh/.zshrc:71`
**Issue:** If `brew --prefix` fails (e.g., Homebrew is not properly installed), the command substitution returns an empty string and `HOMEBREW_PREFIX` is set to empty without any indication. While line 75 checks for non-empty, there's no diagnostic output.
**Fix:**
```zsh
elif command -v brew >/dev/null 2>&1; then
  # Linuxbrew
  _brew_prefix="$(brew --prefix 2>/dev/null)"
  if [ -n "$_brew_prefix" ]; then
    export HOMEBREW_PREFIX="$_brew_prefix"
  fi
fi
```

---

### WR-03: `bak()` function missing argument validation

**File:** `zsh/.zshrc:140`
**Issue:** The `bak()` function doesn't check if an argument is provided. If called without arguments, `cp "$1"{,.bak}` expands to an invalid command.
**Fix:**
```zsh
bak() {
  if [ -z "$1" ]; then
    echo "Usage: bak <file>"
    return 1
  fi
  cp "$1"{,.bak}
}
```

---

### WR-04: `killport()` has unquoted variables and no input validation

**File:** `zsh/.zshrc:143-151`
**Issue:** 
1. `$1` is unquoted in `lsof -ti:$1` — if empty, this could produce unexpected results
2. `$pid` is unquoted in `kill -9 $pid`
3. No validation that `$1` is a valid port number

**Fix:**
```zsh
killport() {
  if [ -z "$1" ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Usage: killport <port-number>"
    return 1
  fi
  local pid
  pid=$(lsof -ti:"$1" 2>/dev/null)
  if [ -z "$pid" ]; then
    echo "No process found on port $1"
    return 0
  fi
  kill -9 "$pid"
  echo "Killed process $pid on port $1"
}
```

---

### WR-05: Complex conditional alias should be a function

**File:** `zsh/.zshrc:162`
**Issue:** The `localip` alias contains shell conditionals and pipes, which is fragile for an alias. Aliases with complex logic should be functions for better readability and reliability.
**Fix:**
```zsh
localip() {
  if is_darwin; then
    ifconfig | grep "inet " | grep -v 127.0.0.1
  else
    ip addr show | grep "inet " | grep -v 127.0.0.1
  fi
}
```

---

### WR-06: `gpub()` lacks error handling

**File:** `zsh/.zshrc:242-248`
**Issue:** No check if the branch already exists, and no error message if `git push` fails. The function silently fails if the branch exists or push fails.
**Fix:**
```zsh
gpub() {
  if [ -z "$1" ]; then
    echo "❌ Usage: gpub <branch-name>"
    return 1
  fi
  if git show-ref --verify --quiet "refs/heads/$1"; then
    echo "❌ Branch '$1' already exists"
    return 1
  fi
  git checkout -b "$1" && git push -u origin "$1"
}
```

---

### WR-07: Unquoted command substitution in `gmain()`

**File:** `zsh/.zshrc:251-253`
**Issue:** The command substitution `$(git symbolic-ref ...)` is unquoted. If it returns empty (no remote HEAD configured), `git checkout` receives no argument.
**Fix:**
```zsh
gmain() {
  local branch
  branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  if [ -z "$branch" ]; then
    echo "❌ Could not determine default branch"
    return 1
  fi
  git checkout "$branch"
}
```

---

### WR-08: Pre-commit hook suppresses error output from `make format`

**File:** `.githooks/pre-commit:14`
**Issue:** `make format > /dev/null 2>&1` redirects both stdout and stderr to `/dev/null`. If `make format` fails (e.g., missing tools), the user gets no diagnostic information.
**Fix:**
```sh
# Run formatting and capture output for debugging
make format > /tmp/pre-commit-format.log 2>&1 || {
  echo "❌ 'make format' failed. Check /tmp/pre-commit-format.log for details."
  exit 1
}
# Or at minimum, keep stderr visible:
# make format > /dev/null
```

---

### WR-09: Makefile `ci-check` subshell prevents proper exit

**File:** `Makefile:182`
**Issue:** The command `git diff --exit-code || (echo "..." && exit 1)` uses a subshell `(...)`. The `exit 1` only exits the subshell, not `make`. This means `ci-check` will NOT fail as expected when there are uncommitted formatting changes.
**Fix:**
```makefile
	@git diff --exit-code || { echo "❌ run 'make format' locally before committing"; exit 1; }
```
Using `{ ...; }` (braces with semicolon) instead of `(...)` (subshell) ensures `exit 1` terminates `make`.

---

## Info

### IN-01: Hardcoded `/home/uzer` path in fpath

**File:** `zsh/.zshrc:3`
**Issue:** The fpath uses a hardcoded `/home/uzer` path instead of `$HOME`. This reduces portability if the repo is used by another user.
**Fix:**
```zsh
fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)
```

---

### IN-02: Hardcoded `/uz6r/dotfiles` path instead of using `$DOTFILES_DIR`

**File:** `zsh/.zshrc:80`
**Issue:** The PATH export hardcodes `$HOME/uz6r/dotfiles/scripts` while line 112's `dotfiles` alias properly uses `${DOTFILES_DIR:-$HOME/uz6r/dotfiles}`. Inconsistent approach.
**Fix:**
```zsh
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$HOME/.local/share/pnpm:${DOTFILES_DIR:-$HOME/uz6r/dotfiles}/scripts:$PATH"
```

---

### IN-03: Hardcoded `/home/uzer` in opencode PATH export

**File:** `zsh/.zshrc:365`
**Issue:** The opencode PATH uses hardcoded `/home/uzer` instead of `$HOME`.
**Fix:**
```zsh
export PATH="$HOME/.opencode/bin:$PATH"
```

---

### IN-04: Numeric aliases 1-9 for directory stack navigation

**File:** `zsh/.zshrc:117`
**Issue:** Creating numeric aliases (1, 2, ..., 9) can be confusing and may conflict with numeric arguments in other contexts. Consider using a prefix or different naming.
**Fix:** (Optional) Use a prefix:
```zsh
for i in {1..9}; do alias "d$i"="cd +$i"; done
# Then use `d1`, `d2`, etc.
```

---

_Reviewed: 2026-04-30T12:00:00Z_
_Reviewer: OpenCode (gsd-code-reviewer)_
_Depth: standard_
