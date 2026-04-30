# Pitfalls Research

**Domain:** Dotfiles cleanup — removing company-specific (Courtsite/Sinar) configuration
**Researched:** 2026-04-30
**Confidence:** HIGH

## Executive Summary

Removing company-specific configuration from dotfiles requires surgical precision. The primary risks are: breaking shell startup (shell won't load), leaving stale references that cause confusion or errors, breaking cross-platform conditionals, and creating orphaned symlinks via GNU Stow. Courtsite-specific code in this repo is concentrated in `.zshrc` (localdev function, commented aliases, active sinar-pi aliases) and `bin/` (two large scripts). The cleanup must preserve the cross-platform detection logic (`is_darwin()`, `is_linux()`) and the conditional plugin loading that makes these dotfiles work on both Ubuntu and macOS.

## Critical Pitfalls

### Pitfall 1: Breaking Shell Startup via Incomplete Function Removal

**What goes wrong:**
Removing a function like `localdev()` from `.zshrc` but leaving a reference to it somewhere else (alias, another function, or a comment that gets uncommented later). Worst case: shell fails to load because of a syntax error introduced during removal.

**Why it happens:**
- Functions often have nested functions (`start_tmux_layout` inside `localdev`) — removing the outer function but missing the inner one leaves syntax errors if anything calls it
- Multi-line functions are easy to partially delete (missing closing braces)
- The `if is_linux; then ... fi` wrapper around `localdev()` might be left behind, causing empty conditional blocks

**How to avoid:**
1. Before editing, run `zsh -n .zshrc` to check syntax
2. Remove the entire block (lines 153-184) including the encapsulating `if is_linux; then ... fi`
3. After removal, run `zsh -n .zshrc` again before sourcing
4. Test in a new terminal tab before committing

**Warning signs:**
- Shell opens with no prompt or minimal prompt (Powerlevel10k didn't load)
- Error messages about missing commands or syntax errors on shell startup
- `localdev` command still exists but does nothing (partial removal)

**Phase to address:** Phase 1 (Clean .zshrc) — verify syntax before and after

---

### Pitfall 2: Leaving Stale PATH Entries

**What goes wrong:**
The `.zshrc` line 80 adds `HOME/uz6r/dotfiles/scripts` to PATH. After removing `bin/sinar-pi-setup` and `bin/sinar-pi-wifi-setup`, the scripts directory may be empty or only contain generic scripts. If the entire `scripts/` directory is removed, PATH has a broken entry.

**Why it happens:**
- PATH is set in `.zshrc` line 80: `export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$HOME/.local/share/pnpm:$HOME/uz6r/dotfiles/scripts:$PATH"`
- The `scripts/` directory is referenced in the `dotfiles` alias (line 112) and PATH
- Forgetting to update PATH after removing the `scripts/` directory

**How to avoid:**
1. Check if `dotfiles/scripts/` directory exists and what's in it
2. If `scripts/` is removed, update line 80 to remove `$HOME/uz6r/dotfiles/scripts` from PATH
3. If `scripts/` is kept for future use, ensure it's empty of company-specific content
4. Run `echo $PATH` in a fresh shell to verify no broken entries

**Warning signs:**
- `command not found` errors for commands that should exist
- PATH contains non-existent directory (check with `tr ':' '\n' <<< "$PATH" | xargs -I {} sh -c 'test -d {} || echo "Missing: {}"`)

**Phase to address:** Phase 1 (Clean .zshrc) — audit PATH line 80

---

### Pitfall 3: Broken Symlinks After Removing bin/ Scripts (GNU Stow)

**What goes wrong:**
GNU Stow creates symlinks from `~/bin/sinar-pi-setup` → `~/dotfiles/bin/sinar-pi-setup`. Simply deleting the file from `dotfiles/bin/` leaves a broken symlink in `~/bin/`.

**Why it happens:**
- Stow doesn't auto-clean symlinks when source files are deleted
- The broken symlinks cause `ls ~/bin/` to show red files (if using `ls --color`)
- Scripts iterating over `~/bin/` may fail on broken symlinks

**How to avoid:**
1. Before deleting scripts from `dotfiles/bin/`, run `stow -D bin` to unstow the package
2. Delete the scripts from `dotfiles/bin/`
3. Re-stow with `stow bin`
4. Alternatively, after deletion run: `find ~/bin -type l ! -exec test -e {} \; -delete`

**Warning signs:**
- `ls -la ~/bin/` shows symlinks in red (broken)
- Running `chkstow` from the dotfiles directory reports bad links
- `file ~/bin/sinar-pi-setup` returns "broken symbolic link"

**Phase to address:** Phase 2 (Remove bin/ scripts) — use `stow -D bin` before deletion

---

### Pitfall 4: Cross-Platform Conditionals Damaged

**What goes wrong:**
The `.zshrc` has carefully structured cross-platform logic (lines 36-50 for detection, 60-77 for Homebrew, 105-109 for ls aliases, 197-214 for clipboard/open commands). Accidentally removing or breaking these conditionals makes the shell fail on one platform.

**Why it happens:**
- The `is_darwin()` and `is_linux()` helper functions (lines 49-50) depend on `IS_MACOS` and `IS_LINUX` exports (lines 37-38)
- These variables are set in a `case "$(uname -s)" in ... esac` block (lines 40-47)
- Accidentally removing the `esac` or breaking the case statement syntax

**How to avoid:**
1. Never edit the platform detection block (lines 36-50) — it's not company-specific
2. After any edit, test on both platforms if possible, or at least verify syntax with `zsh -n`
3. The `is_linux; then ... fi` block around `localdev()` (lines 154, 184) should be removed entirely with the function
4. Keep the Homebrew detection logic — it's not company-specific

**Warning signs:**
- `is_darwin` or `is_linux` commands not found
- Homebrew not found on macOS or Linux after cleanup
- `ll` alias uses wrong flag (`-G` vs `--color=auto`)

**Phase to address:** Phase 1 (Clean .zshrc) — preserve lines 36-77 intact

---

### Pitfall 5: Comment Rot (Leftover References in Comments)

**What goes wrong:**
The `.zshrc` has commented-out Courtsite aliases (lines 315-328) with a `# TODO courtsite shortcuts - phasing out` header. Leaving these comments creates confusion about what's active and what's not.

**Why it happens:**
- Developers often comment out code "temporarily" and forget to remove it
- The TODO comment suggests future action but doesn't get acted on
- Future maintainers wonder if the commented code should be restored

**How to avoid:**
1. Delete all commented Courtsite aliases (lines 311-328 entirely)
2. Remove the `# TODO courtsite shortcuts - phasing out` comment header
3. Remove the `# TODO Courtsite local dev - phasing out` comment (line 153)
4. Search for any remaining "Courtsite" or "sinar" references in comments

**Warning signs:**
- `grep -i "courtsite\|sinar" .zshrc` returns results
- TODO comments that are stale
- Commented code blocks that are never going to be restored

**Phase to address:** Phase 1 (Clean .zshrc) — grep for and remove all comment rot

---

### Pitfall 6: Git History Contains Company References

**What goes wrong:**
Even after removing Courtsite references from the working directory, git history still contains commits with company paths, which could be exposed if the repo is made public or forked.

**Why it happens:**
- Past commits may have company paths in `.zshrc`, `bin/` scripts, or other files
- Simply committing the "cleanup" doesn't rewrite history
- `git log -p` or `git blame` will show the old company-specific code

**How to avoid:**
1. **If repo is private and staying private:** No action needed — just commit the cleanup
2. **If repo might go public:** Use `git filter-repo` or BFG to scrub company references from history
3. **Check for secrets:** Run `gitleaks detect --verbose` or `trufflehog git file://. --only-verified`
4. **Check for paths:** `git log -p --all -S "COURTSITE_DIR"` to find commits that reference company paths

**Warning signs:**
- `git log --all --grep="Courtsite"` returns results
- `git log -p --all -S "COURTSITE_DIR"` shows past commits with the variable
- Company paths in `git blame .zshrc` output

**Phase to address:** Phase 3 (Verify & Commit) — run secret scanners and history check

---

### Pitfall 7: .zshrc.local Contains Company Config

**What goes wrong:**
The `.zshrc` sources `~/.zshrc.local` (lines 411-413) for machine-specific config. If the user previously moved Courtsite aliases to `.zshrc.local` (as suggested in PROJECT.md), those references will still exist on the local machine but won't be in the repo.

**Why it happens:**
- PROJECT.md says "Move Courtsite aliases to .zshrc.local (already there, ensure not in .zshrc)"
- The `.zshrc.local` file is not tracked in git (should be in `.gitignore`)
- After cleanup, the local machine may still have Courtsite references in `~/.zshrc.local`

**How to avoid:**
1. Check if `~/.zshrc.local` exists on the local machine: `cat ~/.zshrc.local`
2. Remove any Courtsite/sinar references from the local file
3. Verify `.zshrc.local` is in `.gitignore` (it should be, as it's machine-specific)
4. Document that users should check their local `~/.zshrc.local`

**Warning signs:**
- `cat ~/.zshrc.local | grep -i "courtsite\|sinar\|COURTSITE"` returns results
- Shell still has `core`, `konsol`, etc. aliases after cleanup (they're coming from `.zshrc.local`)

**Phase to address:** Phase 3 (Verify & Commit) — document local file check

---

### Pitfall 8: Typo in Existing Code (setiauyama vs setiausaha)

**What goes wrong:**
Line 319 has a typo: `setiauyama}` should be `setiausaha}`. This is in a commented-out alias, but if anyone ever uncomments it, it will fail.

**Why it happens:**
- The typo has existed since the alias was created
- It's in a commented block, so it wasn't caught during normal use
- During cleanup, typos in commented code are easy to miss

**How to avoid:**
1. As part of cleanup, fix the typo in the commented line 319: `setiauyama}` → `setiausaha}`
2. Or simply delete the entire commented block (recommended)

**Warning signs:**
- Code review catches the typo
- Someone uncomments the line and gets a "directory not found" error

**Phase to address:** Phase 1 (Clean .zshrc) — fix or remove line 319

---

### Pitfall 9: README.md References Not Updated

**What goes wrong:**
The `README.md` references `sinar-pi-setup` and `sinar-pi-wifi-setup` in the bin/ documentation. After removing these scripts, the README will be outdated.

**Why it happens:**
- README is often forgotten during cleanup
- The scripts are removed from `bin/` but README still says they exist
- Users following README instructions will get "command not found"

**How to avoid:**
1. Update README.md to remove references to sinar-pi-setup and sinar-pi-wifi-setup
2. Remove the line: "│   ├── sinar-pi-setup       # build + package sinarclient tarball"
3. Remove the line: "│   └── sinar-pi-wifi-setup  # wifi setup for Pi (nmconnection + rsync)"
4. Update the "Current focus" section to reflect cleanup is complete

**Warning signs:**
- `grep -i "sinar" README.md` returns results after cleanup
- README lists scripts that don't exist in `bin/`

**Phase to address:** Phase 3 (Verify & Commit) — audit README.md

---

### Pitfall 10: Broken DOTFILES_DIR Variable or Alias

**What goes wrong:**
Line 112: `alias dotfiles="cd ${DOTFILES_DIR:-$HOME/uz6r/dotfiles}"`. The hardcoded path `$HOME/uz6r/dotfiles` is used as a fallback. After cleanup, verify this path is still correct.

**Why it happens:**
- The directory name `uz6r` might be company-related (though it looks like a username)
- If the repo is renamed or moved, this alias breaks
- The `DOTFILES_DIR` variable might not be set, causing the fallback to be used

**How to avoid:**
1. Verify `uz6r` is not company-specific (looks like username, probably fine)
2. Consider setting `DOTFILES_DIR` explicitly in `.zshrc` or `.zshrc.local`
3. Test the `dotfiles` alias after cleanup: run `dotfiles` and verify it cd's to the right place

**Warning signs:**
- `dotfiles` alias doesn't work (directory doesn't exist)
- `echo $DOTFILES_DIR` is empty and the fallback path is wrong

**Phase to address:** Phase 1 (Clean .zshrc) — verify dotfiles alias works

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Comment out code instead of deleting | Easy to restore if needed | Comment rot, confusion about what's active | Never — delete completely |
| Leave stale PATH entries | Avoids breaking something | Broken paths, slower shell startup | Never — clean up PATH |
| Skip `stow -D` before deleting files | Saves one command | Broken symlinks in ~/bin | Never — always unstow first |
| Skip cross-platform testing | Faster cleanup | Shell broken on one platform | Never — test both platforms |

---

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| GNU Stow | Delete files without unstowing first | Run `stow -D bin` before deleting scripts |
| Powerlevel10k | Forget to test prompt after .zshrc changes | Open new terminal tab, verify p10k loads |
| Oh My Zsh | Delete plugins array or source line | Preserve lines 22-30 (plugin loading) |
| Homebrew | Break platform detection for brew prefix | Keep lines 60-77 intact |

---

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Stale PATH entries | Slower command lookup | Clean PATH after removing directories | 5+ stale entries |
| Broken symlinks in ~/bin | `ls` errors, script iteration failures | Run `chkstow` after cleanup | Any broken symlink |
| Large bin/ directory | Slower tab-completion | Remove unused scripts, keep bin/ lean | 50+ scripts |

---

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Leaving company paths in git history | Exposure if repo goes public | Use `git filter-repo` if needed |
| Not scanning for secrets in bin/ scripts | API keys, passwords in scripts | Run `gitleaks detect --no-git` on bin/ |
| Forgetting .zshrc.local has company config | Local machine still has references | Check `~/.zshrc.local` manually |
| Hardcoded paths with usernames | Privacy leak if repo shared | Use `$HOME` instead of `/home/username` |

---

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Shell startup:** Run `zsh -n .zshrc` — verifies no syntax errors
- [ ] **Cross-platform logic:** Verify `is_darwin()` and `is_linux()` still work — test with `is_darwin && echo "macOS" || echo "Linux"`
- [ ] **PATH cleanup:** `tr ':' '\n' <<< "$PATH" | xargs -I {} sh -c 'test -d {} || echo "Missing: {}"'` — finds broken PATH entries
- [ ] **Symlinks:** `find ~/bin -type l ! -exec test -e {} \; -print` — lists broken symlinks
- [ ] **Comment rot:** `grep -i "courtsite\|sinar\|COURTSITE" .zshrc` — should return nothing
- [ ] **Git history:** `git log -p --all -S "COURTSITE_DIR"` — check if history needs scrubbing
- [ ] **Local overrides:** `cat ~/.zshrc.local 2>/dev/null | grep -i "courtsite\|sinar"` — check local file
- [ ] **README:** `grep -i "sinar" README.md` — should return nothing after update
- [ ] **Plugin loading:** Verify Oh My Zsh still loads (check for `ZSH` variable and `source $ZSH/oh-my-zsh.sh`)
- [ ] **Powerlevel10k:** Open new terminal, verify p10k prompt appears

---

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Broken .zshrc syntax | LOW | `mv .zshrc .zshrc.broken && git checkout .zshrc` — restore from git |
| Broken symlinks | LOW | `find ~/bin -type l ! -exec test -e {} \; -delete` — remove all broken symlinks |
| PATH issues | LOW | `exec zsh` to restart shell with clean environment |
| Lost function (accidentally deleted) | MEDIUM | `git log --all -p -- .zshrc` to find the deleted function, manually restore |
| Git history leak | HIGH | `git filter-repo --replace-text replacements.txt` to scrub history, force push |

---

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| 1. Breaking shell startup | Phase 1 (Clean .zshrc) | `zsh -n .zshrc` before sourcing |
| 2. Stale PATH entries | Phase 1 (Clean .zshrc) | Check PATH contents in new shell |
| 3. Broken symlinks | Phase 2 (Remove bin/ scripts) | `chkstow` or `find ~/bin -type l ! -exec test -e {} \;` |
| 4. Cross-platform conditionals | Phase 1 (Clean .zshrc) | Test `is_darwin` and `is_linux` functions |
| 5. Comment rot | Phase 1 (Clean .zshrc) | `grep -i "courtsite\|sinar"` on .zshrc |
| 6. Git history | Phase 3 (Verify & Commit) | `gitleaks detect --verbose` |
| 7. .zshrc.local | Phase 3 (Verify & Commit) | Document local file check for users |
| 8. Typo in code | Phase 1 (Clean .zshrc) | Fix or delete commented block |
| 9. README outdated | Phase 3 (Verify & Commit) | `grep -i "sinar" README.md` |
| 10. DOTFILES_DIR alias | Phase 1 (Clean .zshrc) | Test `dotfiles` alias |

---

## Sources

- [Building Modern Cross-Platform Dotfiles | @shinyaz](https://shinyaz.com/en/blog/2026/03/15/modern-dotfiles-guide) — Cross-platform guard patterns
- [2 Step Defense in Depth for Dotfiles: Modularizing Your .zshrc | Carmelyne Thompson](https://carmelyne.com/modularizing-your-zshrc/) — Shell startup safety
- [GNU Stow for dotfiles | Simon Inglis](https://simoninglis.com/posts/gnu-stow-dotfiles/) — Stow unstow workflow
- [Dotfiles Security: How to Stop Leaking Secrets on GitHub | InstaTunnel Blog](https://instatunnel.my/blog/why-your-public-dotfiles-are-a-security-minefield) — Git history scrubbing
- [Write Cross-Platform Shell: Linux vs macOS Differences | TECH CHAMPION](https://tech-champion.com/linux/write-cross-platform-shell-linux-vs-macos-differences-that-break-production/) — Cross-platform pitfalls
- [Mastering Zsh Startup: ~/.zprofile vs ~/.zshrc](https://slavadubrov.github.io/blog/2025/05/07/mastering-zsh-startup-zprofile-vs-zshrc/) — Zsh startup order
- [timkicker/dotfiles security guide](https://github.com/timkicker/dotfiles/security) — Secret scanning with gitleaks/trufflehog
- Project context: `.planning/PROJECT.md`, `.zshrc`, `bin/` directory listing

---

*Pitfalls research for: Dotfiles cleanup — removing Courtsite/company-specific configuration*
*Researched: 2026-04-30*
