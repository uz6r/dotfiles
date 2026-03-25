# Architecture

## Pattern: Dotfiles as Infrastructure-as-Code

This repository uses GNU Stow for symlink-based dotfile management. Each subdirectory represents a package that gets symlinked to `$HOME`.

## Entry Points

| Entry Point | Purpose |
|-------------|---------|
| `Makefile` | Primary orchestration - bootstrap, lint, format, CI |
| `install.sh` | Bootstrap script - installs stow, creates symlinks |
| `.github/workflows/ci.yml` | CI pipeline |

## Data Flow

```
User runs: make bootstrap
    ↓
install.sh checks for stow → installs if missing
    ↓
stow -R -t $HOME zsh git nvim bin tmux
    ↓
Creates symlinks: ~/.zshrc → dotfiles/zsh/.zshrc
                   ~/.gitconfig → dotfiles/git/.gitconfig
                   ~/.config/nvim → dotfiles/nvim/.config/nvim
                   ~/bin/* → dotfiles/bin/*
                   ~/.tmux.conf → dotfiles/tmux/.tmux.conf
```

## Layer Separation

1. **Bootstrap Layer** - `Makefile`, `install.sh`
2. **Config Layer** - Individual tool configs (zsh, git, nvim, tmux)
3. **Script Layer** - `bin/` - Executable scripts
4. **CI Layer** - `.github/workflows/ci.yml`, `.githooks/`

## Abstractions

- **`Makefile`** - Abstracts package manager differences, provides consistent commands
- **Stow** - Abstracts symlink creation, allows per-package management
- **Template configs** - `.zshrc.local`, `.gitconfig.local` for machine-specific overrides

## Configuration Loading Order

### Zsh
```
~/.zshrc (main)
  → Oh My Zsh base
  → Custom aliases/functions
  → p10k theme (if exists)
  → Optional plugins
  → ~/.zshrc.local (machine-specific)
```

### Git
```
~/.gitconfig
  → ~/.gitconfig.local (machine-specific, via include)
```

### Neovim
```
~/.config/nvim/init.lua
  → Lazy.nvim bootstrap
  → Plugin configuration
  → gruvbox theme
```