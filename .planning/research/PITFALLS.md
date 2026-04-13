# Pitfalls Research

**Domain:** Cross-platform zsh dotfiles (Linux/macOS)
**Researched:** 2026-04-13
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Assuming Linux Tools Exist on macOS

**What goes wrong:** Aliases/functions fail silently or error out on macOS.

**Why it happens:** Linux tools like `xclip`, `ip`, `netstat` with Linux flags don't exist on macOS.

**How to avoid:**
- Always use platform detection before system tool aliases
- Test on both platforms before committing
- Use tools available on both (e.g., `lsof` instead of `netstat -tulanp`)

**Warning signs:**
- Commands work on Linux but fail on macOS
- "command not found" in error messages on one platform
- `which` returns empty for expected tools

**Example fix:**
```zsh
# BAD - fails on macOS
alias pbcopy='xclip -selection clipboard'

# GOOD - works on both
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias pbcopy='pbcopy'  # native, or alias differently
else
  alias pbcopy='xclip -selection clipboard'
fi
```

---

### Pitfall 2: Different `sed` Behavior

**What goes wrong:** `sed -i` works differently on GNU (Linux) vs BSD (macOS).

**Why it happens:** Linux `sed -i 's/foo/bar/' file` vs macOS `sed -i '' 's/foo/bar/' file`

**How to avoid:**
- Use `sed -i ''` (BSD syntax) which works on macOS
- For scripts that must work on both, test thoroughly
- Or use `perl -pi -e` which works identically on both

**Warning signs:**
- `sed` commands modify wrong files
- `sed: 1: "file": invalid command code` on macOS

---

### Pitfall 3: Homebrew Path Not in PATH

**What goes wrong:** Installed tools not found because Homebrew bin not in PATH.

**Why it happens:** Homebrew paths differ by platform and architecture.

**How to avoid:**
- Use Homebrew's official shellenv integration:
  ```zsh
  if [[ "$(uname -s)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
  else
    eval "$(brew --prefix)/bin/brew shellenv)"  # Linuxbrew
  fi
  ```

**Warning signs:**
- `brew install X` succeeds but `X` command not found
- "command not found" for tools installed via brew

---

### Pitfall 4: Hardcoded `/home/username` Paths

**What goes wrong:** Dotfiles work on one machine but fail on others.

**Why it happens:** Using absolute paths like `/home/uzer/` instead of `$HOME`.

**How to avoid:**
- Always use `$HOME` or `~` for home directory
- Use `${DOTFILES_DIR:-$HOME/uz6r/dotfiles}` for dotfiles path
- Use `$(whoami)` instead of hardcoded usernames

**Warning signs:**
- Dotfiles cloned to different username fail
- "No such file or directory" errors

---

### Pitfall 5: Shellcheck Ignores zsh

**What goes wrong:** Bash/shellcheck passes but zsh syntax errors occur.

**Why it happens:** shellcheck targets POSIX sh/bash, not zsh-specific syntax.

**How to avoid:**
- Always test with `zsh -n ~/.zshrc` after changes
- Use `zsh -N` for additional checks
- Don't rely solely on shellcheck

**Warning signs:**
- shellcheck passes but shell fails to source
- "command not found" for functions defined earlier in file

---

### Pitfall 6: Color Flags in `ls`

**What goes wrong:** `ls --color` works on Linux but `-G` needed on macOS.

**Why it happens:** GNU ls vs BSD ls flag differences.

**How to avoid:**
- Use `ls -lah --color=auto` for Linux
- Use conditional for macOS or rely on CLICOLOR
- ```zsh
  if [[ "$(uname -s)" == "Darwin" ]]; then
    alias ll='ls -lahG'
  else
    alias ll='ls -lah --color=auto'
  fi
  ```

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Testing only on Linux | Faster dev | Will break on Mac | Never for dual-boot |
| Using GNU sed directly | Simpler syntax | Fails on macOS | Only if guaranteed Linux-only |
| Skipping `zsh -n` check | Saves 2 seconds | Debugging time | Never |

## "Looks Done But Isn't" Checklist

- [ ] **Clipboard:** Test `copy` and `paste` on both platforms
- [ ] **Homebrew:** Verify `brew` commands work after fresh shell
- [ ] **install.sh:** Run on clean macOS install (or test with `--dry-run`)
- [ ] **Aliases:** Check all aliases with `which aliasname` on both platforms
- [ ] **Functions:** Source .zshrc and call functions manually on both platforms
- [ ] **PATH:** `echo $PATH | tr ':' '\n'` shows expected order on both

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Tools not found | LOW | Install via Homebrew, add to PATH |
| sed in-place fails | MEDIUM | Reinstall file from git, fix script |
| Color output broken | LOW | Update alias with correct flags |
| Hardcoded paths | HIGH | Find and replace, test everywhere |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Tool differences | Phase 1: Platform detection | Test aliases on both |
| Homebrew paths | Phase 1: PATH setup | `which brew` works |
| Hardcoded paths | Phase 1: Variables | Test on different usernames |
| sed compatibility | Phase 2: Scripts | Run install.sh on both |

---
*Pitfalls research for: Cross-platform dotfiles*
*Researched: 2026-04-13*
