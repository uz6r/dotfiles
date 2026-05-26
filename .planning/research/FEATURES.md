# Feature Research — v1.3 Final Audit & Sanitization

**Domain:** Dotfile audit, sanitization, workflow preservation, and macOS migration readiness
**Researched:** 2026-05-26
**Confidence:** HIGH

## Feature Landscape

### Category 1: Workflow Preservation

Capture the portable workflows currently embedded in shell usage patterns so nothing is lost after laptop reset.

#### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Shell history pattern analysis | Without it, commonly used undocumented commands are lost after reset | MEDIUM | Parse `~/.zsh_history` — extract top 50 commands, custom functions called, one-off patterns |
| Undocumented aliases/functions audit | Aliases in `.zshrc.local` or local shell state that aren't in the tracked repo | LOW | Diff `alias` output against tracked `.zshrc`; `.zshrc.local` currently has Courtsite aliases that need local cleanup |
| Local scripts inventory | Scripts in `~/bin`, `~/.local/bin`, `/usr/local/bin` that aren't in the dotfiles repo | MEDIUM | `find ~/bin ~/.local/bin -type f` vs `ls bin/`; flag anything only on this machine |
| Zsh function usage audit | Identify which functions in `.zshrc` are actually used vs dead code | LOW | `grep` shell history for function names (`mkcd`, `bak`, `killport`, `gql`, `gpub`, `gmain`); flag unused |
| Git alias pattern capture | Git aliases defined in `.gitconfig` that are used in daily workflow | LOW | All tracked in `git/.gitconfig` (well-maintained), but verify `.gitconfig.local` for additional aliases |
| Tmux session/layout patterns | Frequently used tmux session layouts or window arrangements | LOW | Check for tmuxinator/tmux-resurrect usage; if none, no preservation needed |

#### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| `bin/audit-workflow` — automated workflow profiler | Generates a WORKFLOW.md from shell history analysis, listing top commands, custom function usage, and untracked scripts | MEDIUM | New script; parse zsh history with dedup, frequency count, cross-reference with tracked aliases/functions |
| Shell history anonymization for sharing | If WORKFLOW.md is committed, strip paths, hostnames, sensitive arguments from history samples | LOW | `sed`-based path replacement; `$HOME` substituion |
| SSH config pattern backup | Capture `~/.ssh/config` host patterns (not keys) as reference for macOS migration | LOW | Pattern: `grep -E '^Host ' ~/.ssh/config` with annotations, exclude IdentityFile paths |
| Brew package list export | Capture installed Homebrew packages/taps for macOS re-setup | LOW | `brew bundle dump` pattern; already have install.sh with brew detection |

#### Anti-Features

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Commit raw shell history | Contains passwords, paths, commands typed with secrets | Generate aggregated/anonymized WORKFLOW.md, never commit raw `.zsh_history` |
| Auto-committing `.zshrc.local` contents | Defeats the `.gitignore` pattern for machine-specific secrets | Only generate a `.zshrc.local.example` template with placeholder patterns |

---

### Category 2: Sanitization

Eliminate ALL sensitive traces — secrets, credentials, company references, personal identifiers — before any public exposure.

#### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **CRITICAL: Remove `ZTE_EC382D.nmconnection`** | Contains plaintext WiFi password (`psk=7A33S6282B`), SSID, UUID — tracked in git | LOW | Delete file + add `*.nmconnection` to `.gitignore`; git history scrub required (it's committed) |
| Secrets scanning with gitleaks | Detect API keys, tokens, passwords accidentally committed | MEDIUM | Install gitleaks, run `gitleaks detect --no-git` on working tree + `gitleaks detect` on git history |
| Company reference detection (enhanced) | `courtsite-guard` exists but only scans tracked files; `.zshrc.local` on disk has active Courtsite aliases | LOW | Extend guard to also flag if user's local `.zshrc.local` contains company refs (warning, not error) |
| Hardcoded username path replacement | `/home/uzer` found in 3 tracked files — leaks username and breaks portability | LOW | Replace with `$HOME`: `.zshrc:3` (fpath), `.zshrc:365` (opencode PATH), `bin/audit-nvim-plugins:7` (CONFIG_FILE) |
| Large binary removal (`lazygit`) | 21MB ELF binary + 7.6MB tarball tracked in git — bloats repo, not a dotfiles concern | LOW | Remove from git, add `lazygit` and `lazygit.tar.gz` to `.gitignore`; replace with Brewfile entry or install script |
| Personal email review in `.gitconfig` | `uzairzahari@yahoo.com` exposed in tracked gitconfig — acceptable for public repo but flag for review | LOW | Already present; user accepts this exposure (standard for dotfiles). Document as intentional. |

#### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| `make sanitize` — comprehensive sanitization target | Single-command pre-public audit: runs gitleaks, company ref scan, hardcoded path check, binary check, nmconnection check | MEDIUM | Add to Makefile; auto-installs gitleaks on first run; reports all findings in one pass |
| Pre-push sanitization hook | Prevents accidentally pushing sensitive content after cleanup | LOW | Enhance existing `.githooks/pre-commit` to also check for hardcoded paths, binaries, network configs |
| Git history scrub for `ZTE_EC382D.nmconnection` | WiFi password exists in git history — plaintext credential in every past clone | HIGH | Use `git filter-repo --path ZTE_EC382D.nmconnection --invert-paths`; coordinate with any existing clones |
| `.zshrc.local` auto-cleanup documentation | User's local `.zshrc.local` still has 16 lines of Courtsite aliases — needs local manual cleanup documented | LOW | Add to README or create `PRE-RESET-CHECKLIST.md` documenting what user must clean on their machine |
| `bin/audit-nvim-plugins` path de-hardcoding | Currently uses `/home/uzer/uz6r/dotfiles/` — should use `$DOTFILES_DIR` or `$HOME` | LOW | Refactor to detect dotfiles location dynamically |

#### Anti-Features

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Auto-delete `.zshrc.local` | User may have legitimate machine-specific config beyond Courtsite | Generate `PRE-RESET-CHECKLIST.md` telling user to manually review and clean `.zshrc.local` |
| Force-rotate all credentials blindly | May break active services the user still uses | Flag what was found; let user decide rotation urgency |
| Commit gitleaks config with false-positive exceptions that hide real issues | Security by obscurity | Keep gitleaks config minimal; only add exceptions after manual review confirms false positive |

---

### Category 3: macOS Compatibility

Ensure all configs and scripts work correctly on macOS after migrating from Linux-only use.

#### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Fix `du` flag incompatibility** (`.zshrc:130`) | `du -h --max-depth=1` is GNU-only; macOS uses `-d 1` | LOW | Replace with: `if is_darwin; then alias duh='du -h -d 1 | sort -hr'; else alias duh='du -h --max-depth=1 | sort -hr'; fi` |
| **Fix `readlink -f` in Makefile:40** | macOS `readlink` doesn't support `-f`; needs `greadlink` or `realpath` | LOW | Use: `readlink "$target" 2>/dev/null || greadlink -f "$target" 2>/dev/null || echo "$target"` |
| **Fix `grep -oP` in `bin/audit-nvim-plugins:16`** | `-P` (Perl regex) is GNU grep only; macOS grep doesn't support it | LOW | Replace `grep -oP` with `grep -oE` (ERE is portable) or use `rg` (ripgrep) which is consistent cross-platform |
| **Fix `date +%s%N` in `bin/profile-zsh:38`** | Nanosecond format `%N` is GNU date only; macOS date doesn't have it | LOW | Use: `if is_darwin; then perl -MTime::HiRes -e 'printf "%.0f\n", Time::HiRes::time()*1000000000'; else date +%s%N; fi` or just drop nanosecond precision |
| **Fix `du` and `sort -hr` combo in `.zshrc:130`** | `sort -hr` is GNU sort; macOS sort uses `-r` but `-h` (human numeric) may not exist on older macOS | LOW | Test: `sort -hr` works on modern macOS (post-10.13); flag for testing |
| `ifconfig` vs `ip addr` in `.zshrc:162` | `.zshrc` already has cross-platform guard (`is_darwin` → `ifconfig`, else `ip addr`); good | LOW | Already handled well. Verify `localip` alias works on both platforms. |
| Snap path assumption in `.zshrc:345` | `$HOME/snap/code/current/.local/share/pnpm` is Linux-only (snap doesn't exist on macOS) | LOW | macOS-safe: the `for` loop just tries the path and moves on if it doesn't exist; no change needed but flag for awareness |

#### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| `make macos-check` — macOS compatibility audit | Single command that scans all tracked files for GNU-only flags and BSD incompatibilities | MEDIUM | Uses regex patterns for known incompatibilities (`readlink -f`, `grep -P`, `date.*%N`, `du --max-depth`, `sed -i` without `''`, `stat -c`, `ps -eo`) |
| CI matrix: add macOS runner | GitHub Actions currently only tests on `ubuntu-latest`; add `macos-latest` to catch cross-platform regressions | MEDIUM | Update `.github/workflows/ci.yml`; macOS runners cost 10x Linux minutes on GitHub |
| `bin/check-macos-compat` — portable flag auditor | Analyzes shell scripts for non-portable flags, suggests fixes | MEDIUM | Similar to `shellcheck` but focused on GNU/BSD flag differences |
| Stow compatibility audit | `stow -v -R` behavior may differ between GNU Stow and macOS (brew) stow versions | LOW | Test on macOS; document any flag differences |

#### Anti-Features

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Replace all GNU utils with BSD equivalents | Makes Linux experience worse (GNU features are genuinely better) | Use platform guards (`is_darwin` / `is_linux`) for flag differences |
| Require `brew install coreutils` on macOS | Adds mandatory dependency; some users prefer native utils | Make coreutils optional; detect and prefer GNU versions if available, but don't hard-depend |
| `if is_darwin` for every command | Bloats configs; most zsh syntax is portable | Only guard commands with known flag differences |

---

### Category 4: Maintainability

Clean up stale configs, improve idempotency, organize for long-term health.

#### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Remove stale `scripts/` PATH entry (`.zshrc:80`)** | `scripts/` directory is empty; PATH still references `$HOME/uz6r/dotfiles/scripts` | LOW | Remove `$HOME/uz6r/dotfiles/scripts` from PATH line 80, or remove PATH entry + delete empty `scripts/` dir |
| **Remove `ZTE_EC382D.nmconnection` from repo** | Network config with WiFi password tracked in root of dotfiles repo — doesn't belong | LOW | Delete file + gitignore; already covered in sanitization section |
| **Remove `lazygit` binary + `lazygit.tar.gz` from git** | 21MB + 7.6MB of tracked binaries in root — use Homebrew/script instead | LOW | Git-filter-repo or `git rm --cached` + `.gitignore`; add lazygit to Brewfile if adopting |
| **Fix hardcoded paths in scripts** | `bin/profile-zsh:7`, `bin/audit-nvim-plugins:7` use absolute `/home/uzer/uz6r/` paths | LOW | Replace with `$DOTFILES_DIR` or auto-detect from script location |
| `make status` gitignore awareness | `make status` doesn't verify `.gitignore` coverage for sensitive patterns | LOW | Add `.gitignore` audit to `make test`: check for `*.nmconnection`, `lazygit*`, binary patterns |
| Update outdated `CONCERNS.md` | References Courtsite aliases and `localdev()` function that were removed in v1.2 | LOW | Update/remove resolved items; add new v1.3 concerns |

#### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Modular `init.lua` split | Current `nvim/.config/nvim/init.lua` is 472 lines monolithic; split into `lua/` modules | MEDIUM | Split into `lua/options.lua`, `lua/keymaps.lua`, `lua/plugins.lua`, `lua/lsp.lua` |
| `.zshrc.local.example` template | Provides machine-specific override template for new setups; documents the pattern | LOW | Create with placeholder patterns (local PATH additions, machine-specific aliases, commented examples) |
| `make doctor` — comprehensive health check | Single target that runs: stow status, syntax checks, courtsite-guard, test, sanitize, macos-check, .gitignore audit, hardcoded-path check | MEDIUM | Aggregates all existing targets + new checks; produces single pass/fail report |
| Idempotency audit for `install.sh` | Verify `install.sh` can be run multiple times without errors; handle edge cases (existing symlinks, Homebrew already installed) | LOW | `install.sh` already handles most cases with `|| true` and existence checks; verify all paths |
| Linting coverage expansion | Add `.zshrc` to shellcheck (currently only `.sh` files), add `.tmux.conf` validation | LOW | `shellcheck` doesn't handle `.zshrc` well; flag as limitation. Add `tmux` config validation: `tmux source-file /dev/null 2>&1` |

#### Anti-Features

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Restructure entire repo layout | Breaks stow paths, massive disruption for marginal benefit | Keep Stow package structure; improve within packages |
| Auto-delete unused functions from `.zshrc` | User may rely on functions not found in history analysis | Flag unused functions for review; let user decide to delete |
| Add complex module loading framework | Over-engineering for personal dotfiles | Keep `conf.d/` pattern simple if adopting; numeric prefix loading is sufficient |

---

### Category 5: Public-Safe Review

Separate public from private state. Ensure nothing in the committed repo leaks personal data.

#### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| `.gitignore` coverage audit | Verify sensitive patterns are excluded: `*.nmconnection`, `lazygit*`, `*.key`, `*.pem`, `*.gpg`, `*.p12`, `*.pfx`, `.aws/`, `.ssh/`, `.gnupg/`, `.docker/config.json` | LOW | Expand `.gitignore` beyond current 13 lines; follow timkicker/dotfiles security guide patterns |
| `zsh/.zshrc.local` local state check | `.zshrc.local` exists on disk with Courtsite aliases, is gitignored (good), but user must clean it locally before making repo public | LOW | Add to `PRE-RESET-CHECKLIST.md`; provide command: `rg -i "courtsite|sinar|enjin" ~/.zshrc.local` |
| `git/.gitconfig.local` presence check | Machine-specific git overrides might contain work email or tokens | LOW | Check if `~/.gitconfig.local` exists; if so, audit its contents for sensitive data |
| OpenCode path hardcoding (`.zshrc:365`) | `export PATH=/home/uzer/.opencode/bin:$PATH` — hardcoded username; OpenCode may store tokens in its config directory | LOW | Replace with `$HOME`; flag for user to verify `~/.opencode/` doesn't contain tokens |
| `.gitconfig` email review | `uzairzahari@yahoo.com` is committed — acceptable for personal dotfiles but flag | LOW | Document as intentional public email; user can override in `.gitconfig.local` |

#### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| `make public-ready` — pre-open-source checklist | Single command that runs all sanitization checks and reports what still needs attention before the repo can go public | MEDIUM | Wraps sanitize + macos-check + gitignore audit + hardcoded-path check + git-history check |
| `PRE-RESET-CHECKLIST.md` | Comprehensive checklist for what the user must do on their LOCAL machine before laptop reset (outside git — `.zshrc.local`, SSH keys, shell history, etc.) | LOW | Markdown checklist with commands to run; covers: `.zshrc.local` cleanup, `.gitconfig.local` review, SSH key backup, Brew package list export, shell history extraction |
| Git history audit for sensitive data | Run `gitleaks detect` on full git history to catch credentials committed in the past | MEDIUM | The `ZTE_EC382D.nmconnection` WiFi password exists in history; needs git-filter-repo scrub |
| Automated `.gitignore` validation | Add to `make test`: verify no tracked files match sensitive patterns (`*.nmconnection`, `*.key`, `*.pem`, binary files >1MB) | LOW | `git ls-files` cross-referenced against known-dangerous patterns |

#### Anti-Features

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Commit a gitleaks `.toml` with `.zshrc.local` exceptions | If anyone modifies the exceptions, real leaks could slip through | Keep gitleaks config minimal; only add `.planning/` and known-safe patterns |
| Add `.zshrc.local` to the repo "as a template" | Users might not realize it contains real config; accidentally commits secrets | Create `.zshrc.local.example` with ONLY placeholder patterns, never commit the real `.zshrc.local` |
| Blind `.gitignore` on `*` then `!tracked-files` | Inverted gitignore is fragile; easy to accidentally commit secrets | Use explicit ignore patterns for sensitive files; default to tracking for everything else |

---

## Feature Dependencies

```
Legend: → = "requires", ⇢ = "enhances", ⚠ = "blocked by"

Category 1: Workflow Preservation
├── bin/audit-workflow (NEW)
│   → zsh history read access
│   ⇢ Shell history anonymization
│
├── Undocumented aliases audit
│   → Local shell access (cannot CI)
│
└── Brew package list export
    → brew bundle dump

Category 2: Sanitization
├── Remove ZTE_EC382D.nmconnection ⚠ CRITICAL
│   → git filter-repo for history scrub
│   → .gitignore update
│
├── Secrets scanning (gitleaks)
│   → Install gitleaks tool
│
├── Hardcoded path fixes
│   → Edit .zshrc:3, .zshrc:365, bin/audit-nvim-plugins:7
│
└── Large binary removal
    → git rm lazytit + lazytit.tar.gz
    → .gitignore update

Category 3: macOS Compatibility
├── Fix du flag (.zshrc:130)
├── Fix readlink -f (Makefile:40)
├── Fix grep -oP (bin/audit-nvim-plugins:16)
├── Fix date +%s%N (bin/profile-zsh:38)
└── make macos-check (NEW)
    → Depends on known incompatibility patterns

Category 4: Maintainability
├── Remove stale scripts/ PATH (.zshrc:80)
├── Update CONCERNS.md
├── .zshrc.local.example (NEW template)
└── make doctor (NEW)
    → Depends on all other make targets existing

Category 5: Public-Safe Review
├── .gitignore expansion
├── PRE-RESET-CHECKLIST.md (NEW doc)
├── make public-ready (NEW target)
│   → Depends on sanitize + macos-check + gitignore-audit
└── Git history audit
    → Depends on ZTE_EC382D.nmconnection removal
```

## Cross-Category Dependencies

```
[Hardcoded path fixes] (Cat 2)
    ⇢ enables [macOS compatibility] (Cat 3) — $HOME paths work on both platforms
    ⇢ enables [Public-safe review] (Cat 5) — no username leaks

[ZTE_EC382D.nmconnection removal] (Cat 2)
    → required for [Public-safe review] (Cat 5) — WiFi cred in history
    → required for [Maintainability] (Cat 4) — stale non-dotfiles config

[lazygit binary removal] (Cat 2)
    → required for [Public-safe review] (Cat 5) — 21MB binary in public repo
    → required for [Maintainability] (Cat 4) — use package manager instead

[.zshrc.local cleanup] (Cat 1 + Cat 2)
    ⇢ User must do locally (can't be automated in CI)
    ⇢ Documented in PRE-RESET-CHECKLIST.md (Cat 5)
```

## MVP Recommendation (v1.3 scope)

### Phase 1: Critical Security (must ship first)
1. **Remove ZTE_EC382D.nmconnection** — delete + gitignore + history scrub
2. **Remove lazygit binary + tarball** — delete + gitignore + history scrub
3. **Fix hardcoded paths** (.zshrc:3, .zshrc:365, bin/audit-nvim-plugins:7)
4. **Expand .gitignore** — add sensitive patterns

### Phase 2: Compatibility & Audit Tooling
5. **Fix macOS incompatibilities** (du, readlink, grep, date)
6. **`make sanitize`** — comprehensive sanitization target
7. **`make macos-check`** — macOS compatibility auditor
8. **`make public-ready`** — pre-open-source checklist aggregator

### Phase 3: Workflow & Documentation
9. **`bin/audit-workflow`** — shell history profiler
10. **`PRE-RESET-CHECKLIST.md`** — local machine cleanup guide
11. **`.zshrc.local.example`** — template for new machines
12. **`make doctor`** — comprehensive health check

### Defer (v1.4+)
- **Modular nvim init.lua split** — 472 lines → lua/ modules
- **CI macOS runner** — cost/benefit for personal dotfiles
- **Git history full scrub** — only if repo goes public (gitleaks pass first)

## Current State: Issues Discovered

### CRITICAL (security)

| # | Issue | Location | Impact |
|---|-------|----------|--------|
| C1 | WiFi password in plaintext | `ZTE_EC382D.nmconnection` (tracked) | Password `7A33S6282B` exposed in git history |
| C2 | 21MB binary tracked | `lazygit` (ELF binary) | Bloats repo, inappropriate for dotfiles |
| C3 | 7.6MB tarball tracked | `lazygit.tar.gz` | Same as above |
| C4 | `.zshrc.local` has Courtsite refs | `~/.zshrc.local` (local disk) | 16 lines of company aliases, gitignored but present |

### HIGH (compatibility)

| # | Issue | Location | Fix |
|---|-------|----------|-----|
| H1 | `du --max-depth` GNU-only | `.zshrc:130` | Platform guard with `-d 1` for macOS |
| H2 | `readlink -f` GNU-only | `Makefile:40` | Use `readlink` || `greadlink` || fallback |
| H3 | `grep -oP` GNU-only | `bin/audit-nvim-plugins:16` | Replace with `grep -oE` or `rg` |
| H4 | `date +%s%N` GNU-only | `bin/profile-zsh:38` | Drop nanosecond precision or use perl fallback |

### MEDIUM (maintainability)

| # | Issue | Location | Fix |
|---|-------|----------|-----|
| M1 | Stale PATH entry | `.zshrc:80` | Remove `$HOME/uz6r/dotfiles/scripts` |
| M2 | Hardcoded username paths | `.zshrc:3,365`, `bin/audit-nvim-plugins:7` | Replace with `$HOME` |
| M3 | Empty `scripts/` directory | Repo root | Delete or repurpose |
| M4 | Outdated CONCERNS.md | `.planning/codebase/CONCERNS.md` | References resolved v1.2 issues |
| M5 | No `.zshrc.local.example` template | Missing | Create with placeholder patterns |

### LOW (enhancement)

| # | Issue | Location | Notes |
|---|-------|----------|-------|
| L1 | Snap path in pnpm detection | `.zshrc:345` | Linux-only, safe to leave (silently skipped on macOS) |
| L2 | Monolithic nvim init.lua | `nvim/.config/nvim/init.lua` (472 lines) | Split into lua/ modules (defer to v1.4) |
| L3 | CI only on ubuntu-latest | `.github/workflows/ci.yml` | Add macOS runner if budget allows |
| L4 | Email in gitconfig | `git/.gitconfig:4` | Intentional; user accepts |

## Sources

### HIGH confidence
- **[timkicker/dotfiles SECURITY.md](https://github.com/timkicker/dotfiles/security)** — Comprehensive dotfiles security guide: pre-push checklist, gitleaks/trufflehog, common leak patterns, history scrubbing with git-filter-repo, .gitignore patterns for secrets
- **[TECH CHAMPION: Write Cross-Platform Shell](https://tech-champion.com/linux/write-cross-platform-shell-linux-vs-macos-differences-that-break-production/)** — Authoritative cross-platform shell guide: GNU vs BSD differences (sed, grep, find, date, stat, ps, ifconfig/ip), shebang portability, feature detection patterns
- **Current repository analysis** — Direct `rg` scans of all tracked files, git state inspection, file content audit (HIGH confidence)

### MEDIUM confidence
- **[GitHub Docs: Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)** — Official guidance on git-filter-repo usage for credential removal
- **[dotfiles.github.io](https://dotfiles.github.io/)** — Community dotfiles conventions and best practices

### LOW confidence
- Websearch: "dotfiles sanitization checklist 2026" — General patterns observed across personal dotfiles repos (gitleaks, .gitignore patterns, .local file conventions)

---

*Feature research for: v1.3 Final Audit & Sanitization before Laptop Reset*
*Researched: 2026-05-26*
