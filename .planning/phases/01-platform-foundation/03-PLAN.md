# Plan 03: Platform Aliases

**Phase:** 1 - Platform Foundation  
**Wave:** 2 (after 01, 02 complete)  
**Files Modified:** `zsh/.zshrc`  
**Requirements Addressed:** ALIAS-01, ALIAS-02, ALIAS-03, ALIAS-04, ALIAS-05, ALIAS-06

## Objective

Update all system tool aliases to work on both platforms.

## Tasks

### 3.1 Fix Clipboard Aliases

<read_first>
- `zsh/.zshrc` (current clipboard aliases around line 145)
</read_first>

<action>
Replace the current Linux-only clipboard aliases:

```zsh
# clipboard (Linux)
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
```

With:

```zsh
# clipboard (cross-platform)
if is_darwin; then
  alias copy='pbcopy'
  alias paste='pbpaste'
else
  # Linux: xclip for clipboard
  if command -v xclip >/dev/null 2>&1; then
    alias copy='xclip -selection clipboard -i'
    alias paste='xclip -selection clipboard -o'
  fi
fi
```

This:
- Creates unified `copy` and `paste` aliases
- Uses native macOS tools on Darwin
- Falls back gracefully on Linux if xclip not installed
</action>

<acceptance_criteria>
- [ ] `grep -A5 "clipboard (cross-platform)" zsh/.zshrc | grep -q "is_darwin"` returns 0
- [ ] `grep -q "alias copy=" zsh/.zshrc` returns 0
- [ ] `grep -q "alias paste=" zsh/.zshrc` returns 0
- [ ] `zsh -n zsh/.zshrc` passes
</acceptance_criteria>

---

### 3.2 Fix Open Command

<read_first>
- `zsh/.zshrc`
</read_first>

<action>
Add after clipboard aliases section:

```zsh
# open command (cross-platform)
if is_darwin; then
  # macOS has native 'open'
  alias open='open'
else
  # Linux: xdg-open for opening files/URLs
  if command -v xdg-open >/dev/null 2>&1; then
    alias open='xdg-open'
  fi
fi
```

This provides `open` command on both platforms (native on macOS, xdg-open on Linux).
</action>

<acceptance_criteria>
- [ ] `grep -q "xdg-open" zsh/.zshrc` returns 0
- [ ] `grep -q "# open command" zsh/.zshrc` returns 0
</acceptance_criteria>

---

### 3.3 Fix localip Alias

<read_first>
- `zsh/.zshrc` (current localip alias around line 141)
</read_first>

<action>
Replace:

```zsh
alias localip='ip addr show | grep "inet " | grep -v 127.0.0.1'
```

With:

```zsh
alias localip='if is_darwin; then ifconfig | grep "inet " | grep -v 127.0.0.1; else ip addr show | grep "inet " | grep -v 127.0.0.1; fi'
```

This makes localip work on both platforms.
</action>

<acceptance_criteria>
- [ ] `grep -q "alias localip=" zsh/.zshrc` returns 0
- [ ] `grep -q "ifconfig" zsh/.zshrc` returns 0
</acceptance_criteria>

---

### 3.4 Fix ports Alias

<read_first>
- `zsh/.zshrc` (current ports alias around line 142)
</read_first>

<action>
Replace:

```zsh
alias ports='netstat -tulanp'
```

With:

```zsh
alias ports='lsof -i -P'
```

Using `lsof` works on both macOS and Linux.
</action>

<acceptance_criteria>
- [ ] `grep -q "alias ports='lsof" zsh/.zshrc` returns 0
</acceptance_criteria>

---

### 3.5 Fix ll Alias for Colors

<read_first>
- `zsh/.zshrc` (current ll alias around line 60)
</read_first>

<action>
Replace:

```zsh
alias ll='ls -lah --color=auto'
```

With:

```zsh
if is_darwin; then
  alias ll='ls -lahG'
else
  alias ll='ls -lah --color=auto'
fi
```

macOS BSD ls uses `-G` for color, GNU ls (Linux) uses `--color=auto`.
</action>

<acceptance_criteria>
- [ ] `grep -A3 "alias ll=" zsh/.zshrc | grep -q "is_darwin"` returns 0
- [ ] `grep -q 'ls -lahG' zsh/.zshrc` returns 0
- [ ] `grep -q '--color=auto' zsh/.zshrc` returns 0
</acceptance_criteria>

## Verification

```bash
# Syntax check
zsh -n zsh/.zshrc && echo "Syntax OK"

# Verify aliases present
grep -E "alias (copy|paste|open|localip|ports|ll)=" zsh/.zshrc
```

## Notes

- The `command -v` checks make xclip and xdg-open optional on Linux
- `lsof -i -P` shows listening ports on both platforms (no root needed for basic info)
- Consider adding `xclip` and `xdg-open` to install.sh as recommended packages
