# STRUCTURE.md — Directory Layout

**Focus:** Directory structure, key locations, and naming conventions

## Directory Structure

```
dotfiles/
├── Makefile              # Task automation (bootstrap, lint, format)
├── install.sh            # Bootstrap script
├── README.md            # Documentation
├── LICENSE              # MIT license
├── .gitignore           # Git ignore patterns
├── .editorconfig        # Editor config
├── .luacheckrc          # Lua linting config
├── .yamllint.yaml       # YAML linting config
├── .github/
│   └── workflows/
│       └── ci.yml       # GitHub Actions CI
├── .githooks/
│   └── pre-commit       # Pre-commit hook
├── .planning/           # GSD planning docs (not stowed)
│   ├── config.json
│   ├── PROJECT.md
│   ├── REQUIREMENTS.md
│   ├── ROADMAP.md
│   ├── STATE.md
│   ├── research/
│   ├── phases/
│   └── codebase/
├── zsh/                 # → ~/.zshrc
│   ├── .zshrc           # Main shell config
│   └── .p10k.zsh        # Powerlevel10k config
├── git/                 # → ~/.gitconfig
│   └── .gitconfig       # Git configuration
├── nvim/                # → ~/.config/nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua # Neovim config
│           └── lazy-lock.json
├── bin/                 # → ~/bin/
│   ├── sinar-pi-setup       # Build sinarclient tarball
│   └── sinar-pi-wifi-setup  # Pi wifi setup
├── tmux/                # → ~/.tmux.conf
│   └── .tmux.conf       # tmux config
└── scripts/             # Utility scripts (not symlinked)
    └── update-migration-pr
```

## Key Locations

| Path | Purpose |
|------|---------|
| `zsh/.zshrc` | Main shell config (415 lines) |
| `nvim/.config/nvim/init.lua` | Neovim config (464 lines) |
| `git/.gitconfig` | Git config (63 lines) |
| `tmux/.tmux.conf` | tmux config (67 lines) |
| `bin/` | Personal scripts symlinked to `~/bin` |
| `.planning/` | Project planning docs (excluded from stow) |

## Naming Conventions

- **Directories**: lowercase, hyphenated (e.g., `bin/`, `zsh/`)
- **Config files**: prefixed with `.` (e.g., `.zshrc`, `.gitconfig`)
- **Scripts**: lowercase, hyphenated (e.g., `sinar-pi-setup`)
- **Stow packages**: match target filename (e.g., `zsh/` → `.zshrc`)

## Stow Packages

| Package | Target | Source Files |
|---------|--------|--------------|
| `zsh/` | `$HOME/.zshrc` | `.zshrc`, `.p10k.zsh` |
| `git/` | `$HOME/.gitconfig` | `.gitconfig` |
| `nvim/` | `$HOME/.config/nvim/` | `init.lua`, lazy config |
| `bin/` | `$HOME/bin/` | Scripts |
| `tmux/` | `$HOME/.tmux.conf` | `.tmux.conf` |