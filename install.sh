#!/bin/sh
set -e

backup_dir="$HOME/dotfiles_backup"
mkdir -p "$backup_dir"

echo "→ installing stow (if missing)"
if command -v apt >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y stow
elif command -v brew >/dev/null 2>&1; then
  brew install stow
fi

echo "→ previewing what will be linked"
stow -nv -t "$HOME" zsh git nvim bin || true

echo "→ backing up conflicts into $backup_dir"
for target in .zshrc .gitconfig .config/nvim/init.vim; do
  if [ -e "$HOME/$target" ] && [ ! -L "$HOME/$target" ]; then
    echo "   backing up $HOME/$target"
    mkdir -p "$backup_dir/$(dirname "$target")"
    mv "$HOME/$target" "$backup_dir/$target"
  fi
done

echo "→ linking dotfiles (restow mode)"
stow -v -R -t "$HOME" zsh git nvim bin

echo "✅ done — restart your shell"
