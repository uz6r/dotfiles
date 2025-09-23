#!/bin/sh
set -e

backup_dir="$HOME/dotfiles_backup"
mkdir -p "$backup_dir"

echo "installing stow (if missing)"
if command -v apt >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y stow
elif command -v brew >/dev/null 2>&1; then
  brew install stow
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
stow -v -R -t "$HOME" zsh git nvim bin tmux || true

echo "✅ done. restart your shell (merge conflicts manually if stow warned)"
