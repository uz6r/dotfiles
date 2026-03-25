# Structure

## Directory Layout

```
dotfiles/
├── .github/workflows/ci.yml   # GitHub Actions CI
├── .githooks/pre-commit        # Pre-commit hook
├── .editorconfig               # Editor config
├── .gitignore                  # Git ignore patterns
├── .luacheckrc                 # Lua linting config
├── .yamllint.yaml              # YAML linting config
├── README.md                   # Documentation
├── LICENSE                     # MIT License
├── Makefile                    # Task runner
├── install.sh                 # Bootstrap script
├── bin/
│   └── sinar-pi-setup          # Sinar Pi deployment script
├── git/
│   └── .gitconfig              # Git configuration
├── nvim/
│   └── .config/nvim/
│       ├── init.lua            # Neovim main config
│       └── lazy-lock.json      # Plugin lock file
├── tmux/
│   └── .tmux.conf              # Tmux configuration
└── zsh/
    ├── .zshrc                  # Zsh configuration
    └── .p10k.zsh               # Powerlevel10k theme
```

## Key Locations

| File | Purpose |
|------|---------|
| `Makefile` | All tasks: bootstrap, update, clean, status, lint, format, ci-check |
| `install.sh` | Stow-based bootstrap - creates symlinks |
| `zsh/.zshrc` | Main shell config - 346 lines of aliases, functions, paths |
| `nvim/.config/nvim/init.lua` | Neovim config - 410 lines, lazy.nvim, plugins, keymaps |
| `tmux/.tmux.conf` | Tmux config - 67 lines, key bindings, status bar |
| `git/.gitconfig` | Git config - aliases, merge tools, editor |
| `.github/workflows/ci.yml` | CI pipeline - runs make format + yamllint + diff check |
| `.githooks/pre-commit` | Local git hooks |
| `bin/sinar-pi-setup` | Bash script for Sinar Pi device setup |

## Naming Conventions

- **Config files**: Hidden files (prefixed with `.`) in home directory after symlinking
- **Directories**: Lowercase, descriptive (zsh, git, nvim, tmux, bin)
- **Scripts**: Descriptive names, lowercase with hyphens (sinar-pi-setup)
- **Make targets**: Lowercase, descriptive (bootstrap, update, clean, lint, format)

## Symlink Targets

When stow runs, it creates these symlinks:
- `~/.zshrc` → `dotfiles/zsh/.zshrc`
- `~/.gitconfig` → `dotfiles/git/.gitconfig`
- `~/.config/nvim/` → `dotfiles/nvim/.config/nvim/`
- `~/.tmux.conf` → `dotfiles/tmux/.tmux.conf`
- `~/bin/*` → `dotfiles/bin/*`