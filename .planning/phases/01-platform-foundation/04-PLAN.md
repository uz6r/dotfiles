# Plan 04: Function Updates

**Phase:** 1 - Platform Foundation  
**Wave:** 2 (after 01, 02 complete)  
**Files Modified:** `zsh/.zshrc`  
**Requirements Addressed:** FUNC-01, FUNC-02

## Objective

Update utility functions to work correctly on both platforms.

## Tasks

### 4.1 Verify killport Works on Both

<read_first>
- `zsh/.zshrc` (current killport function around line 94)
</read_first>

<action>
Check that the current killport function uses `lsof` (which works on both platforms):

```zsh
killport() {
  local pid=$(lsof -ti:$1)
  if [ -z "$pid" ]; then
    echo "no process found on port $1"
    return 0
  fi
  kill -9 $pid
  echo "killed process $pid on port $1"
}
```

This is already correct — `lsof` works on both macOS and Linux. No changes needed.

Add a comment to document this:

```zsh
# kill process on port (works on both macOS and Linux via lsof)
killport() {
```

</action>

<acceptance_criteria>
- [ ] `grep -q "killport()" zsh/.zshrc` returns 0
- [ ] `grep -q "lsof -ti:" zsh/.zshrc` returns 0
</acceptance_criteria>

---

### 4.2 Wrap localdev in Linux Check

<read_first>
- `zsh/.zshrc` (current localdev function around line 104)
</read_first>

<action>
Wrap the localdev function to only load on Linux since Courtsite is Linux-only:

Replace the function definition with:

```zsh
# Courtsite local dev (Linux only - Courtsite is Linux-only project)
if is_linux; then
localdev() {
  local base_dir="${COURTSITE_DIR:-$HOME/Courtsite}/enjin"
  dir1="$base_dir/enjin-proksi"
  dir2="$base_dir/enjin-pelanggan"
  dir3="$base_dir/enjin-konsol"
  dir4="$base_dir/enjin-core"
  dir5="$base_dir/enjin-setiausaha"
  dir6="$base_dir/enjin-workflow"
  
  start_tmux_layout() {
    tmux new-session "cd $dir1; exec zsh" \; \
      split-window -h "cd $dir2; exec zsh" \; \
      split-window -v "cd $dir3; exec zsh" \; \
      select-pane -t 0 \; \
      split-window -v "cd $dir4; exec zsh" \; \
      select-pane -t 1 \; \
      split-window -v "cd $dir5; exec zsh" \; \
      select-pane -t 2 \; \
      split-window -v "cd $dir6; exec zsh" \; \
      select-layout tiled
  }
  
  if [ -z "$TMUX" ]; then
    start_tmux_layout
  else
    tmux new-window
    start_tmux_layout
  fi
}
fi  # end Linux-only
```

This wraps the entire Courtsite-related function in a Linux check so it doesn't cause errors on macOS.
</action>

<acceptance_criteria>
- [ ] `grep -B1 "localdev()" zsh/.zshrc | grep -q "is_linux"` returns 0
- [ ] `grep -A3 "localdev()" zsh/.zshrc | grep -q "is_linux"` returns 0 (closing fi)
- [ ] `zsh -n zsh/.zshrc` passes
</acceptance_criteria>

## Verification

```bash
# Syntax check
zsh -n zsh/.zshrc && echo "Syntax OK"

# Test killport function exists
grep -q "killport()" zsh/.zshrc && echo "killport OK"

# Test localdev wrapped in is_linux
grep -c "is_linux" zsh/.zshrc | grep -q "2\|3\|4" && echo "localdev wrapped OK"
```

## Notes

- `killport` already uses `lsof` which works cross-platform
- Wrapping `localdev` prevents Courtsite paths from being referenced on macOS
- The Courtsite aliases at the bottom of .zshrc should also be wrapped (handled in Plan 03)
