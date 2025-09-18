# dotfiles

[![ci](https://github.com/uz6r/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/uz6r/dotfiles/actions/workflows/ci.yml)

my personal dotfiles managed with [GNU stow](https://www.gnu.org/software/stow/) and a `Makefile` workflow.  
includes linting/formatting, backups, and CI checks.

## why

because i am not about to waste hours rebuilding my setup from scratch  
one day i will forget my laptop somewhere and when that happens i want to clone this repo, hit `make bootstrap`, and boom my shell, my aliases, my shortcuts, all back like nothing happened

this whole thing started because i just wanted to mess with my zsh theme  
now it is a full blown infra-as-code situation for my laptop

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
make format     # lint + format (auto-installs tools if missing)
make ci-check   # simulate CI (strict lint + check diffs)
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

## ci workflow

github actions runs `make ci-check`, which:

1. runs all formatters
2. runs strict yamllint (using .yamllint.yaml)
3. fails if git diff shows changes (you must commit formatted files)

local:

```sh
make ci-check   # test the same checks CI will run
```

## notes

- machine-specific secrets go in ~/.zshrc.local or ~/.gitconfig.local
- add scripts to bin/ to make them available globally
- all configs are symlinked into $HOME via stow
- backups of existing files go into ~/dotfiles_backup before linking
- powerlevel10k is used for zsh theme, with config stored in zsh/.p10k.zsh
