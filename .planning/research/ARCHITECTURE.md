# Architecture Research

**Domain:** Cross-platform zsh dotfiles
**Researched:** 2026-04-13
**Confidence:** HIGH

## Recommended Structure

### Current Structure (Works)

```
dotfiles/
├── zsh/
│   ├── .zshrc           # Main config
│   └── .p10k.zsh        # Theme
├── git/
│   └── .gitconfig
├── nvim/
│   └── ...
└── install.sh           # Bootstrap
```

### Adding Platform-Specific Structure

```
dotfiles/
├── zsh/
│   ├── .zshrc           # Shared config
│   ├── .zshrc.darwin    # macOS specific (sourced at end)
│   ├── .zshrc.linux     # Linux specific (sourced at end)
│   ├── .p10k.zsh
│   └── platform/        # Optional: cleaner separation
│       ├── darwin.zsh
│       └── linux.zsh
└── install.sh
```

**Recommended approach:** Keep it simple. Use inline guards instead of separate files for this project.

## Platform Detection Patterns

### Pattern 1: Inline Conditional

```zsh
# Clipboard
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias copy='pbcopy'
  alias paste='pbpaste'
else
  alias copy='xclip -selection clipboard -i'
  alias paste='xclip -selection clipboard -o'
fi
```

### Pattern 2: Function with Detection

```zsh
is_darwin() {
  [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}

# Usage:
if is_darwin; then
  # macOS specific
fi
```

### Pattern 3: Platform File Sourcing

```zsh
# At end of .zshrc
local platform_file="${DOTFILES_DIR:-$HOME/uz6r/dotfiles}/zsh/platforms/$(uname -s | tr '[:upper:]' '[:lower:]').zsh"
if [ -f "$platform_file" ]; then
  source "$platform_file"
fi
```

**Recommendation:** Pattern 1 for simple aliases, Pattern 2 for complex logic.

## Sourcing Order

```zsh
# 1. OPENSPEC (if using)
fpath=("/home/uzer/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit && compinit

# 2. oh-my-zsh base
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git sudo web-search ...)
source $ZSH/oh-my-zsh.sh

# 3. PATH configuration
export PATH=...

# 4. Shell behavior
setopt ...
zstyle ...

# 5. Generic aliases (platform-agnostic)
alias ll='ls -lah --color=auto'
alias ..='cd ..'

# 6. Utility functions (platform-agnostic)
mkcd() { mkdir -p "$1" && cd "$1"; }

# 7. Platform-specific aliases
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias copy='pbcopy'
  alias paste='pbpaste'
  alias open='open'  # native on macOS
else
  alias copy='xclip -selection clipboard -i'
  alias paste='xclip -selection clipboard -o'
  alias open='xdg-open'
fi

# 8. Optional plugins
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# 9. Local overrides
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
```

## Best Practices

### DO

- Check `uname -s` at the top, store in a variable if used multiple times
- Keep platform-specific code grouped together
- Use `$HOME` instead of hardcoded paths
- Test syntax with `zsh -n` after changes

### DON'T

- Mix platform-specific and generic code randomly
- Use GNU-specific flags without checks
- Assume tools exist (use `command -v` or `which`)
- Put secrets or machine-specific config in shared files

## Homebrew Detection Pattern

```zsh
# Add to .zshrc, early in PATH section

# Homebrew detection (works on both macOS and Linux)
if [[ "$(uname -s)" == "Darwin" ]]; then
  # macOS
  if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon
    export HOMEBREW_PREFIX="/opt/homebrew"
  else
    # Intel
    export HOMEBREW_PREFIX="/usr/local"
  fi
elif command -v brew >/dev/null 2>&1; then
  # Linux with Homebrew installed
  export HOMEBREW_PREFIX="$(brew --prefix)"
fi

# Add to PATH if Homebrew exists
if [ -n "$HOMEBREW_PREFIX" ] && [ -d "$HOMEBREW_PREFIX/bin" ]; then
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
fi
```

## Anti-Patterns

### Anti-Pattern 1: Testing for "not Linux"

```zsh
# BAD
if [[ "$(uname -s)" != "Linux" ]]; then
  # Assumes anything not Linux is macOS
fi
```

```zsh
# GOOD
if [[ "$(uname -s)" == "Darwin" ]]; then
  # Explicit Darwin check
fi
```

### Anti-Pattern 2: Checking for tool absence

```zsh
# BAD - assumes Linux if macOS tool missing
if ! command -v pbcopy >/dev/null; then
  alias pbcopy='xclip...'
fi
```

```zsh
# GOOD - check platform explicitly
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias copy='pbcopy'
else
  alias copy='xclip...'
fi
```

---
*Architecture research for: Cross-platform dotfiles*
*Researched: 2026-04-13*
