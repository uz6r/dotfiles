# CONCERNS.md — Technical Debt & Issues

**Focus:** Known issues, tech debt, security concerns, and fragile areas

## Known Issues

### 1. No Actual Tests
- **Severity:** Low
- **Issue:** No automated test suite for dotfiles functionality
- **Mitigation:** CI runs formatters/linters, manual validation via `make status`

### 2. Courtsite-Specific Aliases
- **Severity:** Low
- **Issue:** `.zshrc` contains Courtsite-specific aliases (`core`, `konsol`, `pelanggan`, etc.)
- **Impact:** Pollutes shell on non-Courtsite machines
- **Mitigation:** Could be moved to `.zshrc.local`

### 3. Localdev() Function is Linux-Only
- **Severity:** Low
- **Issue:** `localdev()` function wrapped in `if is_linux` but references Courstie paths
- **Location:** `.zshrc:154-184`
- **Impact:** Breaks on macOS if called

### 4. Hard-coded Paths
- **Severity:** Low
- **Issue:** Some paths hardcoded (e.g., `${DOTFILES_DIR:-$HOME/uz6r/dotfiles}`)
- **Impact:** Assumes specific directory structure

## Security Concerns

### 1. GitHub SSH URLs
- **Severity:** Info
- **Location:** `.gitconfig:62-63`
- **Issue:** Rewrites HTTPS URLs to SSH (`git@github.com:`)
- **Note:** Intended behavior for SSH key authentication

### 2. No Secrets in Repo
- **Severity:** Good
- **Mitigation:** Machine-specific secrets in `.zshrc.local` and `.gitconfig.local` (gitignored)

### 3. Pre-commit Runs Formatters
- **Severity:** Good
- **Note:** Auto-formats on commit, prevents inconsistent code

## Fragile Areas

| Area | Risk | Reason |
|------|------|--------|
| `.zshrc` (415 lines) | Medium | Large file, many conditional branches |
| Platform detection | Low | Simple `uname -s` check |
| Homebrew paths | Low | Well-tested by community |
| lazy.nvim bootstrap | Low | Standard lazy.nvim pattern |

## Tech Debt

1. **Oh-my-zsh dependency** — Heavy, but standard
2. **Powerlevel10k config** — Large `.p10k.zsh` file
3. **Plugin count** — 20+ neovim plugins, some may be unused

## Performance Concerns

- **Shell startup time** — zsh with oh-my-zsh + plugins can be slow
- **Lazy loading** — Some plugins (nvim-cmp, LSP) load on demand

## Areas for Improvement

1. Consider moving Courtsite-specific aliases to local config
2. Could add shell startup profiling to identify bottlenecks
3. Consider removing unused plugins from neovim config