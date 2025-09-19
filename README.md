# dotfiles

[![ci](https://github.com/uz6r/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/uz6r/dotfiles/actions/workflows/ci.yml)

my personal dotfiles as infra-as-code managed with [GNU stow](https://www.gnu.org/software/stow/)

## why

because my dev environment shouldn’t be a snowflake. one clone + `make bootstrap` and i get the same setup anywhere.

## requirements

make sure the following are installed first:

- **git** → clone this repo
- **stow** → symlink configs
- **make** → run the workflow

for linting/formatting (`make setup` will install most automatically):

- **shellcheck** (apt/brew)
- **shfmt** (go install)
- **yamllint** (apt/brew)
- **jq** (apt/brew)
- **prettier** (npm global install)
- **luacheck** (luarocks)
- **stylua** (cargo or binary release)

you don’t need to remember these — just run:

```sh
make setup
```

and it will attempt to auto-install everything with your package manager. if something can’t be auto-installed (like prettier/stylua/luacheck), the makefile will tell you what to do.

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
make status     # check symlink status
make setup      # auto-install all lint/format tools
make format     # lint + format (auto-fix)
make lint       # lint only (no auto-fix)
make ci-check   # simulate CI (strict lint + check diffs)
```

## directory structure

```python
dotfiles/
├── .gitignore       # ignore history, local overrides, swap files
├── .luacheckrc      # tell luacheck about neovim globals (vim, etc.)
├── LICENSE          # license file (MIT by default)
├── Makefile         # make shortcuts (bootstrap, update, clean, status, lint/format)
├── README.md        # documentation
├── bin/             # personal scripts (symlinked into ~/bin)
├── git/             # git configs (.gitconfig etc.)
├── install.sh       # bootstrap script (runs stow, used by make)
├── nvim/            # neovim configs (.config/nvim/init.lua + lua modules)
└── zsh/             # zsh configs (.zshrc, .p10k.zsh, aliases)
```

## linting & formatting

- make format does both linting and formatting:
- shell scripts linted with shellcheck, auto-formatted with shfmt
- zsh configs syntax-checked with zsh -n (not auto-formatted)
- yaml linted with yamllint, formatted with prettier
- json validated with jq, formatted with prettier
- markdown formatted with prettier
- lua (neovim configs) linted with luacheck, formatted with stylua

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
