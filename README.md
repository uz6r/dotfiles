# dotfiles

my personal dotfiles managed with [GNU stow](https://www.gnu.org/software/stow/)

## bootstrap

```sh
git clone git@github.com:yourname/dotfiles.git ~/dotfiles
cd ~/dotfiles
make bootstrap
```

## usage

```sh
make help       # list available commands
make bootstrap  # install stow + link dotfiles
make update     # pull latest and relink
make clean      # remove symlinks created by stow
make status     # show git status
make format     # lint and format dotfiles (auto-installs tools if missing)
```

## directory structure

```python
dotfiles/
├── .gitignore     # ignore history, local overrides, swap files
├── LICENSE        # license file (MIT by default)
├── Makefile       # make shortcuts (bootstrap, update, clean, status, help)
├── README.md      # documentation
├── bin/           # personal scripts (symlinked into ~/bin)
├── git/           # git configs (.gitconfig etc.)
├── install.sh     # bootstrap script (runs stow, used by make)
├── nvim/          # neovim configs (.config/nvim/init.vim)
└── zsh/           # zsh configs (.zshrc, themes, aliases)
```

## linting & formatting

- make format does both linting and formatting:
- shell scripts linted with shellcheck, auto-formatted with shfmt
- zsh configs syntax-checked with zsh -n (not auto-formatted)
- yaml linted with yamllint, formatted with prettier
- json validated with jq, formatted with prettier
- markdown formatted with prettier

## notes

- machine-specific secrets go in ~/.zshrc.local or ~/.gitconfig.local
- add scripts to bin/ to make them available globally
- all configs are symlinked into $HOME via stow
- backups of existing files go into ~/dotfiles_backup before linking
- powerlevel10k is used for zsh theme, with config stored in zsh/.p10k.zsh
