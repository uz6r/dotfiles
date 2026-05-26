# Pre-Reset Checklist

**Purpose:** Document everything you must do on your LOCAL machine before wiping it.
This is NOT about the dotfiles repo — it's about your current machine's local state.

**Status:** Complete when you've backed up everything you need and securely deleted
everything you don't.

- - -

## ⚠ Must Do Before Wipe

### 1. SSH Keys

- [ ] Backup private keys: `cp -r ~/.ssh ~/ssh-backup-$(date +%Y%m%d)`
- [ ] Verify backup contains: `id_ed25519`, `id_rsa`, `id_ed25519.pub`, `id_rsa.pub`, `config`
- [ ] Encrypt backup: `tar czf ssh-keys.tar.gz ~/ssh-backup-*` then store in password manager
- [ ] OR copy to another machine via scp/rsync

### 2. Git Configuration

- [ ] Backup local git config: `cp ~/.gitconfig.local ~/gitconfig-local-backup`
- [ ] Note: dotfiles `.gitconfig` is already tracked — only .gitconfig.local is machine-specific
- [ ] Check for git credentials: `git config --global --list | grep credential`

### 3. Shell History

- [ ] Run: `bin/audit-workflow --output WORKFLOW.md` (already done if you're reading this)
- [ ] Review WORKFLOW.md — does it capture everything you need?
- [ ] Raw history backup (optional): `cp ~/.zsh_history ~/zsh-history-backup`

### 4. Environment Files

- [ ] Check for `.env` files: `find /home -name '.env*' -not -path '*/node_modules/*' 2>/dev/null`
- [ ] Check for `.npmrc`: `cat ~/.npmrc` (may contain tokens)
- [ ] Check for netrc: `cat ~/.netrc 2>/dev/null` (may contain passwords)
- [ ] Back up API keys from projects: `find ~/uz6r -name '.env*' -not -path '*/node_modules/*' 2>/dev/null`

### 5. Private Directory

- [ ] Review `~/dotfiles/private/` for anything to keep
- [ ] Run `make audit-home` for a comprehensive scan
- [ ] After review: `rm -rf ~/dotfiles/private/`

### 6. Browser Data

- [ ] Export bookmarks (if needed)
- [ ] Export saved passwords (if needed)
- [ ] Sync browser profiles if using browser sync

### 7. Package Lists (for macOS migration)

- [ ] Homebrew: `brew bundle dump --file=~/brew-backup/Brewfile`
- [ ] npm global packages: `npm list -g --depth=0 > ~/npm-global-backup.txt`
- [ ] pip packages: `pip list > ~/pip-backup.txt`
- [ ] cargo packages: `cargo install --list > ~/cargo-backup.txt`
- [ ] Snap packages: `snap list > ~/snap-backup.txt`

### 8. Project Directories

- [ ] Review: `ls ~/uz6r/` — which projects need backup?
- [ ] Review: `ls ~/Courtsite/` — anything to archive?
- [ ] Check unpushed commits: `for d in ~/uz6r/*/; do (cd "$d" && git status 2>/dev/null && echo "---"); done`

### 9. Machine-Specific Config

- [ ] Review: `cat ~/.zshrc.local` (remove or archive)
- [ ] Review: `cat ~/.gitconfig.local` (backup name/email/signingkey)
- [ ] Check for other dotfiles: `ls -la ~/ | grep '^\..*rc\|^\..*conf'`

- - -

## ✅ Post-Wipe Rebuild

After clean OS install:

1. Clone dotfiles: `git clone git@github.com:uzr/dotfiles.git ~/uz6r/dotfiles`
2. Run bootstrap: `cd ~/uz6r/dotfiles && make bootstrap`
3. Verify: `make doctor` — should pass clean
4. Install gitleaks (needed for pre-commit): `brew install gitleaks`
5. Restore SSH keys from backup
6. Restore `.gitconfig.local` from backup
7. Run `make verify` to confirm everything works

- - -

> **Last updated:** 2026-05-26
> **See also:** `make doctor`, `make public-ready`, `make audit-home`
