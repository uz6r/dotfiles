# Plan 01: Platform Detection

**Phase:** 1 - Platform Foundation  
**Wave:** 1 (parallel with 02)  
**Files Modified:** `zsh/.zshrc`  
**Requirements Addressed:** PLAT-01, PLAT-02, PLAT-03

## Objective

Add platform detection to .zshrc so we can conditionally load platform-specific configs.

## Tasks

### 1.1 Add Platform Variables

<read_first>
- `zsh/.zshrc` (current state)
</read_first>

<action>
Add at the top of the shell behavior section (after line 53, before generic aliases):

```zsh
# ---------------------------------
# platform detection
# ---------------------------------
export IS_MACOS=false
export IS_LINUX=false

case "$(uname -s)" in
  Darwin*)
    export IS_MACOS=true
    ;;
  Linux*)
    export IS_LINUX=true
    ;;
esac

is_darwin() { [[ "$IS_MACOS" == "true" ]]; }
is_linux() { [[ "$IS_LINUX" == "true" ]]; }
```

This adds:
- `$IS_MACOS` and `$IS_LINUX` boolean exports for conditionals
- `is_darwin()` and `is_linux()` helper functions
</action>

<acceptance_criteria>
- [ ] `grep -q "IS_MACOS" zsh/.zshrc` returns 0
- [ ] `grep -q "is_darwin()" zsh/.zshrc` returns 0
- [ ] `grep -q "is_linux()" zsh/.zshrc` returns 0
- [ ] `zsh -n zsh/.zshrc` passes (syntax check)
</acceptance_criteria>

---

### 1.2 Document Platform Variables

<read_first>
- `zsh/.zshrc`
</read_first>

<action>
Add a comment block above the platform detection section:

```zsh
# ---------------------------------
# platform detection (Darwin/Linux)
# ---------------------------------
# IS_MACOS, IS_LINUX: boolean exports for conditional logic
# is_darwin(), is_linux(): helper functions
```

This documents the new variables for future maintainers.
</action>

<acceptance_criteria>
- [ ] `grep -q "# platform detection (Darwin/Linux)" zsh/.zshrc` returns 0
</acceptance_criteria>

## Verification

```bash
# Test detection on current system
zsh -c 'source zsh/.zshrc; echo "IS_MACOS=$IS_MACOS, IS_LINUX=$IS_LINUX"; is_darwin && echo "darwin"; is_linux && echo "linux"'

# Syntax check
zsh -n zsh/.zshrc && echo "Syntax OK"
```

## Notes

- Using `case` statement for compatibility
- Exports allow child processes to check platform
- Helper functions enable cleaner conditional syntax
