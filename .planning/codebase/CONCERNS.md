# Concerns

## Technical Debt

### Medium Priority

1. **No plugin version pinning in Neovim** - `init.lua` uses `lazy.nvim` without specific versions, relying on default branch/branch=stable. Could cause unexpected updates.

2. **Scripts without tests** - `bin/sinar-pi-setup` is a 144-line script with no test coverage. Complex logic for config creation and packaging.

3. **Hardcoded paths** - Many configs have hardcoded paths (e.g., `${COURTSITE_DIR:-$HOME/Courtsite}`) that assume specific directory structure.

### Low Priority

4. **No backup verification** - `make status` checks symlinks but doesn't verify backed-up files are still accessible.

5. **CI installs from scratch** - GitHub Actions installs all tools every run, could be slower than caching.

## Known Issues

### Potential Issues

1. **Lazy.nvim GitHub rate limits** - Bootstrap clones lazy.nvim from GitHub; could fail if rate-limited (rare).

2. **p10k instant prompt caching** - Uses XDG_CACHE_HOME; if cache is corrupted, prompt may break.

3. **fzf integration** - `.zshrc` sources `~/.fzf.zsh` if it exists; fzf not in dotfiles, so optional.

4. **Oh My Zsh updates** - `.zshrc` loads from `$HOME/.oh-my-zsh` - if OMZ updates break, shell may not load.

### Configuration Conflicts

1. **Neovim lazy-lock.json** - Tracked in git, but plugin versions determined by lazy.nvim defaults at install time.

2. **Machine-specific overrides** - `.zshrc.local` and `.gitconfig.local` are not tracked, making machine config invisible to version control.

## Security Concerns

### Low Risk

1. **Secrets in shell history** - `zsh/.zshrc` has no history protection; sensitive commands may be logged.

2. **API keys in environment** - If `~/.zshrc.local` contains secrets, they load on every shell start.

3. **Git hooks are local** - `.githooks/pre-commit` is tracked but runs locally without review.

## Fragile Areas

### High Fragility

1. **Install script dependencies** - `install.sh` assumes apt or brew; fails on other distributions (Arch, Fedora, etc.).

2. **Stow conflicts** - If target files exist and aren't symlinks, stow refuses to link (documented in install.sh but requires manual resolution).

3. **Oh My Zsh plugin loading** - If custom plugins directory doesn't exist, auto-load fails silently.

### Medium Fragility

4. **Node.js/pnpm paths** - Complex path detection logic in `.zshrc:312-337` for pnpm could miss some install methods.

5. **NVM loading** - `.zshrc:301-307` loads NVM from standard location; non-standard installs won't load.

## Performance Considerations

- Lazy.nvim loads plugins on demand, should be fast
- Treesitter installs parsers on first use
- p10k instant prompt speeds up shell startup

## Notes

- This is a personal dotfiles repo - some trade-offs are acceptable for personal convenience
- CI enforces formatting to prevent drift
- Machine-specific overrides in `.local` files are intentional (keep secrets local)