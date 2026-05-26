# Project Research Summary

**Project:** Dotfiles v1.3 — Final Audit & Sanitization before Laptop Reset
**Domain:** Dotfile audit, sanitization, cross-platform hardening, workflow preservation, public-safe structure
**Researched:** 2026-05-26
**Confidence:** HIGH

## Executive Summary

This is a **pre-machine-wipe audit and sanitization** of a personal dotfiles repository managed with GNU Stow, targeting zsh, neovim, tmux, and git configurations. The research across all four domains (stack, features, architecture, pitfalls) converges on a single conclusion: the v1.2 cleanup successfully removed Courtsite (company) references from tracked files, but a comprehensive pre-wipe sweep reveals **one live secret (WiFi PSK tracked in git history), multiple hardcoded path leaks, binary bloat (29MB of lazygit artifacts), macOS incompatibilities in 4 aliases/scripts, and a .gitignore that lacks coverage for generic credential patterns**. The repo is not ready for public exposure or machine disposal.

The recommended approach is a **four-phase execution**: (1) immediately remediate the critical security issues — delete the nmconnection WiFi credential, remove lazygit binaries, fix hardcoded paths; (2) build verification infrastructure — gitleaks secret scanning, expanded pre-commit hooks, audit/sanitize Makefile targets, .gitignore hardening; (3) fix macOS compatibility — GNU-ism remediation in `du`, `readlink`, `grep`, and `date` usage plus hardcoded `/home/uzer` paths; (4) preserve workflows — export and filter shell history, generate a pre-reset checklist, document the public/private boundary with a `private/` directory. The architecture supports this order: audit infrastructure (Phase 2) must exist before remediation (Phase 1) can be verified safe, but the critical issues are severe enough that they should be triaged immediately with manual fixes, then verified by the tooling built in Phase 2.

Key risks: (a) the `ZTE_EC382D.nmconnection` file has been committed — deleting it from HEAD leaves the WiFi password in git history, requiring `git filter-repo` if the repo ever goes public; (b) the existing `courtsite-guard` has exclusion blind spots (`.planning/`, `.githooks/`, `Makefile`) that could allow company references to re-enter through planning documents; (c) the user's local `.zshrc.local` still contains 16 lines of active Courtsite aliases that are gitignored but sourced at shell startup; (d) shell history (4797 lines) and the `~/Courtsite/` source directory (8.8GB) exist entirely outside the dotfiles repo scope and will be permanently lost after machine wipe unless explicitly preserved.

## Key Findings

### Recommended Stack

The audit toolchain is built on single-binary, zero-runtime-dependency tools that already align with the project's Makefile-based philosophy. The core addition is **Gitleaks** (MIT license, Go binary, offline-capable) for secrets scanning — chosen over TruffleHog (AGPL, bloated 800+ detectors), ggshield (requires GitGuardian cloud account), and detect-secrets (requires Python runtime). Existing tools require version upgrades: ShellCheck from 0.8.0 → 0.11.0 (improved zsh support, SC2xxx portability rules), shfmt to v3.13.1 (full zsh parser), ripgrep from 13.0.0 → 14.x (optional, for `--field-match-separator`). GNU Stow remains the symlink manager — its `--restow` flag is naturally idempotent and `chkstow -b` finds broken symlinks. Nothing requires Docker, Python, Node, or any language runtime.

**Core technologies:**
- **Gitleaks v8.30.1**: Secrets and credential scanning — single Go binary, 170+ built-in rules, pre-commit integration, configurable `.gitleaks.toml`, feature-complete (security patches only), MIT license
- **ShellCheck v0.11.0** (`--shell=zsh`): Shell portability and quality linting — catches GNU-isms (SC2xxx), unused variables (SC2034 for stale config), undefined references, zsh-specific improvements
- **ripgrep 14.x+**: Pattern-based content scanning — powers company reference detection, stale alias hunting, hardcoded path discovery, and binary file identification across all audit domains
- **shfmt v3.13.1**: Shell formatting and syntax validation — normalizes scripts, catches syntax errors indicative of stale/broken config
- **GNU Stow 2.x+**: Symlink idempotency — `--restow` won't clobber, `chkstow -b` finds broken symlinks (stale config indicator)

### Expected Features

The feature landscape spans five categories, all converging on "make this repo safe to keep, safe to migrate, and safe to make public."

**Must have (table stakes — critical security):**
- **Remove `ZTE_EC382D.nmconnection`** — contains plaintext WiFi PSK (`psk=7A33S6282B`), tracked in git history; requires deletion + `.gitignore` + history scrub if repo goes public
- **Remove `lazygit` binary + `lazygit.tar.gz`** — 21MB ELF binary + 7.6MB tarball tracked in git; replace with Homebrew/script installation
- **Fix hardcoded `/home/uzer` paths** — 3 locations: `.zshrc:3` (fpath), `.zshrc:365` (OpenCode PATH), `bin/audit-nvim-plugins:7` (CONFIG_FILE); replace with `$HOME`
- **Expand `.gitignore`** — add patterns for `*.nmconnection`, `.env*`, `*.pem`, `*.key`, `*.pfx`, `credentials`, `.npmrc`, `.aws/`, `private/`
- **Fix macOS incompatibilities** — `du --max-depth=1` (GNU-only, needs `-d 1`), `readlink -f` (needs `greadlink` fallback), `grep -oP` (needs `-oE` or `rg`), `date +%s%N` (GNU-only, needs perl fallback or drop nanosecond precision)

**Should have (prevention & documentation):**
- **`make sanitize`** — comprehensive zero-tolerance scan (gitleaks + company refs + hardcoded paths + binaries + .nmconnection check)
- **`make macos-check`** — static analysis for GNU-only flags, BSD incompatibilities across all tracked scripts
- **`make public-ready`** — pre-open-source aggregator wrapping sanitize + macos-check + gitignore audit + history check
- **`make doctor`** — comprehensive health check aggregating test + audit + sanitize + compat + gitignore audit
- **`bin/audit-workflow`** — shell history profiler extracting top 50 commands, custom function usage, untracked script inventory
- **`PRE-RESET-CHECKLIST.md`** — comprehensive guide for what the user must do locally before machine wipe (`.zshrc.local` cleanup, SSH key backup, shell history export, Brew package list)
- **`.zshrc.local.example`** — template with placeholder patterns for new machine setup

**Defer (v1.4+):**
- **Modular nvim `init.lua` split** — 472-line monolith → `lua/options.lua`, `lua/keymaps.lua`, `lua/plugins.lua`, `lua/lsp.lua`
- **CI macOS runner** — cost/benefit for personal dotfiles; 10x Linux minute cost on GitHub Actions
- **Git history full scrub** — `git filter-repo` to remove `ZTE_EC382D.nmconnection` from history; only if repo goes public

### Architecture Approach

The architecture layers audit/verification on top of the existing dotfiles infrastructure without restructuring. Three new layers are added: (1) **Verification Layer** — 5 new `bin/audit-*` scripts and 1 `bin/verify-macos` script, each single-responsibility, running in dual REPORT/STRICT modes; (2) **Guard Layer** — extended pre-commit hook (adds secret + binary detection), enhanced CI pipeline (`make verify` job), and a new `make verify` super-meta target; (3) **Boundary Layer** — new `private/` directory as explicit public-vs-private boundary, with expanded `.gitignore` coverage.

The core architectural pattern is **audit vs. sanitize: same detection scripts, dual modes**. Each `bin/audit-*` script supports REPORT mode (print findings, exit 0 — for developer workflows) and STRICT mode (exit 1 on any finding — for pre-commit gates and CI). The Makefile exposes `make audit` (REPORT, non-blocking), `make sanitize` (STRICT, zero-tolerance), and `make verify` (super-meta: test + sanitize + compat). Pre-commit runs only the fastest checks (secret scan of staged files, binary detection, courtsite guard, format) — full audit runs in CI.

**Major components:**
1. **`bin/audit-secrets`** — scans tracked files for API keys, tokens, passwords, WiFi PSKs using regex patterns; dual-mode (REPORT/STRICT)
2. **`bin/audit-binaries`** — detects binary/large files committed to repo using `file` command; flags lazygit artifacts, .nmconnection files
3. **`bin/audit-hardcoded`** — finds hardcoded home paths, IPs, personal data (email, usernames) in tracked files
4. **`bin/audit-stale`** — cross-references Makefile packages vs stow directories; finds empty dirs, broken symlinks, dead PATH references
5. **`bin/verify-macos`** — static analysis for GNU-only flags (`--max-depth`, `readlink -f`, `grep -P`, `date +%N`, `sed -i` without `''`, `stat -c`, `ps -eo`) across all tracked scripts
6. **`Makefile` meta-targets** — `make audit` (REPORT chain), `make sanitize` (STRICT chain), `make verify` (super-meta: test + sanitize + compat), `make doctor` (comprehensive health)

### Critical Pitfalls

The research identified 11 pitfalls. The top 5 that must be addressed in planning:

1. **WiFi password tracked in git history** — `ZTE_EC382D.nmconnection` contains `psk=7A33S6282B` and has been committed. Prevention: `git rm --cached` + `.gitignore` + gitleaks pre-commit + rotate password on router. If repo goes public: `git filter-repo` + force push + credential rotation.

2. **Sanitization scanner blind spots from exclusions** — `courtsite-guard` excludes `.planning/`, `.githooks/`, and `Makefile`, creating paths where company references could re-enter undetected. Prevention: Replace blanket exclusions with `# GUARD:ALLOW` comment markers on specific lines; run `verify-cleanup` (no exclusions) as a hard failure in `make test`.

3. **Local `.zshrc.local` still has active Courtsite aliases** — 16 lines of company aliases are gitignored but sourced at shell startup. The aliases are active in the current shell but invisible to all scanners. Prevention: Manual cleanup + `make audit-local` target that scans `~/.zshrc.local`, `~/.gitconfig.local` on disk.

4. **Home directory ecosystem entirely outside repo scope** — `~/Courtsite/` (8.8GB source code), SSH keys (`~/.ssh/id_*`), shell history (4797 lines), project `.env` files with API keys all exist outside the dotfiles repo and will be permanently lost after machine wipe. Prevention: `make audit-home` target for targeted home-directory scanning; `PRE-RESET-CHECKLIST.md` documenting what must be backed up vs. securely deleted.

5. **macOS assumptions break silently** — `duh` alias uses `--max-depth=1` (GNU-only), OpenSpec fpath uses `/home/uzer` (doesn't exist on macOS `/Users/uzer`), and several scripts use GNU-specific flags (`grep -oP`, `date +%s%N`, `readlink -f`). These don't produce errors in CI (Linux-only runner) and would silently fail on macOS. Prevention: `make macos-check` static analysis + platform guards (`is_darwin`/`is_linux`) for flag differences.

## Implications for Roadmap

Based on combined research from all four agents, the v1.3 milestone should be structured into **4 sequential phases** that follow a "stop the bleeding → build the gates → harden the edges → preserve what matters" progression.

### Phase 1: Critical Remediation (Triage)
**Rationale:** The WiFi password (`ZTE_EC382D.nmconnection`) and 29MB of binary bloat (`lazygit` + `lazygit.tar.gz`) are live in the repo right now. Every commit that doesn't address them is a commit that carries these liabilities forward. Hardcoded paths break portability immediately. These are the "stop the bleeding" items — fix them before building tooling that will simply detect what you already know is broken. The architecture (Phase C) depends on gates (Phase B) to prevent re-introduction of removed files, but the severity of a live credential tracked in git justifies immediate manual triage with retrospective verification.

**Delivers:**
- Deleted `ZTE_EC382D.nmconnection` + `*.nmconnection` in `.gitignore`
- Removed `lazygit` binary + `lazygit.tar.gz` + patterns in `.gitignore`
- Fixed hardcoded `/home/uzer` → `$HOME` in `.zshrc:3`, `.zshrc:365`, `bin/audit-nvim-plugins:7`
- Removed stale `scripts/` PATH entry from `.zshrc:80` + deleted empty `scripts/` directory
- Expanded `.gitignore` with security patterns: `.env*`, `*.pem`, `*.key`, `*.pfx`, `credentials`, `.npmrc`, `.aws/`, `private/`

**Addresses:** FEATURES.md Phase 1 (Critical Security items 1-4)
**Avoids:** Pitfall 1 (WiFi password), Pitfall 5 (.gitignore gaps), Pitfall 7 (hardcoded paths)

### Phase 2: Verification Infrastructure (Gates)
**Rationale:** Once the known critical issues are resolved, build the automated tooling that prevents regression. This follows the architecture's Phase A→B→C pattern: create the audit scripts first, wrap them in Makefile targets, then extend the pre-commit hook and CI pipeline using the same scripts in STRICT mode. The dual-mode pattern (REPORT/STRICT) means the same detection logic serves both "show me what's wrong" (`make audit`) and "block the door" (pre-commit/CI). This phase also installs Gitleaks as the primary secrets scanner, integrated into both `make sanitize` and pre-commit.

**Delivers:**
- **5 new `bin/audit-*` scripts**: `audit-secrets`, `audit-binaries`, `audit-stale`, `audit-hardcoded` (all dual-mode REPORT/STRICT)
- **`make audit`** meta-target — chain all audit scripts in REPORT mode, produce comprehensive report
- **`make sanitize`** meta-target — chain audit scripts in STRICT mode, exit 1 on any finding
- **Gitleaks v8.30.1 installation** + `.gitleaks.toml` config with custom rules (SSH keys, home paths, internal URLs)
- **Extended pre-commit hook** — adds secret scanning (fast regex on staged files) + binary detection + courtsite guard (unchanged) + format check (unchanged)
- **Extended CI pipeline** — adds `make verify` job (test + sanitize + compat) after existing lint-format job
- **`make verify`** super-meta target — comprehensive gate: `make test` (unchanged) + `make sanitize` (STRICT) + `make verify-compat`

**Uses:** Gitleaks v8.30.1, ShellCheck v0.11.0, ripgrep 14.x, shfmt v3.13.1
**Implements:** Architecture Verification Layer + Guard Layer + Boundary Layer
**Avoids:** Pitfall 2 (scanner blind spots), Pitfall 10 (pre-commit missing generic secrets), Pitfall 11 (false positives — categorized output)

### Phase 3: Cross-Platform Hardening (macOS Readiness)
**Rationale:** The project has been Linux-only for its entire history. With a macOS migration on the horizon, 4 specific GNU-isms must be fixed before the dotfiles are useful on a Mac. Static analysis (`bin/verify-macos`, integrated as `make macos-check`) catches Linux-only assumptions that shellcheck misses. Platform guards (`is_darwin`/`is_linux`) are already established in `.zshrc` — extend the pattern to utility aliases and scripts. This phase also cleans up the `courtsite-guard` exclusion policy, replacing blanket exclusions with targeted allowlist markers.

**Delivers:**
- **Fixed `duh` alias** (`.zshrc:130`): platform guard for `--max-depth=1` (Linux) vs `-d 1` (macOS)
- **Fixed `readlink -f`** (`Makefile:40`): fallback chain `readlink` → `greadlink` → `echo`
- **Fixed `grep -oP`** (`bin/audit-nvim-plugins:16`): replace with `grep -oE` or `rg`
- **Fixed `date +%s%N`** (`bin/profile-zsh:38`): drop nanosecond precision or add perl fallback
- **`bin/verify-macos`** script — static analyzer for known GNU-only patterns across all tracked files
- **`make macos-check`** target — wraps `bin/verify-macos` with advisory (non-blocking) exit semantics
- **Tightened `courtsite-guard` exclusions** — replace blanket `.planning/`/`.githooks/` exclusions with `# GUARD:ALLOW-courtsite-reference` comment markers on specific lines
- **Updated `CONCERNS.md`** — remove resolved v1.2 items, add v1.3 concerns

**Implements:** Architecture Phase D (Cross-Platform Verification)
**Avoids:** Pitfall 6 (macOS silent breakage), Pitfall 7 (OpenSpec hardcoded path), Pitfall 2 (scanner blind spots)

### Phase 4: Workflow Preservation & Documentation (Future-Proofing)
**Rationale:** After the repo is clean, safe, and portable, the final concern is what lives *outside* the repo. Shell history (4797 lines of learned workflows), SSH keys, project `.env` files, and the `~/Courtsite/` source directory will all be permanently lost after machine wipe. This phase generates documentation and tooling to help the user decide what to preserve, what to export, and what to securely delete. It also creates the `private/` directory as an explicit boundary between public-tracked and private-local state, establishing a convention that survives the wipe.

**Delivers:**
- **`bin/audit-workflow`** — shell history profiler (top 50 commands, custom function usage, untracked script inventory, WORKFLOW.md generation with anonymized paths)
- **`PRE-RESET-CHECKLIST.md`** — comprehensive guide: `.zshrc.local` cleanup commands, SSH key backup instructions, shell history export/filter steps, Brew package list export, `.gitconfig.local` review, project `.env` backup, Courtsite directory disposition
- **`.zshrc.local.example`** — template with placeholder patterns for new machine setup (commented examples, not real config)
- **`make doctor`** — comprehensive health check aggregating test + audit + sanitize + compat + gitignore audit + hardcoded path check + stale check
- **`make public-ready`** — pre-open-source checklist wrapping sanitize + macos-check + gitignore audit + history check
- **`private/` directory** — explicit public-vs-private boundary with `README.md` documenting the convention; gitignored entirely
- **`make audit-home`** target — targeted home-directory scan (`.ssh/`, `.zsh_history`, `.gitconfig.local`, `.zshrc.local`, `~/.npmrc`, `~/.aws/`) with explicit exclusion of `~/Courtsite/`, `~/.cache/`, `~/Downloads/`

**Addresses:** FEATURES.md Phase 3 (Workflow & Documentation items 9-12)
**Avoids:** Pitfall 3 (local .zshrc.local on disk), Pitfall 4 (home ecosystem outside scope), Pitfall 8 (over-cleaning — flag-and-review, not auto-delete), Pitfall 9 (shell history loss)

### Phase Ordering Rationale

The phase order is dictated by dependency chains discovered across all four research files:

- **Phase 1 before Phase 2** because you must remove known secrets before building automated scanners that would immediately fail on them. Manual triage of the 4 critical issues (WiFi password, binaries, hardcoded paths, .gitignore gaps) creates a clean baseline for the verification tooling to enforce.
- **Phase 2 before Phase 3** because the audit scripts (Phase 2) provide the detection foundation that `bin/verify-macos` (Phase 3) extends. The `--strict` mode established in Phase 2 carries through to macOS compatibility checks. The tightened `courtsite-guard` exclusion policy (Phase 3) depends on the audit infrastructure's allowlist marker pattern (Phase 2).
- **Phase 3 before Phase 4** because the repo must be cross-platform clean before documenting "here's what a new macOS machine needs." The `make doctor` target (Phase 4) depends on `make verify-compat` (Phase 3) existing as a sub-target.
- **Phase 4 last** because workflow preservation and documentation are valuable but not blocking — the machine can be wiped without them, but the user would lose years of shell history and configuration context. This phase is the "quality of life" capstone that makes the transition smooth.

**Cross-cutting concerns** (addressed across multiple phases):
- The `courtsite-guard` exclusion blind spot (Pitfall 2) is initially documented in Phase 1 (awareness), tightened in Phase 3 (allowlist markers), and verified in Phase 4 (`make doctor` coverage).
- The `.gitignore` is expanded in Phase 1 (critical patterns), validated in Phase 2 (`audit-binaries`, `audit-secrets` use it as exclusion reference), and audited in Phase 4 (`make doctor` includes gitignore coverage check).
- The `.zshrc.local` problem (Pitfall 3) is flagged in Phase 1 (must be documented), checked by Phase 2 (`audit-local` awareness), and given a cleanup guide in Phase 4 (`PRE-RESET-CHECKLIST.md`).

### Research Flags

**Phases likely needing deeper research during planning:**
- **Phase 4 (Workflow Preservation):** Shell history parsing, anonymization, and WORKFLOW.md generation is heuristic — the `audit-workflow` script design needs validation against actual `.zsh_history` content. Anonymization patterns may miss edge cases (internal hostnames, IPs in command arguments). Recommend a `/gsd-research-phase` spike during Phase 4 planning to test parsing against real history data.
- **Phase 3 (macOS Readiness):** `bin/verify-macos` static analysis can only catch known patterns. Actual macOS testing is deferred (no macOS runner in CI). There may be runtime issues that static analysis misses (e.g., `stow` flag differences, `sort -hr` behavior on older macOS). Recommend manual macOS smoke test before Phase 4.

**Phases with standard patterns (skip research-phase):**
- **Phase 1 (Critical Remediation):** All issues are already identified with exact file locations, line numbers, and fix patterns. No research needed — this is straightforward execution of documented fixes.
- **Phase 2 (Verification Infrastructure):** The architecture is fully specified with script outlines, Makefile target definitions, and pre-commit integration patterns. Gitleaks configuration is documented with custom rules. Standard Makefile + shell scripting patterns — no unknowns.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | **HIGH** | All tools directly inspected: Gitleaks (MIT, single binary, offline), ShellCheck (upgrade path verified), ripgrep (existing in project), GNU Stow (existing). Alternatives evaluated and rejected with documented rationale. Version compatibility matrix provided. |
| Features | **HIGH** | Every feature derived from direct repository scanning: `rg` scans of all tracked files, git state inspection, file content audit. Issues identified with exact file paths and line numbers. CRITICAL issues (WiFi password, binary bloat) confirmed via `head -n 20 ZTE_EC382D.nmconnection` and `file lazygit`. The 336-line FEATURES.md includes concrete fix commands for every issue. |
| Architecture | **HIGH** | Architecture derived from existing Makefile patterns, pre-commit hook structure, and formal patterns from ARCHITECTURE.md v1.2. All new components maintain the existing "scripts in bin/, orchestration in Makefile, gates in pre-commit" pattern. Component responsibilities, data flow, and integration points are fully specified with code examples for each architectural pattern. |
| Pitfalls | **HIGH** | All 11 pitfalls confirmed via direct repository inspection: `ZTE_EC382D.nmconnection` content verified, `~/.zshrc.local` contents audited, `~/Courtsite/` size confirmed via `du -sh`, shell history line count verified, pre-commit hook logic inspected. Pitfall-to-phase mapping provided for each. Recovery strategies documented for all scenarios. |

**Overall confidence:** HIGH — all findings based on direct repository inspection, official documentation, and existing project patterns. No speculative features or unverified assumptions.

### Gaps to Address

- **Git history scrub strategy:** If the repo ever goes public, `ZTE_EC382D.nmconnection` exists in git history. The research covers `git filter-repo` usage and credential rotation, but the decision of *when* to scrub (before or after push) and coordination with existing clones remains a deferred decision. Addressed in PROJECT.md GIT-01 (deferred). Not blocking for v1.3 audit.
- **macOS runtime testing:** All macOS compatibility fixes are based on static analysis of GNU-vs-BSD flag differences. No actual macOS test run has been performed. `bin/verify-macos` catches known patterns but cannot test runtime behavior (e.g., `stow` flag differences, `sort -hr` on older macOS). Mitigated by deferring CI macOS runner to v1.4 but flagging for manual smoke test before Phase 4.
- **Shell history anonymization completeness:** The `audit-workflow` script's anonymization (path replacement, hostname stripping) is heuristic. Edge cases like internal IPs in command arguments or connection strings with embedded credentials may survive filtering. Mitigated by making anonymization a separate, optional step with clear warnings — raw history is never committed.
- **`private/` directory convention adoption:** The `private/` directory is a new architectural pattern for this repo. Existing `.zshrc.local` lives in `zsh/` (stow package directory) and is sourced from `$HOME/.zshrc.local` (decoupled from stow location). Whether to physically relocate `.zshrc.local` to `private/` or simply document the convention requires user decision during planning. Architecture provides both options.

## Sources

### Primary (HIGH confidence)
- **Direct repository investigation** (2026-05-26) — All tracked files scanned with `rg`, git state inspected, file contents audited, nmconnection WiFi PSK confirmed, lazygit binary confirmed via `file`, shell history size confirmed, home directory ecosystem mapped
- **Existing project artifacts** — `Makefile` (all targets analyzed), `.githooks/pre-commit` (hook logic inspected), `.github/workflows/ci.yml` (CI pipeline analyzed), `.planning/codebase/STACK.md` (current tool inventory), `.planning/PROJECT.md` (milestone definition), `.planning/ROADMAP.md` (completed milestones)
- **[GitHub: gitleaks/gitleaks v8.30.1](https://github.com/gitleaks/gitleaks)** — README, config format, pre-commit integration, feature-complete announcement
- **[GitHub: koalaman/shellcheck v0.11.0](https://github.com/koalaman/shellcheck)** — Portability rules (SC2xxx), zsh support via `--shell=zsh`, 39.5k stars
- **[GitHub: mvdan/sh v3.13.1](https://github.com/mvdan/sh)** — zsh parser support in shfmt, Go library for shell AST
- **[GNU Stow manual](https://www.gnu.org/software/stow/manual/)** — `chkstow -b` for broken symlinks, `--restow` idempotency
- **[timkicker/dotfiles SECURITY.md](https://github.com/timkicker/dotfiles/security)** — Comprehensive dotfiles security guide: pre-push checklist, gitleaks integration, common leak patterns, history scrubbing procedures, .gitignore patterns for secrets
- **[Tech Champion: Write Cross-Platform Shell](https://tech-champion.com/linux/write-cross-platform-shell-linux-vs-macos-differences-that-break-production/)** — Authoritative GNU vs BSD differences: sed, grep, find, date, stat, ps, ifconfig/ip, shebang portability, feature detection patterns

### Secondary (MEDIUM confidence)
- **[InstaTunnel Blog: Dotfiles Security Minefield](https://instatunnel.my/blog/why-your-public-dotfiles-are-a-security-minefield)** — Secret separation patterns, pre-commit hooks, gitleaks integration, git-filter-repo workflows
- **[GitHub Docs: Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)** — Official git-filter-repo workflow for credential removal
- **[dotfiles.github.io](https://dotfiles.github.io/)** — Community dotfiles conventions and best practices
- **Previous research in `.planning/research/PITFALLS.md` (v1.2)** — Courtsite cleanup pitfalls, cross-platform guard patterns, stow symlink management

### Tertiary (LOW confidence)
- **Websearch: "dotfiles sanitization checklist 2026"** — General patterns observed across personal dotfiles repos (gitleaks adoption, .gitignore conventions, .local file patterns)

---

*Research completed: 2026-05-26*
*Ready for roadmap: yes*
