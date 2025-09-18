cat > install.sh <<'EOF'
#!/bin/sh
set -e

echo "→ installing stow (if missing)"
if command -v apt >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y stow
elif command -v brew >/dev/null 2>&1; then
  brew install stow
fi

echo "→ linking dotfiles"
cd "$(dirname "$0")"
stow zsh git nvim bin

echo "✅ done — restart your shell"
EOF
chmod +x install.sh

