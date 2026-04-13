# Plan 02: PATH Configuration

**Phase:** 1 - Platform Foundation  
**Wave:** 1 (parallel with 01)  
**Files Modified:** `zsh/.zshrc`  
**Requirements Addressed:** PATH-01, PATH-02, PATH-03, PATH-04

## Objective

Update PATH configuration to detect and add Homebrew paths for both macOS and Linux.

## Tasks

### 2.1 Update PATH Section for Homebrew

<read_first>
- `zsh/.zshrc` (current PATH section around line 35)
</read_first>

<action>
Replace the current PATH section (lines 34-35):

```zsh
# ---------------------------------
# fix PATH (system + npm + pnpm)
# ---------------------------------
```

With:

```zsh
# ---------------------------------
# PATH configuration
# ---------------------------------

# System paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrew (works on both macOS and Linux)
if is_darwin; then
  # macOS Homebrew
  if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon
    export HOMEBREW_PREFIX="/opt/homebrew"
  else
    # Intel
    export HOMEBREW_PREFIX="/usr/local"
  fi
elif command -v brew >/dev/null 2>&1; then
  # Linuxbrew
  export HOMEBREW_PREFIX="$(brew --prefix)"
fi

# Add Homebrew to PATH if available
if [ -n "$HOMEBREW_PREFIX" ] && [ -d "$HOMEBREW_PREFIX/bin" ]; then
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
fi

# User local paths
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$HOME/.local/share/pnpm:$PATH"

# Dotfiles scripts
export PATH="$HOME/uz6r/dotfiles/scripts:$PATH"
```

This:
- Detects Homebrew on macOS (Apple Silicon vs Intel)
- Detects Homebrew on Linux (Linuxbrew)
- Adds appropriate PATH entries based on platform
- Keeps existing npm/pnpm paths
</action>

<acceptance_criteria>
- [ ] `grep -q "HOMEBREW_PREFIX" zsh/.zshrc` returns 0
- [ ] `grep -q 'uname -m == "arm64"' zsh/.zshrc` returns 0
- [ ] `grep -q 'brew --prefix' zsh/.zshrc` returns 0
- [ ] `grep -q 'command -v brew' zsh/.zshrc` returns 0
- [ ] `zsh -n zsh/.zshrc` passes (syntax check)
</acceptance_criteria>

### 2.2 Remove Old PATH Export

<read_first>
- `zsh/.zshrc`
</read_first>

<action>
Remove the old hardcoded PATH export if it still exists after line 35:

```zsh
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.local/share/pnpm:$HOME/uz6r/dotfiles/scripts:$PATH"
```

This was the old PATH that should be replaced by the new modular approach above.
</action>

<acceptance_criteria>
- [ ] `grep -q '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin' zsh/.zshrc` returns 1 (old path removed)
</acceptance_criteria>

## Verification

```bash
# Syntax check
zsh -n zsh/.zshrc && echo "Syntax OK"

# Verify Homebrew detection logic present
grep -c "HOMEBREW_PREFIX" zsh/.zshrc
```

## Notes

- Homebrew on Linux uses `brew --prefix` to find install location
- The `command -v brew` check only runs on Linux, avoiding false positives on macOS
- Apple Silicon Macs use `/opt/homebrew` instead of `/usr/local`
