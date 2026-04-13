# Stack Research

**Domain:** Cross-platform dotfiles (Linux/macOS)
**Researched:** 2026-04-13
**Confidence:** HIGH

## Package Managers

### Homebrew (Recommended for Both)

| Platform | Installation Path | Notes |
|----------|-------------------|-------|
| macOS | `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel) | Standard Homebrew |
| Linux | `/home/linuxbrew/.linuxbrew` or `~/.linuxbrew` | Linuxbrew, mostly compatible |

**Recommended approach:** Use Homebrew on both platforms. Most packages work.

```bash
# Detect Homebrew prefix
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
elif command -v brew >/dev/null 2>&1; then
  eval "$(brew --prefix)/bin/brew shellenv"
fi
```

### apt (Linux Only)

Not needed if using Homebrew everywhere, but useful for:
- System packages requiring root
- Desktop environment stuff

## System Tools Differences

| Tool | Linux | macOS | Unified Approach |
|------|-------|-------|------------------|
| Clipboard copy | `xclip -selection clipboard` | `pbcopy` | Alias both to same name |
| Clipboard paste | `xclip -selection clipboard -o` | `pbpaste` | Alias both |
| IP address | `ip addr` | `ifconfig` | Use `ip addr` on Linux, check `ifconfig` path on macOS |
| Network ports | `netstat -tulanp` | `lsof -i -P` | Use lsof (available on both) |
| Package manager | `apt` | `brew` | Use brew on both |
| Open URL/file | `xdg-open` | `open` | Alias `open` to `xdg-open` on Linux |
| Get external IP | `curl -s ifconfig.me` | Same | Works on both |
| User info | `whoami` | Same | Works on both |
| CPU info | `lscpu` | `sysctl hw.model` | Conditional alias |
| Memory info | `free -h` | `vm_stat` | Conditional alias |

## PATH Configuration

### Recommended Order

```zsh
# 1. System paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# 2. Homebrew paths (platform-specific)
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  else
    export PATH="/usr/local/bin:$PATH"
  fi
else
  # Linux Homebrew
  if [ -d "$HOME/.linuxbrew" ]; then
    export PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
  elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
  fi
fi

# 3. User local paths
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# 4. Package manager global bins
export PATH="$HOME/.npm-global/bin:$HOME/.local/share/pnpm:$PATH"
```

## Coreutils Differences

| Command | Linux (GNU) | macOS (BSD) | Fix |
|---------|-------------|-------------|-----|
| `date` | GNU version | BSD version | Different flags for `date +%s%3N` |
| `ls` | GNU with color | BSD with color flag | Use `-G` on macOS |
| `cp` | GNU flags | BSD flags | Test carefully |
| `sed` | GNU sed | BSD sed | `sed -i ''` vs `sed -i` |
| `tar` | GNU tar | BSD tar | Generally compatible |

**Recommendation:** Install GNU coreutils via Homebrew on macOS (`brew install coreutils`), use `g-prefix` commands for Linux-isms.

## Shell Check

| Check | Command | Notes |
|-------|---------|-------|
| Syntax check | `zsh -n ~/.zshrc` | Always run after changes |
| Shellcheck | `brew install shellcheck` on macOS | Not needed for zsh but useful |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `realpath` | Different flags on BSD | Use `readlink -f` |
| `stat -c` | GNU-specific | Use `stat -f` on macOS |
| `readlink -e` | GNU-specific | Check file exists before readlink |

---
*Stack research for: Cross-platform dotfiles*
*Researched: 2026-04-13*
