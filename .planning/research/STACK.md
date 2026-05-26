# Stack Research

**Domain:** Dotfile audit, sanitization, cross-platform hardening (secrets, company refs, portability, stale config, idempotency, public-safe structure)
**Researched:** 2026-05-26
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Gitleaks | v8.30.1+ | Secrets and credential scanning | Single Go binary, zero runtime deps, pre-commit hook, `.gitleaks.toml` config file, 170+ built-in detection rules, MIT license. Maintainer announced feature-complete (security patches only) — stable target, no churn. |
| ShellCheck | v0.11.0 | Shell portability and quality linting | Already in the project (v0.8.0 installed). v0.11.0 (Aug 2025) adds improved zsh support, expands SC2xxx portability rules that catch Linux/macOS incompatibilities. Can target specific shells with `--shell=zsh`. 39.5k stars, GPLv3. |
| shfmt | v3.13.1+ | Shell formatting and syntax validation | Already in Makefile (go-installed). v3.13.1 (Apr 2026) with full zsh parser support. Used by `make format` to normalize shell scripts. Catches syntax errors that indicate stale/broken config. 8.8k stars, BSD-3. |
| ripgrep (rg) | 14.x+ | Pattern-based content scanning | Already in project (v13.0.0 installed — upgrade to 14.x for `--field-match-separator` flag). Powers company reference detection, stale alias/function hunting, private data pattern matching. Foundation tool for 4 of 6 audit categories. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| GNU Stow | 2.x+ | Symlink idempotency | Already used. `stow --restow` is naturally idempotent — won't clobber existing files, only manages symlinks. `chkstow -b` finds broken symlinks (stale config indicator). |
| jq | 1.7+ | JSON validation and extraction | Already in Makefile. Use for validating JSON config files, extracting structured data from Gitleaks reports. |
| sh (mvdan.cc/sh) | v3.13+ | Shell AST parsing (Go library) | Powers shfmt. Could be leveraged programmatically if custom dead-code detection is ever built, but direct Go programming not needed for this audit. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Gitleaks | Pre-commit and pre-push secret blocking | Add to `.githooks/pre-commit` alongside existing Courtsite guard. Run `gitleaks detect --no-git -v` for filesystem scan, `gitleaks git -v` for history scan. |
| ShellCheck `--shell=zsh` | zsh-specific portability checking | SC2034 (unused variables = stale config), SC2154 (undefined variables), SC2249/SC2250 (bash-specific constructs in sh scripts). |
| rg + patterns file | Company reference detection | Existing pattern in Makefile (`-g` exclusions). Enhance with `.patterns/company-patterns.txt` for configurable term lists. |
| rg + grep -c | Stale alias/function detection | Compare defined aliases in `.zshrc` against actual usage: `rg "alias (\w+)" zsh/.zshrc` vs `rg "\1" .` to find unreferenced shortcuts. |
| zsh -n | zsh syntax health check | Already in `make test`. Catches broken config before it becomes stale. Run against ALL zsh files (`.zshrc`, `.p10k.zsh`, `.zshrc.local` if present). |
| make + .gitignore audit | Public-safe structure check | Audit `.gitignore` for completeness. Ensure private state files, tokens, and machine-specific configs are excluded. Check for hardcoded usernames with `rg "/home/\w+"` patterns. |

## Domain-to-Tool Mapping

| Audit Domain | Primary Tool | Fallback/Supplementary | Confidence |
|-------------|-------------|----------------------|------------|
| (1) Secrets/credentials | Gitleaks v8.30.1 | rg + custom `.gitleaks.toml` rules | HIGH |
| (2) Company references | rg + `.patterns/` file | Existing Makefile `courtsite-guard` | HIGH |
| (3) macOS/Linux portability | ShellCheck v0.11.0 | `zsh -n` syntax, Makefile `ensure_tool` macro | HIGH |
| (4) Stale/dead config | rg + shellcheck SC2034 | `chkstow -b`, manual audit of commented blocks | MEDIUM |
| (5) Idempotency | GNU Stow built-in | Manual `install.sh` review, `make clean && make bootstrap` test | MEDIUM |
| (6) Public-safe structure | `.gitignore` audit + rg patterns | Manual review of file permissions, hardcoded paths | MEDIUM |

## Installation

```bash
# Core audit tools (cross-platform via apt/brew)

# Gitleaks — secrets scanning (NEW for v1.3)
brew install gitleaks                          # macOS
# Linux binary:
# curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/scripts/install.sh | sh

# ShellCheck upgrade (existing, upgrade from 0.8.0 → 0.11.0)
brew upgrade shellcheck                        # macOS
sudo apt install shellcheck                    # Ubuntu (may need backports for 0.11.0)
# Or binary: https://github.com/koalaman/shellcheck/releases

# shfmt upgrade (existing via go, to v3.13.1)
go install mvdan.cc/sh/v3/cmd/shfmt@v3.13.1

# ripgrep upgrade (existing, from 13.0.0 → 14.x)
brew upgrade ripgrep                           # macOS
sudo apt install ripgrep                       # Ubuntu (check version)
```

## Gitleaks Configuration

Create `.gitleaks.toml` at repo root — integrates with existing pre-commit hook:

```toml
# .gitleaks.toml — secrets detection for dotfiles audit
title = "Dotfiles Gitleaks Config"

[extend]
useDefault = true

# Additional custom rules for dotfile-specific patterns
[[rules]]
id = "ssh-private-key-in-config"
description = "SSH private keys accidentally placed in config files"
regex = '''-----BEGIN (?:RSA|OPENSSH|DSA|EC|PGP) PRIVATE KEY-----'''
tags = ["ssh", "key"]

[[rules]]
id = "home-directory-path"
description = "Hardcoded home directory with username (privacy leak)"
regex = '''/home/(?!\$\{?)[a-zA-Z][a-zA-Z0-9_-]*/'''
tags = ["privacy", "path"]

[[rules]]
id = "internal-url"
description = "Internal/company URLs that should not be public"
regex = '''https?://(?:[a-zA-Z0-9-]+\.)?(?:internal|corp|staging|dev)\.'''
tags = ["url", "internal"]

# Ignore test/planning files and existing known false positives
[[allowlists]]
description = "Ignore planning docs and test data"
paths = [
  '''.planning/.*''',
  '''Makefile''',
  '''\.githooks/.*''',
]
```

## Alternatives Considered

| Recommended | Alternative | Why Not |
|-------------|-------------|---------|
| **Gitleaks** (MIT) | TruffleHog (AGPL) | TruffleHog is AGPL (restrictive for personal repos), requires network for `--results=verified`, massive binary with 800+ detectors. Overkill for dotfiles. |
| **Gitleaks** | ggshield (MIT) | Requires GitGuardian API key and account. Cloud dependency inappropriate for local-only dotfiles audit. |
| **Gitleaks** | detect-secrets (Apache 2.0) | Python runtime required (`pip install`). Slower than Go binary. v1.5.0 (May 2024) — less actively maintained. 4.5k vs 27.3k stars. |
| **ShellCheck** | checkbashisms (GPL) | Perl script from Debian devscripts. Only checks POSIX compatibility, no zsh support. ShellCheck covers portability (SC2xxx) + quality + security + zsh. |
| **ShellCheck SC2034** | Dedicated dead-code tool | No existing tool specifically for dotfile stale config detection. ShellCheck's unused variable detection catches the most common case. |
| **rg + patterns** | Custom Python/Node script | Adding a runtime dependency (Python/Node) for something rg handles out of the box is unnecessary complexity. |
| **GNU Stow** | chezmoi | chezmoi has templating + encryption, but switching symlink managers mid-project is high risk. Stow already handles idempotency. |

## What NOT to Add

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| **TruffleHog** | AGPL license, requires Go runtime or Docker, 800+ detectors is noise for dotfiles. Network verification (`--results=verified`) calls external APIs. | Gitleaks — single binary, MIT, offline-capable, configurable rules. |
| **ggshield** | Requires GitGuardian cloud account and API key. Adds external service dependency for what should be a local audit. | Gitleaks — fully offline, no account needed. |
| **detect-secrets** | Requires Python 3.x runtime. Baseline management adds complexity. Yelp maintains it but slower release cadence (last release May 2024). | Gitleaks — Go binary, no runtime deps, active community. |
| **checkbashisms** | Perl script, only POSIX/sh checking. Doesn't understand zsh or bash-specific portability concerns. ShellCheck unified coverage. | ShellCheck `--shell=zsh` — catches zsh portability, POSIX issues, and quality checks in one tool. |
| **git-filter-repo** | Already deferred (GIT-01 in PROJECT.md). Only needed if repo goes public with leaked history. Not needed for audit phase. | Deferred — address only when public push is imminent. |
| **repgrep (rgr)** | Interactive TUI for find-replace. Overkill for audit (finding only, not replacing). | rg directly — faster, scriptable, already in Makefile. |
| **Custom Python/Node audit script** | Adds language runtime dependency. Breaks the zero-dependency audit pattern (rg + shellcheck + gitleaks are all single binaries). | Compose existing single-binary tools via Makefile targets. |
| **Docker-based scanning** | Pulls large images, requires Docker daemon. Adds complexity for something that should run in <1s locally. | Native binary installs via brew/apt — faster startup, lower overhead. |

## Stack Patterns by Audit Domain

**If scanning for secrets (pre-commit):**
- Use `gitleaks git --pre-commit` in `.githooks/pre-commit`
- Configure `.gitleaks.toml` with custom rules for SSH keys, home paths, internal URLs
- Add `.gitleaksignore` for known false positives (test data, example configs)

**If checking cross-platform portability:**
- Use `shellcheck --shell=zsh --severity=warning $(find . -name "*.sh" -o -name "*.zsh")`
- Pay attention to SC2xxx rules (portability): SC2039 (non-POSIX), SC2249/SC2250 (bashisms)
- For zsh-specific: `zsh -n` catches syntax errors that shellcheck doesn't

**If hunting stale config:**
- Use `rg "alias (\w+)=" zsh/.zshrc -or '$1'` to extract aliases, then grep for usage
- Use `shellcheck -x zsh/.zshrc` to find unused variables (SC2034)
- Use `chkstow -b` to find broken symlinks pointing to deleted configs
- Manual review: commented-out blocks > 6 months old = candidate for removal

**If verifying idempotency:**
- Stow is naturally idempotent: `stow -R` restows without clobbering
- `install.sh` must check for existing installations before acting
- Test: `make clean && make bootstrap && make bootstrap` (second run must succeed with "already installed" messages)

**If checking public safety:**
- Audit `.gitignore` for completeness (`.env`, `.zshrc.local`, `*.pem`, tokens)
- Search for hardcoded usernames: `rg "/home/(?!\$\{?)\w+/" .`
- Search for email addresses: `rg "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" .` (exclude planning docs)
- Verify no `.git` directory leak: `rg "\.git/"` shouldn't find tracked git internals

## Version Compatibility

| Tool | Current Version | Target Version | Platform Support | Notes |
|------|----------------|----------------|------------------|-------|
| shellcheck | 0.8.0 | 0.11.0 | Linux (apt/brew), macOS (brew) | Upgrade needed for zsh SC2xxx improvements |
| rg (ripgrep) | 13.0.0 | 14.x+ | Linux, macOS, Windows | Works fine at 13.0.0 — upgrade optional |
| shfmt | go-installed | v3.13.1 | Go 1.25+ required | Already via `ensure_tool` in Makefile |
| gitleaks | NOT INSTALLED | v8.30.1 | Linux, macOS (brew/binary) | New addition for v1.3 |
| jq | installed | 1.7+ | Linux, macOS | Already in Makefile |

## Sources

- [GitHub: gitleaks/gitleaks v8.30.1](https://github.com/gitleaks/gitleaks) — README, config format, pre-commit hook integration, feature-complete announcement (HIGH confidence)
- [GitHub: trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog) — Detector count (800+), verification feature, AGPL license (HIGH confidence)
- [GitHub: Yelp/detect-secrets v1.5.0](https://github.com/Yelp/detect-secrets) — Plugin system, baseline approach, Python runtime requirement (HIGH confidence)
- [GitHub: GitGuardian/ggshield v1.50.4](https://github.com/GitGuardian/ggshield) — API key requirement, cloud dependency, 500+ detectors (HIGH confidence)
- [GitHub: koalaman/shellcheck v0.11.0](https://github.com/koalaman/shellcheck) — Portability checks (SC2xxx), zsh support via `--shell=zsh`, 39.5k stars (HIGH confidence)
- [GitHub: mvdan/sh v3.13.1](https://github.com/mvdan/sh) — zsh parser support in shfmt, Go library for shell AST (HIGH confidence)
- [GNU Stow manual](https://www.gnu.org/software/stow/manual/) — `chkstow -b` for broken symlinks, `--restow` idempotency (HIGH confidence)
- Existing codebase: `.planning/codebase/STACK.md`, `Makefile`, `.githooks/pre-commit` — current tool inventory and integration points (HIGH confidence)

---

*Stack research for: Dotfiles v1.3 Final Audit & Sanitization before Laptop Reset*
*Researched: 2026-05-26*
