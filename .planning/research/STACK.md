# Stack Research

**Domain:** Dotfiles cleanup and decoupling (zsh config, scripts, cross-platform)
**Researched:** 2026-04-30
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| zsh | 5.x+ | Shell configuration | Existing shell - no change needed. Cleanup focuses on removing company-specific content, not replacing the shell. |
| GNU Stow | 2.x+ | Symlink management | Existing tool in project. Use `stow -D` to unstow packages, `stow -R` to restow after cleanup. Already in Makefile. |
| ripgrep (rg) | 13.x+ | Search and identify company references | 100x faster than grep, respects .gitignore, PCRE2 regex support. Essential for finding all Courtsite references across the repo. |
| git-filter-repo | 2.38+ | Git history cleanup (if needed) | Official replacement for `git filter-branch`. Use if company data leaked into git history and needs complete removal. Python-based, requires fresh clone. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| repgrep (rgr) | 0.2.x+ | Interactive find-and-replace | When you need to preview and selectively replace Courtsite references across multiple files. Interactive TUI built on ripgrep. |
| sd | 0.7+ | Simple search and replace | Alternative to sed for simpler find-replace operations. More intuitive syntax than sed, cross-platform (GNU/BSD compatible). |
| gitleaks | 8.x+ | Pre-push secret scanning | Run before pushing to verify no company secrets/credentials remain in the repo. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| GNU sed | In-place file replacement (Linux) | `sed -i 's/foo/bar/g'` for simple replacements. Already available on Linux. |
| BSD sed | In-place file replacement (macOS) | `sed -i '' 's/foo/bar/g'` - different syntax from GNU sed. Use `rg` + conditional logic. |
| git-extras | Additional git commands | Provides `git-delete-merged-branches` etc. Not required but useful for cleanup. |
| chkstow | Stow target maintenance | Ships with GNU Stow 2.x+. Run `chkstow -b` to find broken symlinks after cleanup. |

## Installation

```bash
# Core tools (likely already installed)
# ripgrep - search for company references
brew install ripgrep                    # macOS
sudo apt install ripgrep                 # Ubuntu/Debian

# repgrep - interactive find-replace (optional)
brew install repgrep                     # macOS
cargo install repgrep                    # Any platform via Rust

# sd - simpler alternative to sed (optional)
brew install sd                          # macOS
cargo install sd                         # Any platform via Rust

# git-filter-repo - history rewriting (only if needed)
pip install git-filter-repo               # Any platform (Python)
brew install git-filter-repo              # macOS
sudo apt install git-filter-repo         # Ubuntu 22.04+

# gitleaks - secret scanning (optional, for verification)
brew install gitleaks                    # macOS
curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/scripts/install.sh | sh  # Linux
```

## Cleanup Strategy

### Phase 1: Identify All Company References

```bash
# Use ripgrep to find all Courtsite references
cd ~/uz6r/dotfiles
rg -i "courtsite|sinar|enjin|co_utsite_dir" --type-add 'config:*.{zsh,sh,md}' -t config

# Find all company-related scripts in bin/
rg "courtsite|sinar|enjin" bin/

# Check for COURTSITE_DIR environment variable usage
rg "COURTSITE_DIR" 
```

### Phase 2: Remove Company-Specific Content

#### A. Clean .zshrc (main file)

The current `.zshrc` has two sections marked for removal:
- Lines 153-184: `localdev()` function with Courtsite directories
- Lines 312-328: Commented Courtsite aliases (already commented out)

**Action:** Remove lines 153-184 entirely. These contain the `localdev()` function that references `COURTSITE_DIR` and multiple enjin directories.

```bash
# Preview what will be removed (lines 153-184)
sed -n '153,184p' zsh/.zshrc

# Remove the localdev function block
# Lines 153-184 contain the TODO Courtsite local dev section
# After removal, verify no Courtsite references remain:
rg -i "courtsite|localdev|enjin" zsh/.zshrc
```

#### B. Clean .zshrc.local (already properly separated)

The `.zshrc.local` file already contains Courtsite aliases in a separate file that is:
- Sourced conditionally (line 411-413 in .zshrc)
- Not tracked by git (should be in .gitignore)

**Action:** Verify `.zshrc.local` is in `.gitignore`. If not, add it:

```bash
# Check if .zshrc.local is ignored
git check-ignore -v zsh/.zshrc.local || echo "NOT IGNORED - add to .gitignore"

# Add to .gitignore if needed
echo ".zshrc.local" >> .gitignore
```

#### C. Remove Company Scripts from bin/

Two scripts to remove:
- `bin/sinar-pi-setup`
- `bin/sinar-pi-wifi-setup`

**Action:** 
```bash
# Remove from stow management first
stow -d ~/uz6r/dotfiles -t ~ -D bin   # Unstow bin package

# Remove the files
rm ~/uz6r/dotfiles/bin/sinar-pi-setup
rm ~/uz6r/dotfiles/bin/sinar-pi-wifi-setup

# Restow bin package (without the removed scripts)
stow -d ~/uz6r/dotfiles -t ~ bin
```

#### D. Check for Remaining References

```bash
# Search entire repo for any remaining company references
rg -i "courtsite|sinar|enjin|co_utsite" --hidden

# Check git history (if concerned about leaked data)
git log --all --oneline --grep="courtsite\|sinar\|enjin"

# If company data found in git history, use git-filter-repo:
# WARNING: Rewrites history - coordinate with any collaborators
# git filter-repo --invert-paths --path-glob '*sinar*' --path-glob '*courtsite*'
```

### Phase 3: Verify and Test

```bash
# Run existing test suite
make test

# Verify zsh config loads without errors
zsh -x zsh/.zshrc 2>&1 | grep -i error

# Check for broken symlinks
chkstow -b -t ~

# Optional: Scan for leaked secrets
gitleaks detect --source ~/uz6r/dotfiles --verbose
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| ripgrep (rg) | grep | Only if ripgrep unavailable. grep is slower, doesn't respect .gitignore by default. |
| ripgrep + sed | repgrep (rgr) | Use repgrep for interactive, preview-based replacement. Better for reviewing changes before applying. |
| git-filter-repo | BFG Repo-Cleaner | BFG is simpler for basic file deletions but less flexible. git-filter-repo is officially recommended by GitHub. |
| GNU Stow | chezmoi | chezmoi has built-in templating and encryption. Overkill for this cleanup - Stow already in use. |
| Manual edit | `sed -i` inline | For this small cleanup, manual edit with review is safer than automated replacement. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `git filter-branch` | Deprecated, slow, error-prone. | `git-filter-repo` |
| Blind find-replace across all files | May break config syntax, break symlinks. | Targeted ripgrep + manual review |
| Removing `.zshrc.local` from repo | It's already the right pattern - untracked local overrides. | Keep pattern, just ensure it's gitignored |
| `rm -rf` on bin/ without unstowing | Leaves broken symlinks in ~. | `stow -D` first, then remove files |

## Stack Patterns by Variant

**If keeping company aliases for personal use:**
- Move them to `~/.zshrc.local` (already done)
- Ensure `.zshrc.local` is in `.gitignore`
- Source conditionally in `.zshrc` (already implemented at lines 411-413)

**If complete removal needed:**
- Delete `bin/sinar-*` scripts
- Remove `localdev()` function from `.zshrc` (lines 153-184)
- Remove commented aliases (lines 312-328 - already commented out)
- Verify with `rg` no references remain

**If git history cleanup needed (company data leaked):**
- Use `git filter-repo --sensitive-data-removal`
- Requires fresh clone, rewrites all history
- Coordinate with collaborators (force push required)
- Rotate any exposed credentials immediately

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| ripgrep 13.x | All modern shells | No shell dependencies, standalone binary |
| git-filter-repo 2.38+ | Git 2.24+ | Requires Python 3.5+ |
| GNU Stow 2.x | Any POSIX system | Perl-based, widely available |
| repgrep 0.2.x | ripgrep 13.x+ | Requires ripgrep installed first |

## Sources

- [Context7: /burntsushi/ripgrep](https://github.com/burntsushi/ripgrep) — Search syntax, --replace flag, FAQ (HIGH confidence)
- [GitHub Docs: Removing sensitive data](https://docs.github.com/articles/remove-sensitive-data) — git-filter-repo usage, force push workflow (HIGH confidence)
- [git-filter-repo docs](https://www.mintlify.com/newren/git-filter-repo/) — Path filtering, sensitive data removal (HIGH confidence)
- [GNU Stow manual](https://www.gnu.org/software/stow/manual/) — Delete/unstow operations, chkstow utility (HIGH confidence)
- [StackOverflow: .zshrc.local pattern](https://stackoverflow.com/questions/67375498/) — Not a standard zsh file, but common convention in dotfiles (MEDIUM confidence)
- [timkicker/dotfiles security guide](https://github.com/timkicker/dotfiles/security) — Pre-push checklist, rg scanning (HIGH confidence)
- [Websearch: dotfiles cleanup best practices 2026] — General patterns for local file separation (MEDIUM confidence)

---
*Stack research for: Dotfiles cleanup and Courtsite decoupling*
*Researched: 2026-04-30*
