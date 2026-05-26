# Pitfalls Research

**Domain:** Dotfile audit, sanitization, and pre-machine-wipe migration
**Researched:** 2026-05-26
**Confidence:** HIGH

## Executive Summary

The v1.2 cleanup successfully removed Courtsite references from the tracked repo, but a pre-machine-wipe audit reveals gaps that the courtsite-guard and verify-cleanup targets cannot catch: (1) the scanner excludes `.planning/` and `.githooks/`, creating blind spots for new references migrating into those paths; (2) local files inside the repo directory that are gitignored (`.zshrc.local` still has Courtsite aliases) escape detection; (3) tracked secrets outside the scan scope (ZTE_EC382D.nmconnection contains a WiFi PSK in plaintext and is committed to git); (4) 8.8GB of Courtsite source code in `~/Courtsite/` is entirely outside the dotfiles repo; (5) shell history (~4800 lines) could contain sensitive commands; and (6) macOS compatibility has GNU-isms (`du --max-depth=1`, `sort -hr` BSD vs GNU behavior) that would break the `duh` alias silently on macOS. The audit phase must widen the scan radius beyond the repo, harden `.gitignore` coverage, and verify macOS assumptions.

## Critical Pitfalls

### Pitfall 1: Secret Files Tracked in Git (WiFi Password in nmconnection)

**What goes wrong:**
`ZTE_EC382D.nmconnection` is tracked in git and contains a plaintext WiFi pre-shared key (`psk=7A33S6282B`). This file has been committed and exists in the repo's full history. Anyone who clones or forks the repo gains the WiFi password for the ZTE_EC382D network.

**Why it happens:**
- NetworkManager connection files were likely added early during setup before the project was treated as security-sensitive
- The `.gitignore` has no pattern for `*.nmconnection` files
- The courtsite-guard only scans for Courtsite/Sinar/Enjin references, not generic secrets
- No secret scanner (gitleaks, trufflehog) is integrated into the pre-commit hook or `make test`

**Consequences:**
- WiFi credential exposed to anyone with repo access
- Credential persists in git history even if the file is removed from HEAD
- If repo ever goes public, the password is permanently compromised
- The network owner must change the WiFi password

**Prevention:**
1. Immediately delete and untrack: `git rm --cached ZTE_EC382D.nmconnection && rm ZTE_EC382D.nmconnection`
2. Add `*.nmconnection` to `.gitignore`
3. Add secret scanning to pre-commit: integrate gitleaks or `rg` patterns for `psk=`, `password=`, `wpa-psk`
4. Add `make secret-scan` target that includes generic credential patterns
5. Rotate the WiFi password on the ZTE_EC382D access point

**Warning signs:**
- `rg "psk=|password=|wpa-psk" .` returns hits in tracked files
- `.nmconnection` files in repo root or anywhere
- `make test` passes but no secret scan was run

**Phase to address:** Audit Phase 1 (Secrets & Credentials Scan) — immediate triage item

---

### Pitfall 2: Sanitization Scanner Blind Spots (False Negatives from Exclusions)

**What goes wrong:**
The `courtsite-guard` target explicitly excludes `.planning/`, `.githooks/`, and `Makefile` from scanning. These exclusions create blind spots: a developer (or future AI agent) could add a Courtsite reference into a planning document, a git hook script, or the Makefile itself, and the guard would not catch it. The `verify-cleanup` target scans the full repo (only excluding `.git/`) but is less frequently run and produces a warning rather than blocking commits.

**Why it happens:**
- Exclusions were added during v1.2 to avoid false positives from the planning documents and guard files themselves (which legitimately mention "Courtsite" in regex patterns and documentation)
- The guard was designed as a regression detector for user-facing code, not a comprehensive audit tool
- Pre-commit hook uses the same exclusion patterns as `courtsite-guard`

**Consequences:**
- Courtsite references could (re-)enter the repo through planning documents or hook scripts without detection
- If a planning file, hook, or Makefile line is ever moved into production config, the reference migrates under the radar
- False sense of security: `courtsite-guard` passes but the repo is not truly clean

**Prevention:**
1. Replace blanket exclusions with file-specific allowlists (only exempt the exact lines/patterns that must reference "Courtsite" for the guard to function)
2. Run `verify-cleanup` (no exclusions) as part of `make test` — it already is, but ensure it's a hard failure, not a warning
3. Add a periodic full scan without exclusions to CI or pre-push hook
4. Use comment markers like `# GUARD:ALLOW-courtsite-reference` on the few lines that legitimately mention Courtsite, and have the scanner skip only those marked lines

**Warning signs:**
- Planning documents accumulating company-related content
- New scripts added to `.githooks/` that reference company paths
- `courtsite-guard` passes but `verify-cleanup` fails (already a red flag in v1.2 design)

**Phase to address:** Audit Phase 2 (Scan Hardening & Coverage) — tighten exclusions, add allowlist markers

---

### Pitfall 3: Local-Only State Inside Repo Directory (Gitignored but on Disk)

**What goes wrong:**
`zsh/.zshrc.local` lives inside the dotfiles repo directory, is gitignored (via `*.local`), but still exists on disk with active Courtsite aliases (lines 1-16 reference COURTSITE_DIR, enjin-core, enjin-konsol, etc.). The sanitization scanners work against git-tracked files and file contents — they cannot scan files that are both gitignored AND excluded from scan paths. After machine wipe, this file is gone, but before wipe, it's a local artifact that could be accidentally sourced or inspected.

**Why it happens:**
- `.zshrc.local` was the designated "escape hatch" for machine-specific config during v1.2 cleanup
- The file was never actually cleaned — only moved "out of the way" via `.gitignore`
- `stow` symlinks from `~/.zshrc.local` → `~/dotfiles/zsh/.zshrc.local` mean the aliases are still active in the shell
- The scanner targets can't check gitignored files that aren't in the scan path

**Consequences:**
- Courtsite aliases (`core`, `konsol`, `pelanggan`, etc.) are still active in the current shell
- Running these aliases would attempt to cd into Courtsite project directories
- If someone screenshots or screen-shares their terminal, company names appear
- After machine wipe, the aliases disappear (good for the new machine, but the cleanup wasn't complete)

**Prevention:**
1. Manually inspect and clean `~/.zshrc.local` — remove all Courtsite aliases
2. Run `source ~/.zshrc` after cleanup to verify aliases are gone
3. Add an audit step that checks both `$HOME/.zshrc.local` AND `dotfiles/zsh/.zshrc.local` on disk
4. Document the `.zshrc.local` contents in the audit report so the user knows what was cleaned
5. Consider adding a `make audit-local` target that scans common local-state locations

**Warning signs:**
- `grep -i courtsite ~/.zshrc.local 2>/dev/null` returns hits
- Running `alias | grep -i "core\|konsol\|sinar\|enjin"` shows active aliases
- `type core` shows it's aliased to a Courtsite directory

**Phase to address:** Audit Phase 1 (Secrets & Credentials Scan) — local state sweep

---

### Pitfall 4: Entire Home Directory Ecosystem Outside Repo Scope

**What goes wrong:**
The dotfiles repo represents a small fraction of the total developer environment. Critical items exist entirely outside the dotfiles repo and are invisible to all current scanning:
- **`~/Courtsite/` directory: 8.8GB** of company source code (enjin, infrastructure, simpan-kira)
- **SSH private keys:** `~/.ssh/id_ed25519` and `~/.ssh/id_rsa` — needed for future machine setups
- **Shell history:** `~/.zsh_history` (4797 lines, 278KB) and `~/.bash_history` (8.5KB) — may contain company server paths, internal IPs, or commands with embedded secrets
- **Project `.env` files:** `/home/uzer/uz6r/lembayung/.env` and `.env.local` contain `PROVIDER_API_KEY` values
- **npm tokens/config:** `~/.npmrc`, `~/.config/configstore/` — third-party service tokens
- **Git credentials:** `~/.git-credentials` may exist even if not found in this scan

**Why it happens:**
- Dotfiles tools (stow, git, ripgrep) are scoped to the repo directory
- The v1.2 cleanup focused narrowly on "zero Courtsite references in the dotfiles repo"
- No tooling was built to audit the broader `$HOME` environment
- The `.gitignore` only protects the repo from accidentally committing these files — it doesn't help find them

**Consequences:**
- After machine wipe, SSH keys are lost permanently (no access to servers/services)
- After machine wipe, 8.8GB of Courtsite source code is lost (may be needed for reference, handover, or portfolio)
- Shell history containing useful commands is lost
- `.env` files with API keys for side projects are lost
- Git identity configuration in `.gitconfig.local` is lost (need to reconfigure name, email, signing keys)

**Prevention:**
1. Build a `make audit-home` target that scans common locations: `~/.ssh/`, `~/.zsh_history`, `~/Courtsite/`, `~/*/.env*`, `~/.npmrc`, `~/.gitconfig.local`
2. Create a backup checklist: SSH keys → encrypted backup, shell history → export, .env files → password manager
3. Identify what must be preserved vs. what should be securely deleted
4. Run `rg -l "courtsite\|sinar\|enjin" ~/` (breath search) to find unexpected company references outside the dotfiles repo
5. Document the audit radius explicitly — "repo only" vs "home directory" vs "full machine"

**Warning signs:**
- `make test` passes but `~/Courtsite/` still contains gigabytes of company data
- No SSH key backup before machine wipe
- `ls ~/Courtsite/` shows project directories that were "cleaned" from the dotfiles

**Phase to address:** Audit Phase 1 (Secrets & Credentials Scan) — home directory sweep

---

### Pitfall 5: .gitignore Gaps That Leak Private State

**What goes wrong:**
The current `.gitignore` uses broad patterns (`*.local`) that work for `.zshrc.local` and `.gitconfig.local` but misses entire categories of sensitive files. Specific gaps:
- **No `.env*` pattern:** Project `.env` and `.env.local` files could be accidentally committed if created inside the repo
- **No `*.nmconnection` pattern:** NetworkManager connection files with WiFi passwords would be tracked (confirmed: ZTE_EC382D.nmconnection already committed)
- **No SSH/key patterns:** `*.pem`, `*.key`, `*.ppk`, `id_*` (non-.pub variants) are not excluded
- **No token/credential patterns:** `.npmrc`, `.netrc`, `.git-credentials`, `credentials`, `*.token` not excluded
- **No certificate patterns:** `*.p12`, `*.pfx`, `*.crt`, `*.cer` not excluded
- **No cloud config patterns:** `.aws/`, `.config/gcloud/`, `.kube/` not excluded
- **No shell history patterns:** `.bash_history`, `.zsh_history` (though the `*.local` pattern doesn't catch these)

**Why it happens:**
- `.gitignore` was built incrementally as specific files needed to be excluded
- No comprehensive security-focused `.gitignore` audit was performed
- The repo was always intended to be private, reducing perceived risk

**Consequences:**
- A `git add .` could accidentally stage WiFi passwords, API keys, or private keys
- If the repo is ever pushed to a public remote (GitHub), secrets are exposed
- The pre-commit hook blocks Courtsite references but does not block generic secrets
- Even in a private repo, secrets in version control are harder to rotate and manage

**Prevention:**
1. Add comprehensive patterns: `.env*`, `*.nmconnection`, `*.pem`, `*.key`, `*.pfx`, `.npmrc`, `.netrc`, `.git-credentials`, `*.token`, `credentials`, `.aws/`, `.config/gcloud/`, `.kube/`
2. Add `id_*` with explicit exception for `id_*.pub` using `!id_*.pub`
3. Add `*.history` and `*_history` for shell history files
4. Add a `make audit-gitignore` target that checks for common sensitive files that would NOT be excluded by current rules
5. Integrate gitignore audit into `make test`

**Warning signs:**
- `git add -A` stages files that feel "wrong" (network configs, key files)
- Running `git ls-files --others --exclude-standard` shows files that should be ignored
- New project directories added to the repo accidentally bring `.env` files

**Phase to address:** Audit Phase 3 (.gitignore Hardening) — comprehensive pattern audit

---

### Pitfall 6: macOS Compatibility Assumptions That Break Silently

**What goes wrong:**
Several aliases and functions in `.zshrc` use GNU-specific flags that would fail silently (or with confusing errors) on macOS. The most impactful:

- **`alias duh='du -h --max-depth=1 | sort -hr'`** — `--max-depth=1` is GNU-only. BSD `du` on macOS uses `-d 1`. Running this alias on macOS without GNU coreutils installed produces an error like `du: illegal option -- -`. The `sort -hr` flag: GNU sort uses `-h` for human-readable sort; BSD sort interprets `-h` differently (or doesn't support it). This alias is completely broken on stock macOS.

- **`alias localip`** — Uses `ip addr show` on Linux. The `ip` command does not exist on macOS (part of iproute2, Linux-only). The guard `is_darwin` correctly falls back to `ifconfig`, so this works — but only because it was designed with cross-platform in mind. Other aliases lack this guard.

- **`HOMEBREW_PREFIX` detection** — The `brew --prefix` subshell on line 73 would hang or error if Homebrew is not installed on a Linux machine. The `command -v brew` guard mitigates this, but the shell startup still evaluates the conditional path.

- **OpenSpec completions path** — Line 3: `fpath=("/home/uzer/.oh-my-zsh/custom/completions" $fpath)` uses a hardcoded `/home/uzer` path that doesn't exist on macOS (macOS uses `/Users/uzer`).

**Why it happens:**
- Most development occurred on Ubuntu (Linux) — macOS testing was limited or deferred
- The cross-platform guards in `.zshrc` (lines 36-77, 105-109, 166-183) cover the obvious cases but not utility aliases like `duh`
- GNU coreutils are often available on macOS via Homebrew, masking the issue during casual use
- The hardcoded `/home/uzer` paths are Linux-specific and would need `/Users/uzer` on macOS

**Consequences:**
- `duh` alias throws errors on macOS: `du: illegal option -- -` followed by `sort: invalid option -- 'h'`
- OpenSpec completions never load on macOS because the fpath directory doesn't exist
- User confidence in cross-platform compatibility is eroded
- Hardcoded paths mean the dotfiles aren't truly portable to a different username

**Prevention:**
1. Fix `duh` alias: `if is_darwin; then alias duh='du -h -d 1 | sort -hr'; else alias duh='du -h --max-depth=1 | sort -hr'; fi`
2. Fix OpenSpec fpath: use `$HOME/.oh-my-zsh/custom/completions` instead of `/home/uzer/...`
3. Audit all aliases for GNU-specific flags: `--max-depth`, `--color=auto` (already guarded for `ll`), `--no-git` etc.
4. Add a `make test-macos` target or at minimum a static analysis that flags GNU-isms
5. Test in a macOS environment or use shellcheck with `--shell=bash` / manual review of BSD-vs-GNU flag usage

**Warning signs:**
- macOS terminal showing `du: illegal option` on startup
- `which du` returns `/usr/bin/du` (BSD) not a Homebrew-installed GNU du
- Hardcoded `/home/` paths in configs that would need `/Users/` on macOS

**Phase to address:** Audit Phase (Cross-Platform Validation) — fix GNU-isms, verify macOS assumptions

---

### Pitfall 7: OpenSpec Hardcoded Home Path Breaks Portability

**What goes wrong:**
Line 3 of `.zshrc`:
```zsh
fpath=("/home/uzer/.oh-my-zsh/custom/completions" $fpath)
```
This hardcodes `/home/uzer`, which only exists on Linux with username "uzer". On macOS the home directory is `/Users/uzer`. On any machine with a different username, the path is also wrong. This breaks OpenSpec shell completions.

**Why it happens:**
- Auto-generated code block (marked `# OPENSPEC:START` / `# OPENSPEC:END`) with a hardcoded absolute path
- The tool that generated this (OpenSpec) didn't use `$HOME` interpolation
- Hardcoded paths are easy to miss during review because the config "works on my machine"

**Consequences:**
- OpenSpec completions silently fail on macOS
- If username changes (new machine), completions also break on Linux
- The `autoload -Uz compinit` still runs, so no error is shown — just missing completions

**Prevention:**
Replace with: `fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)`

**Warning signs:**
- `grep "/home/" zsh/.zshrc` returns hardcoded home paths
- `echo $fpath | grep /home/` shows hardcoded paths in the completions search

**Phase to address:** Audit Phase (Cross-Platform Validation) — replace hardcoded paths with `$HOME`

---

### Pitfall 8: Over-Cleaning — Removing Useful Config During Sanitization

**What goes wrong:**
In the zeal to remove company references, useful non-company config could be deleted. The `.zshrc` currently has a healthy set of aliases (git, docker, pnpm, yt-dlp) and utility functions (mkcd, bak, killport, gpub, gmain, gql). An over-aggressive audit might flag things like the `gql()` function (which references `pnpm run` — could be misidentified as company-specific) or the Courtsite-related `sm` alias (which is actually a slicemachine alias for Prismic, not company-related at all).

**Why it happens:**
- Pattern-based scanning can't distinguish between "this mentions a company name" and "this is unrelated but uses a similar keyword"
- The `sm` alias is ambiguous: could be "sinar machine" or "slicemachine" — context matters
- A developer doing cleanup without domain knowledge might err on the side of deletion

**Consequences:**
- Loss of genuinely useful aliases and functions
- Productivity hit on the new machine when familiar shortcuts are gone
- Harder to restore deleted config than to verify it's clean

**Prevention:**
1. Before deleting anything, document what each alias/function does and why it exists
2. Use `git log -S "alias_name"` to find when and why something was added
3. Flag, don't auto-delete — have a human (or careful agent) review flagged items
4. The `audit-nvim-plugins` script in `bin/` is an example of useful tooling — don't remove it thinking it's "audit-related" company code
5. Add a `make audit-review` target that lists flagged items with context for manual review, rather than auto-stripping

**Warning signs:**
- `rg -i "courtsite\|sinar\|enjin"` returning false positives on `sm` (slicemachine) aliases
- Diff showing large deletions of config with no corresponding documentation
- Post-cleanup shell errors for missing aliases that were actually useful

**Phase to address:** Audit Phase (Sanitization Review) — flag-and-review, not auto-delete

---

### Pitfall 9: Shell History Contains Sensitive Commands and Useful Workflows

**What goes wrong:**
`~/.zsh_history` (4797 lines, 278KB) and `~/.bash_history` (8.5KB) contain:
- Potentially sensitive commands (company server IPs, internal URLs, connection strings with embedded passwords)
- Valuable workflow patterns that represent months/years of learned behaviors
- Commands that reveal project structure, toolchain choices, and development patterns

After machine wipe, all of this is lost. Some of it should be lost (sensitive commands), but some is valuable (workflow muscle memory).

**Why it happens:**
- Shell history is ephemeral by design — no one backs it up
- `HISTSIZE=5000` in `.zshrc` limits history but doesn't distinguish sensitive from useful
- No tooling exists to export, filter, or review shell history before wipe

**Consequences:**
- Useful commands, one-liners, and workflow patterns are permanently lost
- Sensitive commands become unrecoverable if the machine is accessed before wipe
- On the new machine, the user must rediscover workflows from scratch

**Prevention:**
1. Export shell history to a file: `history -E 1 > ~/shell-history-export.txt`
2. Review and filter: remove lines with passwords, tokens, internal IPs
3. Save filtered history for reference on the new machine
4. Add `HISTIGNORE` patterns to prevent passwords/tokens from entering history in the future
5. Consider `setopt histignorespace` (prepend sensitive commands with space to exclude from history)

**Warning signs:**
- `history | grep -i "password\|token\|secret\|api.key"` returns hits
- History file is unusually large (278KB for 4797 lines is normal, but contents matter)
- No export or backup of history planned before wipe

**Phase to address:** Audit Phase (Workflow Preservation) — export, filter, archive history

---

### Pitfall 10: Pre-Commit Hook Only Blocks Courtsite, Not Generic Secrets

**What goes wrong:**
The pre-commit hook (`.githooks/pre-commit`) runs two checks: (1) ripgrep for Courtsite references with the same exclusions as courtsite-guard, and (2) `make format` to catch unformatted files. It does NOT scan for:
- Generic credential patterns (API keys, tokens, passwords)
- WiFi passwords or PSKs
- SSH private keys
- Hardcoded home directory paths
- `.env` files being staged
- Certificate files being staged

The hook also has the same exclusion blind spots as the courtsite-guard (pitfall 2).

**Why it happens:**
- The hook was purpose-built for v1.2's Courtsite cleanup, not as a general security gate
- Secret scanning tools (gitleaks, trufflehog) require installation and haven't been integrated
- The current hook is intentionally minimal to avoid slowing down commits

**Consequences:**
- A commit containing a WiFi password (like the ZTE_EC382D.nmconnection file) passes the pre-commit hook
- API keys in new scripts or config files get committed without detection
- The hook provides a false sense of security for non-Courtsite secrets

**Prevention:**
1. Add generic secret scanning to the pre-commit hook using ripgrep patterns (no external dependencies):
   ```sh
   # Generic secret patterns
   PATTERNS='psk=|wpa-psk|password\s*=|BEGIN (OPENSSH|RSA|DSA|EC) PRIVATE KEY|api[_-]?key\s*=|token\s*=|secret\s*='
   ```
2. Block `.env`, `.nmconnection`, `.pem`, `.key`, `.pfx` files from being staged (warn, don't just ignore)
3. Consider integrating gitleaks as a second-pass scanner if installed (graceful fallback if not)
4. Add pre-commit hook verification to `make test`

**Warning signs:**
- `git diff --cached | rg "psk=|BEGIN.*PRIVATE KEY"` returns hits before committing
- New files with extensions like `.pem`, `.key`, `.env` appear in `git status`
- Secret files committed without pre-commit hook firing

**Phase to address:** Audit Phase 3 (.gitignore Hardening) — expand pre-commit to generic secrets

---

### Pitfall 11: Scan Scope Creep — False Positives in Audit Tools

**What goes wrong:**
As the audit radius expands from "repo dotfiles" to "home directory" to "full machine", the number of false positives explodes. Scanning `~/` for "courtsite" would also hit:
- Browser caches, history files, and bookmarks
- `~/Courtsite/` itself (8.8GB of company code — millions of matches)
- Package manager caches (npm, pip, cargo) that may cache packages named after company projects
- `.planning/` documents that legitimately discuss the cleanup process
- Log files from company applications
- Git repositories in `~/uz6r/` and `~/Courtsite/` that reference company names

Without careful scoping, the audit produces an unreadable wall of noise.

**Why it happens:**
- Broad ripgrep scans without path exclusions hit everything
- No distinction between "file contains company reference" (expected in Courtsite source code) and "file should not contain company reference" (dotfiles config)
- The scanner doesn't understand context — it's just regex matching

**Consequences:**
- Audit reports are too noisy to be actionable
- Real issues buried under thousands of expected matches
- Developer fatigue — "everything is flagged, nothing gets fixed"

**Prevention:**
1. Use explicit scan targets, not broad `~/` sweeps: scan `~/.zshrc`, `~/.zshrc.local`, `~/.gitconfig`, `~/.gitconfig.local`, `~/dotfiles/`, `~/.ssh/config`, `~/.aws/`, `~/.config/`
2. Exclude known directories: `~/Courtsite/`, `~/Downloads/`, `~/Desktop/`, `~/.cache/`, `~/.npm/`, `~/.cargo/`
3. Produce categorized output: "Critical: secret in dotfiles" vs "Info: reference in project source code"
4. Let the user configure their audit radius: `make audit-home` (targeted) vs `make audit-full` (comprehensive with exclusions)
5. Use ripgrep's `--glob` and `--iglob` extensively for precise targeting

**Warning signs:**
- Audit output exceeds 100 lines of matches
- `rg -c "courtsite" ~/` returns hundreds of thousands of hits
- No clear categorization between "expected reference" and "unexpected reference"

**Phase to address:** Audit Phase (Scan Tooling) — design targeted, categorized audit scans

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Skip SSH key backup before wipe | Saves 30 seconds | Permanent access loss to all servers/services | Never — always backup |
| Delete `.zsh_history` without review | Quick wipe | Lose years of useful commands and workflows | Never — export and filter first |
| Exclude directories from scan (`.planning/`, `.githooks/`) | Fewer false positives | Blind spots for new references | Only with marker-based allowlist |
| Ignore `.zshrc.local` because it's gitignored | Saves manual review time | Courtsite aliases persist and are active | Never — audit local state too |
| Assume macOS "just works" because `is_darwin` guards exist | Faster delivery | Silent breakage on `duh`, OpenSpec completions, hardcoded paths | Never — test or static-analyze |
| Use hardcoded `/home/uzer` in auto-generated code blocks | Tool-generated, "works for me" | Broken on macOS, different usernames, or non-Linux | Never — use `$HOME` |

## Integration Gotchas

Common mistakes with existing guard/verify tooling.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| courtsite-guard | Assuming its exclusions are always safe | Review exclusions per milestone; tighten when possible |
| verify-cleanup | Running it once, not continuously | Keep it integrated into `make test` as a hard gate |
| pre-commit hook | Copying court-guard exclusions blindly | Add generic secret scanning alongside Courtsite scanning |
| ripgrep scanning | Using same patterns for all scan scopes | Categorize: secrets (broad, few matches) vs company refs (targeted to dotfiles) |
| stow symlinks | Forgetting that `.zshrc.local` symlink still points into the repo | Check `ls -la ~/.zshrc.local` to see where it points |
| `make test` | Assuming it covers everything audit-related | Add secret-scan, local-state-check, and macos-compat-check targets |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| nmconnection file tracked in git | WiFi password exposed to all repo accessors | `git rm --cached` + `.gitignore` + rotate password |
| No secret scanning in pre-commit | Tokens, keys, passwords committed undetected | Add `rg` patterns for generic secrets + optional gitleaks |
| Hardcoded home paths in config | Username enumeration, portability failure | Replace `/home/uzer` with `$HOME` everywhere |
| `.gitignore` missing .env, key, cert patterns | Accidental commit of API keys, private keys | Add comprehensive security patterns |
| SSH private keys not backed up | Permanent access loss after machine wipe | Encrypted backup or export to password manager |
| Shell history contains passwords | Credentials visible in `history` output | `setopt histignorespace` + HISTIGNORE patterns |
| `verify-cleanup` produces warnings not errors | Cleanup issues get ignored over time | Make it a hard failure in `make test` |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Courtsite references:** `make test` passes but `grep -i courtsite ~/.zshrc.local` returns hits — **verify local state files**
- [ ] **WiFi secrets:** `make test` passes but `ZTE_EC382D.nmconnection` is tracked with PSK — **audit tracked files for credentials**
- [ ] **SSH keys:** Dotfiles are portable but `~/.ssh/id_*` not backed up — **verify key backup exists**
- [ ] **Shell history:** Dotfiles are clean but `~/.zsh_history` contains sensitive commands — **export, review, filter**
- [ ] **Home directory audit:** Repo is clean but `~/Courtsite/` is 8.8GB — **sweep home directory for company artifacts**
- [ ] **.gitignore coverage:** `*.local` works but `.env*`, `*.nmconnection`, `*.pem` not covered — **add security patterns**
- [ ] **macOS compatibility:** `is_darwin` guards exist but `duh` alias uses GNU-only `--max-depth=1` — **audit all aliases for GNU-isms**
- [ ] **Hardcoded paths:** OpenSpec block uses `/home/uzer` instead of `$HOME` — **replace all hardcoded home paths**
- [ ] **Pre-commit scanning:** Hook blocks Courtsite but not generic secrets — **add credential pattern matching**
- [ ] **Scan exclusion review:** `courtsite-guard` excludes `.planning/`, `.githooks/`, `Makefile` — **tighten to allowlist markers**
- [ ] **Project .env files:** `lembayung/.env.local` has API keys — **backup or rotate before wipe**
- [ ] **Git identity:** `~/.gitconfig.local` may have name/email config — **verify it's backed up or documented**

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Tracked WiFi password in git | MEDIUM | `git rm --cached` + `.gitignore` + rotate password on router |
| Lost SSH keys (no backup) | HIGH | Regenerate all key pairs, update authorized_keys on all servers, update GitHub/GitLab SSH keys |
| Lost shell history | MEDIUM | Start fresh; document commonly used commands from memory; check other machines for partial history |
| Lost .env API keys | MEDIUM | Regenerate API keys from each service's dashboard |
| macOS alias broken | LOW | Fix in `.zshrc`, test on macOS, commit fix |
| False negative in court-scan | LOW | Tighten exclusions, add allowlist markers, re-run scan |
| Over-cleaned useful config | MEDIUM | `git reflog` or `git log --all` to find deleted content; restore selectively |
| Committed secrets to git history | HIGH | `git filter-repo` + force push + rotate all credentials |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| 1. WiFi password tracked in git | Audit Phase (Secrets Scan) | `git ls-files | rg nmconnection` returns empty; PSK rotated |
| 2. Scanner blind spots from exclusions | Audit Phase (Scan Hardening) | `courtsite-guard` uses allowlist markers not blanket exclusions |
| 3. Local .zshrc.local on disk | Audit Phase (Secrets Scan) | `grep -i courtsite ~/.zshrc.local` returns empty |
| 4. Home dir ecosystem outside scope | Audit Phase (Home Sweep) | `make audit-home` reports clean or documents artifacts |
| 5. .gitignore coverage gaps | Audit Phase (Gitignore Hardening) | `.gitignore` covers .env, .nmconnection, keys, certs |
| 6. macOS compatibility (duh, OpenSpec) | Audit Phase (Cross-Platform) | macOS `duh` works; `grep /home/ zsh/.zshrc` returns empty |
| 7. Hardcoded /home/uzer paths | Audit Phase (Cross-Platform) | All paths use `$HOME`; `grep /home/ .` returns only `.planning/` (expected) |
| 8. Over-cleaning useful config | Audit Phase (Sanitization Review) | Flag-and-review workflow; no auto-deletion without context |
| 9. Shell history loss | Audit Phase (Workflow Preservation) | History exported, filtered, archived before wipe |
| 10. Pre-commit missing generic secrets | Audit Phase (Gitignore Hardening) | Hook blocks `psk=`, `BEGIN.*PRIVATE KEY`, `.env` staging |
| 11. False positives in broad scans | Audit Phase (Scan Tooling) | Categorized output; targeted scan targets with exclusions |

## How This Integrates With Existing Tooling

The existing guard infrastructure (`courtsite-guard`, `verify-cleanup`, pre-commit hook, `make test`) provides a solid foundation, but the v1.3 audit must extend it:

| Existing Tool | Gap | v1.3 Extension |
|---------------|-----|----------------|
| `courtsite-guard` | Excludes `.planning/`, `.githooks/`, `Makefile` | Replace blanket exclusions with `# GUARD:ALLOW` comment markers on specific lines |
| `verify-cleanup` | Only scans tracked files in repo | Add `verify-cleanup-local` that also scans `~/.zshrc.local`, `~/.gitconfig.local` |
| pre-commit hook | Only Courtsite patterns | Add generic secret patterns: PSK, private keys, API key formats |
| `make test` | Tests shell syntax, git config, nvim, courtsite | Add `make audit-secrets`, `make audit-home`, `make audit-macos` targets |
| `.gitignore` | `*.local`, `.zsh_history`, swap files | Add `.env*`, `*.nmconnection`, `*.pem`, `*.key`, `*.pfx`, `credentials`, `.npmrc`, `.aws/` |
| `bin/audit-nvim-plugins` | Neovim plugin listing only | Consider `bin/audit-secrets` and `bin/audit-home` as new audit tools |

## Sources

- **Direct repository investigation (HIGH confidence):**
  - `ZTE_EC382D.nmconnection` — tracked file with WiFi PSK confirmed via direct inspection
  - `zsh/.zshrc.local` — gitignored file with Courtsite aliases confirmed via direct inspection
  - `~/Courtsite/` — 8.8GB company source directory confirmed via `du -sh`
  - `.gitignore` — coverage gaps confirmed via direct comparison with security best practices
  - `.zshrc` line 3 — hardcoded `/home/uzer` path confirmed via direct inspection
  - `.zshrc` `duh` alias — GNU-only `--max-depth=1` flag confirmed via direct inspection
  - Shell history — 4797 lines in `~/.zsh_history` confirmed via `wc -l`
  - Pre-commit hook — no generic secret scanning confirmed via direct inspection

- **Official documentation (HIGH confidence):**
  - [InstaTunnel Blog: Dotfiles Security Minefield](https://instatunnel.my/blog/why-your-public-dotfiles-are-a-security-minefield) — Secret separation, pre-commit hooks, gitleaks, git-filter-repo patterns
  - [Tech Champion: Cross-Platform Shell Linux vs macOS](https://tech-champion.com/linux/write-cross-platform-shell-linux-vs-macos-differences-that-break-production/) — GNU vs BSD coreutils differences (sed, grep, du, stat, date), filesystem case sensitivity, shebang portability

- **Community knowledge (MEDIUM confidence):**
  - [timkicker/dotfiles SECURITY.md](https://github.com/timkicker/dotfiles/security) — Comprehensive `.gitignore` patterns, pre-push checklist, secret scanning commands, history scrubbing procedures
  - Previous research in `.planning/research/PITFALLS.md` (v1.2) — Courtsite cleanup pitfalls, cross-platform guard patterns, stow symlink management

- **Existing project context (HIGH confidence):**
  - `.planning/PROJECT.md` — Current state, milestone goals, validated/deferred requirements
  - `.planning/ROADMAP.md` — Completed milestones, deferred items (GIT-01)
  - `Makefile` — Existing targets, guard implementations, test pipeline
  - `.githooks/pre-commit` — Current scanning patterns and exclusions

---

*Pitfalls research for: v1.3 Final Audit & Sanitization before workstation reset*
*Researched: 2026-05-26*
