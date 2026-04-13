# Feature Research

**Domain:** Cross-platform zsh dotfiles
**Researched:** 2026-04-13
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Must Have)

Features that must work on both platforms.

| Feature | Linux | macOS | Implementation |
|---------|-------|-------|----------------|
| Clipboard alias | `xclip` | `pbcopy` | Unified `copy` alias |
| Clipboard paste | `xclip -selection clipboard -o` | `pbpaste` | Unified `paste` alias |
| Open command | `xdg-open` | `open` | Alias to `xdg-open` on Linux |
| Package manager | `apt` (optional) | `brew` | Just `brew` if using Homebrew everywhere |
| Homebrew detection | Path varies | Path varies | Shell snippet to detect |
| Shell reload | `source ~/.zshrc` | Same | Works both places |

### Differentiators (Nice to Have)

Features that improve the experience.

| Feature | Benefit | Complexity | Notes |
|---------|---------|------------|-------|
| Auto-detect platform | Fewer manual changes | LOW | `uname -s` check |
| Smart PATH | No duplicates | LOW | PATH deduplication |
| Platform-specific plugins | Better UX | MEDIUM | Load conditionally |
| System info commands | `sysinfo` function | LOW | Unified system info |

## Platform Detection

### Primary Method: `uname -s`

```zsh
if [[ "$(uname -s)" == "Darwin" ]]; then
  # macOS specific
elif [[ "$(uname -s)" == "Linux" ]]; then
  # Linux specific
fi
```

### Secondary: macOS Version (if needed)

```zsh
sw_vers -productVersion  # e.g., 14.0
sw_vers -productName     # e.g., macOS
```

### Linux Distribution (rarely needed)

```zsh
# Only if Ubuntu-specific behavior needed
if [ -f /etc/os-release ]; then
  source /etc/os-release
  if [[ "$ID" == "ubuntu" ]]; then
    # Ubuntu specific
  fi
fi
```

## Aliases to Update

### Current Linux-only (need macOS equivalents)

| Current | Platform | Should Be | Fix |
|---------|----------|-----------|-----|
| `alias pbcopy='xclip...'` | Linux | macOS has built-in `pbcopy` | Remove Linux alias, add conditional |
| `alias pbpaste='xclip...'` | Linux | macOS has built-in `pbpaste` | Remove Linux alias, add conditional |
| `alias ports='netstat...'` | Linux | macOS syntax different | Use `lsof` instead (works both) |
| `alias localip='ip addr...'` | Linux | macOS uses `ifconfig` | Platform-specific alias |

### New Aliases to Add

| Alias | Linux | macOS | Notes |
|-------|-------|-------|-------|
| `open` | `xdg-open` | native | Standardize on one name |
| `copy` | `xclip -selection clipboard` | `pbcopy` | Unified clipboard copy |
| `paste` | `xclip -selection clipboard -o` | `pbpaste` | Unified clipboard paste |

## Functions to Update

### `killport()`

Current uses `lsof -ti:$1` which works on both. **No changes needed.**

### `localdev()`

References Courtsite paths — Linux-only project. Keep as-is or wrap in Linux check.

### `myip()` / `localip()`

```zsh
alias myip='curl -s ifconfig.me && echo'  # Works on both

alias localip() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ifconfig | grep "inet " | grep -v 127.0.0.1
  else
    ip addr show | grep "inet " | grep -v 127.0.0.1
  fi
}
```

## Optional: FZF Configuration

FZF works on both. Already configured in .zshrc:
```zsh
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
```

**On macOS:** `brew install fzf` and run `/opt/homebrew/opt/fzf/install` (or `/usr/local/opt/fzf/install`)

## Feature Dependencies

```
Platform Detection (uname)
    └── All platform-specific aliases/functions
```

## MVP Definition

### Launch With (v1)

- [ ] Platform detection in .zshrc
- [ ] Unified clipboard aliases (copy/paste)
- [ ] Unified open command
- [ ] Fixed network tools (localip, ports)
- [ ] Homebrew path detection for both platforms
- [ ] install.sh works on both (apt/brew)

### Add After (v2)

- [ ] System info function (sysinfo)
- [ ] Auto-install common tools per platform
- [ ] FZF setup integration

---
*Feature research for: Cross-platform dotfiles*
*Researched: 2026-04-13*
