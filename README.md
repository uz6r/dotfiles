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

## notes

- machine-specific secrets go in ~/.zshrc.local or ~/.gitconfig.local
- add scripts to bin/ to make them available globally
