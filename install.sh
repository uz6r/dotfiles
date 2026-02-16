#!/bin/sh
set -e

backup_dir="$HOME/dotfiles_backup"
mkdir -p "$backup_dir"

echo "checking for stow"
if ! command -v stow >/dev/null 2>&1; then
  echo "installing stow..."
  if command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y stow
  elif command -v brew >/dev/null 2>&1; then
    brew install stow
  else
    echo "❌ stow not found and no package manager detected"
    echo "   please install stow manually: https://www.gnu.org/software/stow/"
    exit 1
  fi
else
  echo "✅ stow already installed"
fi

echo "previewing what will be linked"
stow -nv -t "$HOME" zsh git nvim bin tmux || true

echo "checking for conflicts (backups will be copies, nothing deleted)"
for target in .zshrc .gitconfig .config/nvim/init.lua; do
  if [ -e "$HOME/$target" ]; then
    if [ -L "$HOME/$target" ]; then
      echo "   skipping $HOME/$target (already symlinked)"
    else
      echo "   backing up $HOME/$target -> $backup_dir/$target"
      mkdir -p "$backup_dir/$(dirname "$target")"
      cp -p "$HOME/$target" "$backup_dir/$target"
      echo "   ⚠️  $HOME/$target still exists — stow may refuse to link it"
      echo "      (remove or merge manually before rerunning stow)"
    fi
  fi
done

echo "linking dotfiles (restow mode)"
if stow -v -R -t "$HOME" zsh git nvim bin tmux; then
  echo "✅ done. restart your shell to apply changes"
else
  echo "⚠️  stow encountered errors. check conflicts above and resolve manually"
  exit 1
fi

# Setup git hooks if in a git repo
if [ -d ".git" ]; then
  echo "setting up git hooks"
  git config core.hooksPath .githooks || true
  echo "✅ git hooks configured"
fi
