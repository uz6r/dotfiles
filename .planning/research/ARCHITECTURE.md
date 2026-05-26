# Architecture Research: Audit, Sanitization & Compatibility Verification Integration

**Domain:** Dotfiles — integrating audit, sanitization, and cross-platform verification into GNU Stow + Makefile repo
**Researched:** 2026-05-26
**Confidence:** HIGH

## Standard Architecture

### System Overview (v1.3 Target State)

```
┌──────────────────────────────────────────────────────────────────────┐
│                       Dotfiles Repository                            │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                    Verification Layer (NEW)                      │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐                │  │
│  │  │  audit/    │  │ sanitize/  │  │verify-compat│               │  │
│  │  │(inspection)│  │(enforcement)│  │(cross-plat)│               │  │
│  │  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘                │  │
│  │        │               │               │                       │  │
│  └────────┼───────────────┼───────────────┼───────────────────────┘  │
│           │               │               │                         │
│  ┌────────┴───────────────┴───────────────┴───────────────────────┐  │
│  │                     Guard Layer (EXTENDED)                       │  │
│  │  ┌──────────┐  ┌────────────┐  ┌──────────────────────────┐    │  │
│  │  │pre-commit│  │  CI (.github│  │Makefile verify (NEW)     │    │  │
│  │  │(EXTENDED)│  │/workflows)  │  │courtsite + audit +      │    │  │
│  │  │+ secrets │  │  + verify   │  │sanitize + compat + test │    │  │
│  │  │+ binaries│  │             │  │                          │    │  │
│  │  └──────────┘  └────────────┘  └──────────────────────────┘    │  │
│  └────────────────────────────────────────────────────────────────┘  │
│           │                                                         │
│  ┌────────┴─────────────────────────────────────────────────────┐    │
│  │                     Existing Dotfiles                          │    │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐  │    │
│  │  │ zsh/ │ │ git/ │ │nvim/ │ │tmux/ │ │ bin/ │ │ private/ │  │    │
│  │  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ │ (NEW)    │  │    │
│  │     │        │        │        │        │     │ gitignored│  │    │
│  │     └────────┴────────┴────────┴────────┴─────┘ └──────────┘  │    │
│  │                        │                                       │    │
│  │              GNU Stow Symlinks → $HOME                         │    │
│  │     ~/.zshrc, ~/.gitconfig, ~/.config/nvim, ~/bin/*            │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                        │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                Build Orchestration (Makefile)                    │    │
│  │                                                                  │    │
│  │  make verify ─── SUPER-META (comprehensive gate)                 │    │
│  │     ├── make test      (existing: syntax + courtsite + cleanup)  │    │
│  │     ├── make audit     (NEW meta: all audit-* targets)           │    │
│  │     ├── make sanitize  (NEW meta: secrets + binaries + paths)    │    │
│  │     └── make verify-compat (NEW: macOS portability check)       │    │
│  │                                                                  │    │
│  │  make test ─── EXISTING (unchanged scope)                        │    │
│  │     ├── zsh syntax check                                         │    │
│  │     ├── git config validation                                    │    │
│  │     ├── nvim config validation                                   │    │
│  │     ├── courtsite-guard (existing, no exclusions tightening)     │    │
│  │     └── verify-cleanup  (existing, full-repo scan)               │    │
│  │                                                                  │    │
│  │  make audit ─── NEW meta (report findings, non-blocking)        │    │
│  │     ├── audit-secrets    (scan for keys/tokens/passwords)        │    │
│  │     ├── audit-binaries   (find large binary files in repo)       │    │
│  │     ├── audit-stale      (find stale configs, empty dirs)        │    │
│  │     └── audit-hardcoded  (find hardcoded paths/IPs/personal)     │    │
│  │                                                                  │    │
│  │  make sanitize ─── NEW meta (zero-tolerance, exit 1 on finding)  │    │
│  │     ├── audit-secrets    (same script, strict mode via flag)     │    │
│  │     ├── audit-binaries   (same script, strict mode)              │    │
│  │     └── audit-hardcoded  (same script, strict mode)              │    │
│  └────────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Existing or New | Implementation |
|-----------|----------------|-----------------|----------------|
| `bin/audit-secrets` | Scan tracked files for API keys, tokens, passwords, credentials | NEW | Shell script using `rg` regex patterns |
| `bin/audit-binaries` | Find binary/large files committed to repo | NEW | Shell script checking file types via `file` command |
| `bin/audit-stale` | Find stale configs, empty dirs, dead references | NEW | Shell script cross-referencing Makefile packages vs stow dirs |
| `bin/audit-hardcoded` | Find hardcoded paths, IPs, personal data | NEW | Shell script using `rg` path/ip/pii patterns |
| `bin/verify-macos` | Check for Linux-only assumptions in scripts/configs | NEW | Shell script analyzing for unguarded platform-specific calls |
| `bin/profile-zsh` | Shell startup profiling (~950ms measurement) | EXISTING | Bash/zsh script with timing measurement |
| `bin/audit-nvim-plugins` | Neovim plugin usage analysis (23 plugins) | EXISTING | Bash script extracting lazy.nvim plugin list |
| `Makefile` (audit targets) | Orchestrate audit scripts with consistent interface | NEW (added) | Make targets delegating to bin/ scripts |
| `Makefile` (sanitize targets) | Orchestrate zero-tolerance checks | NEW (added) | Make targets with strict exit codes |
| `Makefile` (verify target) | Comprehensive pre-commit/CI gate | NEW (added) | Meta-target chaining audit + sanitize + compat + test |
| `Makefile` (test target) | Dotfiles validation (unchanged scope) | EXISTING | zsh syntax, git config, nvim config, courtsite, cleanup |
| `.githooks/pre-commit` | Block commits with secrets, binaries, Courtsite refs | EXTENDED | Add secret/binary checks before existing format check |
| `.github/workflows/ci.yml` | CI validation pipeline | EXTENDED | Add `make verify` job after format check |
| `.gitignore` | Exclude private files from tracking | EXTENDED | Add patterns for secrets, binaries, network configs |
| `private/` dir | Explicit public-vs-private boundary | NEW | Gitignored directory for local-only state |

## Recommended Project Structure (v1.3)

```
dotfiles/
├── zsh/                          # Zsh configuration (stow package)
│   ├── .zshrc                    # Main shell config (clean, platform guards)
│   └── .p10k.zsh                 # Powerlevel10k theme
├── git/                          # Git configuration (stow package)
│   ├── .gitconfig                # Global git config
│   └── .gitignore_global         # Global gitignore
├── nvim/                         # Neovim config (stow package)
│   └── .config/nvim/
│       ├── init.lua              # Main neovim config
│       └── lua/                  # Lua modules
├── tmux/                         # Tmux config (stow package)
│   └── .tmux.conf
├── bin/                          # Portable utility scripts (stow package)
│   ├── profile-zsh               # [EXISTING] Shell profiling tool
│   ├── audit-nvim-plugins        # [EXISTING] Neovim plugin auditor
│   ├── audit-secrets             # [NEW] Secret/key/token scanner
│   ├── audit-binaries            # [NEW] Binary file detector
│   ├── audit-stale               # [NEW] Stale config/symlink finder
│   ├── audit-hardcoded           # [NEW] Hardcoded path/IP/PII scanner
│   └── verify-macos              # [NEW] macOS compatibility checker
├── private/                      # [NEW] Gitignored private state
│   ├── .zshrc.local              # [EXISTING but should live here?]
│   └── README.md                 # [NEW] Documentation of private/ convention
├── Makefile                      # Task runner (install, test, lint, audit, verify)
├── install.sh                    # Bootstrap script
├── .githooks/
│   └── pre-commit                # [EXTENDED] +secrets +binaries +courtsite
├── .github/
│   └── workflows/
│       └── ci.yml                # [EXTENDED] +verify job
├── .gitignore                    # [EXTENDED] +secrets +binaries +network configs
└── README.md                     # Repository documentation
```

### Structure Rationale

- **`bin/` gets 5 new scripts:** All audit/verify tools follow the existing pattern of portable shell scripts. They're stow-linked to `~/bin/` so they're available in PATH. Each has a single responsibility (audit, scan, verify). This keeps the Makefile thin (just orchestration) and the scripts independently testable.

- **`private/` directory:** Explicit boundary between public-tracked and private-local state. Gitignored entirely. Contains `.zshrc.local` and anything else machine-specific. This directory serves as documentation: everything inside is private, everything outside is public-safe.

- **No new top-level directories for scripts:** The `scripts/` directory currently exists but is empty. Rather than grow it, the `bin/` convention already works — audit tools are runtime utilities, not bootstrap helpers. The empty `scripts/` directory should be removed during audit cleanup.

- **Makefile grows by ~60 lines:** New targets integrate into the existing structure without restructuring. `make test` scope is preserved. `make verify` is the new comprehensive gate. `make audit` is the new "report findings" workflow. `make sanitize` is the "enforce zero tolerance" workflow.

## Architectural Patterns

### Pattern 1: Audit vs Sanitize — Two Modes, Same Tool

**What:** Each `bin/audit-*` script supports two modes: REPORT (non-zero findings printed but exit 0) and STRICT (exit 1 on any finding). The Makefile `audit-*` targets use REPORT mode. The `sanitize` meta-target invokes the same scripts in STRICT mode.

**When to use:** When you want the same detection logic for both "show me what's wrong" (developer workflow) and "block the door" (pre-commit/CI gate).

**Trade-offs:**
- ✅ Single source of truth for detection patterns
- ✅ No drift between "nice to know" and "must fix" definitions
- ✅ Developers can run `make audit` to see everything before `make sanitize` blocks it
- ⚠️ Scripts need a `--strict` flag or `AUDIT_MODE` env var convention

**Example:**
```bash
#!/usr/bin/env bash
# bin/audit-secrets — Scan for API keys, tokens, credentials
# Usage:
#   ./audit-secrets          # REPORT mode: print findings, exit 0
#   ./audit-secrets --strict  # STRICT mode: print findings, exit 1 if any found
#   STRICT=1 ./audit-secrets  # Alternative: env var

set -euo pipefail
STRICT="${STRICT:-0}"
[[ "${1:-}" == "--strict" ]] && STRICT=1

# Patterns for common secret formats (heuristic, not exhaustive)
PATTERNS=(
    'sk-[a-zA-Z0-9]{20,}'              # Stripe/OpenAI keys
    'ghp_[a-zA-Z0-9]{36,}'             # GitHub personal access tokens
    'AKIA[0-9A-Z]{16}'                 # AWS access key IDs
    '[a-zA-Z0-9+/]{30,}={0,2}'         # Base64-ish (low specificity, broad catch)
    'api[_-]?key[:=].{8,}'             # Generic API key assignments
    'password[:=].{1,}'                # Password assignments in configs
    'psk=.*'                           # WiFi pre-shared keys (NetworkManager)
)

FOUND=0
for pattern in "${PATTERNS[@]}"; do
    matches=$(rg --no-heading -n "$pattern" \
        --hidden \
        -g '!.git' \
        -g '!.planning' \
        -g '!private/' \
        -g '!*.md' \
        . || true)
    if [[ -n "$matches" ]]; then
        echo "⚠️  Potential secret found (pattern: $pattern):"
        echo "$matches"
        echo ""
        FOUND=1
    fi
done

if [[ $FOUND -eq 0 ]]; then
    echo "✅ No potential secrets detected"
    exit 0
fi

if [[ $STRICT -eq 1 ]]; then
    echo "❌ Secret scan FAILED ($FOUND potential issues)"
    exit 1
else
    echo "⚠️  Audit found $FOUND potential issues (non-blocking)"
    exit 0
fi
```

### Pattern 2: Makefile Meta-Targets with Consistent Exit Semantics

**What:** Meta-targets chain sub-targets with clear exit code semantics. REPORT targets (audit-*) use `|| true`. STRICT targets (sanitize-*) use `|| exit 1`. The super-meta `verify` target fails fast on any sub-target failure.

**When to use:** When you have multiple independent checks that share tooling but differ in severity.

**Example (Makefile additions):**
```makefile
# ── audit (REPORT mode: run all, show all, don't block) ──
AUDIT_FLAGS =

audit-secrets: ## scan for API keys, tokens, and credentials
	@echo "→ Scanning for secrets..."
	@$(AUDIT_FLAGS) bin/audit-secrets || true

audit-binaries: ## find binary/large files in repo
	@echo "→ Checking for binary files..."
	@$(AUDIT_FLAGS) bin/audit-binaries || true

audit-stale: ## find stale configs, empty dirs, dead references
	@echo "→ Checking for stale configuration..."
	@$(AUDIT_FLAGS) bin/audit-stale || true

audit-hardcoded: ## find hardcoded paths, IPs, personal data
	@echo "→ Scanning for hardcoded data..."
	@$(AUDIT_FLAGS) bin/audit-hardcoded || true

audit: audit-secrets audit-binaries audit-stale audit-hardcoded ## run all audit checks (report mode)
	@echo "✅ audit complete"

# ── sanitize (STRICT mode: block on any finding) ──

sanitize: ## run all sanitization checks (zero tolerance)
	@echo "=== Running Sanitization (STRICT mode) ==="
	@echo ""
	@STRICT=1 $(MAKE) audit
	@echo ""
	@echo "=== Sanitization passed ==="

# ── verify-compat (cross-platform advisory) ──

verify-compat: ## check macOS compatibility
	@echo "→ Checking macOS compatibility..."
	@bin/verify-macos || echo "  ⚠️  macOS compatibility check found issues (review output above)"

# ── verify (SUPER-META: comprehensive pre-commit/CI gate) ──

verify: test sanitize verify-compat ## comprehensive validation (test + sanitize + compat)
	@echo ""
	@echo "=== Full verification passed ==="
```

### Pattern 3: Pre-commit as Fast Security Gate (Not Slow Audit)

**What:** Pre-commit runs only the fastest, highest-signal checks. Secret scanning (regex-based, fast) and binary detection (file size check, fast) run pre-commit. Full audit and macOS compatibility run in CI.

**When to use:** When pre-commit latency matters (every commit) but certain checks are too slow or too dependent on context.

**Trade-offs:**
- ✅ Fast commits (pre-commit completes in < 2 seconds)
- ✅ Catches the worst issues (secrets, binaries) before they hit the repo
- ✅ Heavier checks still run in CI
- ⚠️ Pre-commit can't catch everything — CI is still the final gate

**Example (.githooks/pre-commit extension):**
```sh
#!/bin/sh
echo "Running pre-commit checks..."

# 1. Secret detection (FAST — regex scan of staged files only)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)
if echo "$STAGED_FILES" | grep -q .; then
    if echo "$STAGED_FILES" | xargs rg -l --no-heading \
        'sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36,}|AKIA[0-9A-Z]{16}|psk=.*' \
        2>/dev/null; then
        echo "❌ Potential secrets found in staged files. Commit blocked."
        exit 1
    fi
fi

# 2. Binary/large file detection
if echo "$STAGED_FILES" | xargs file 2>/dev/null | grep -i 'executable\|ELF\|Mach-O' | grep -v 'shell script' | grep -v 'Makefile'; then
    echo "❌ Binary files detected. Remove or add to .gitignore."
    exit 1
fi

# 3. Courtsite reference detection (existing)
if rg -i "courtsite|sinar|enjin|COURTSITE_DIR" --files-with-matches --hidden -g '!.git' -g '!.planning' -g '!Makefile' -g '!.githooks' . ; then
    echo "❌ Courtsite references found. Commit blocked."
    exit 1
fi

# 4. Format check (existing)
make format > /dev/null 2>&1
if ! git diff --exit-code --quiet; then
    echo "❌ Code was reformatted. Please review and stage the changes."
    exit 1
fi

echo "✅ Pre-commit checks passed"
exit 0
```

## Data Flow

### Audit Workflow (Developer Runs `make audit`)

```
make audit
    ↓
    ├── audit-secrets  → rg scans all tracked files for secret patterns
    │   └── REPORT mode: prints findings, exits 0
    │       (Developer reviews findings, decides what to fix)
    │
    ├── audit-binaries → file + stat check for binary/large files
    │   └── Flags: lazygit (21MB), lazygit.tar.gz (7.9MB), .nmconnection
    │
    ├── audit-stale    → checks for empty dirs, stale symlinks, dead configs
    │   └── Flags: scripts/ (empty dir), stale stow dirs if any
    │
    └── audit-hardcoded → rg scans for hardcoded paths, IPs, personal data
        └── Flags: /home/uzer/ paths, internal URLs, machine-specific values
```

### Sanitize Workflow (Pre-commit/CI Runs `make sanitize`)

```
make sanitize (STRICT=1)
    ↓
    ├── audit-secrets --strict  → EXIT 1 if any secret found
    │   (Blocks commit/CI if keys, tokens, or passwords detected)
    │
    ├── audit-binaries --strict → EXIT 1 if binary files found
    │   (Prevents committing compiled binaries to dotfiles repo)
    │
    └── audit-hardcoded --strict → EXIT 1 if personal data in tracked files
        (Blocks hardcoded home paths, internal IPs, PII)
```

### Verify Workflow (CI Comprehensive Gate)

```
make verify
    ↓
    ├── make test         → zsh syntax, git config, nvim config, courtsite, cleanup
    │   (Must pass: fundamental dotfiles correctness)
    │
    ├── make sanitize     → secrets + binaries + hardcoded (STRICT)
    │   (Must pass: no sensitive data leaks)
    │
    └── verify-compat     → macOS portability check
        (Advisory: prints warnings but doesn't block unless --strict-compat)
```

### Pre-commit Workflow (Per-commit Gate)

```
git commit
    ↓
.githooks/pre-commit
    ├── 1. Secret scan (staged files only, fast regex)
    │   └── FAIL → block commit: "secrets detected"
    │
    ├── 2. Binary file check (staged files only)
    │   └── FAIL → block commit: "binary files detected"
    │
    ├── 3. Courtsite guard (existing, unchanged)
    │   └── FAIL → block commit: "Courtsite references found"
    │
    └── 4. Format check (existing, unchanged)
        └── FAIL → block commit: "unformatted code"
```

## Integration Points

### Makefile Target Dependency Graph

```
verify (NEW super-meta)
├── test (EXISTING, unchanged)
│   ├── zsh syntax check
│   ├── git config validation
│   ├── nvim config validation
│   ├── courtsite-guard (EXISTING)
│   └── verify-cleanup (EXISTING)
├── sanitize (NEW meta, STRICT mode)
│   ├── audit-secrets (NEW script)
│   ├── audit-binaries (NEW script)
│   └── audit-hardcoded (NEW script)
└── verify-compat (NEW)
    └── verify-macos (NEW script)

audit (NEW meta, REPORT mode)
├── audit-secrets (NEW script, non-strict)
├── audit-binaries (NEW script, non-strict)
├── audit-stale (NEW script, non-strict)
└── audit-hardcoded (NEW script, non-strict)

Note: make test scope remains UNCHANGED from v1.2.
      make verify is the new comprehensive gate for CI and pre-push.
```

### CI Pipeline Integration (`.github/workflows/ci.yml`)

| Job | Existing or New | When | Purpose |
|-----|----------------|------|---------|
| `lint-format` | EXISTING | Every push/PR | Format validation (unchanged) |
| `verify` | NEW | Every push/PR | Full audit + sanitize + compat + test |
| Future: `macos-verify` | DEFERRED | Only if macOS runner needed | Actual macOS testing (not just static analysis) |

**Rationale:** The `verify` job runs after `lint-format` (dependency: formatting must pass before deeper checks matter). It can be added as a separate job that depends on `lint-format` succeeding.

### Pre-commit Hook Integration

| Check | Current | v1.3 | Rationale |
|-------|---------|------|-----------|
| Courtsite guard | ✅ Yes | ✅ Yes | Proven effective, keeps working |
| Secret detection | ❌ No | ✅ Yes (NEW) | Catches private keys/tokens before commit |
| Binary file detection | ❌ No | ✅ Yes (NEW) | Prevents 21MB lazygit situations |
| Format check | ✅ Yes | ✅ Yes | Existing behavior preserved |
| Full audit | ❌ No | ❌ No (too slow) | Runs in CI, not pre-commit |

### .gitignore Updates

| Pattern | Reason | Category |
|---------|--------|----------|
| `*.local` | ALREADY EXISTS | Local overrides |
| `.zshrc.local` | ALREADY EXISTS | Per-machine zsh config |
| `.gitconfig.local` | ALREADY EXISTS | Per-machine git config |
| `dotfiles_backup/` | ALREADY EXISTS | Bootstrap backups |
| `*.swp`, `*.swo`, `*.un~` | ALREADY EXISTS | Vim swap files |
| **`*.nmconnection`** | **NEW** | NetworkManager WiFi passwords |
| **`lazygit`** | **NEW** | Binary artifact (21MB committed by mistake) |
| **`lazygit.tar.gz`** | **NEW** | Binary archive (7.9MB committed by mistake) |
| **`.env*`** | **NEW** | Environment files with secrets |
| **`.credentials`** | **NEW** | Credential files |
| **`*.pem`** | **NEW** | Private key files |
| **`*.key`** | **NEW** | Key files |
| **`private/`** | **NEW** | Private data directory |
| **`!private/README.md`** | **NEW** (optional un-ignore) | Documentation of convention |

### Private Directory Structure

```
private/                 # Gitignored entirely
├── README.md            # Documents what belongs here (NOT gitignored if !private/README.md rule added)
├── .zshrc.local         # Per-machine zsh overrides (moved from tracked zsh/)
├── .gitconfig.local     # Per-machine git overrides
├── secrets/             # API keys, tokens (if needed for testing)
└── machine/             # Per-machine notes/setup
```

**Note on `.zshrc.local` location:** Currently `zsh/.zshrc.local` lives in the stow package directory. If it needs to remain in `zsh/` for stow to find it, the `.gitignore` already handles `*.local`. But it should be documented that `private/` is the designated place for truly private state. The existing `.zshrc.local` sourcing in `.zshrc` references `$HOME/.zshrc.local`, not the stow package — so location is decoupled from stow.

## Existing Issues Discovered During Architecture Research

These findings validate the need for the v1.3 milestone and directly inform the audit tooling:

| Issue | Location | Severity | Tool That Catches It |
|-------|----------|----------|---------------------|
| WiFi password in plaintext (`psk=7A33S6282B`) | `ZTE_EC382D.nmconnection` (root) | **CRITICAL** — live credential in git history | `audit-secrets` (psk= pattern) |
| 21MB binary committed | `lazygit` (root) | HIGH — bloats repo, shouldn't be tracked | `audit-binaries` (file type detection) |
| 7.9MB archive committed | `lazygit.tar.gz` (root) | MEDIUM — unnecessary binary artifact | `audit-binaries` (size check) |
| Empty directory with no content | `scripts/` | LOW — dead code, confusion risk | `audit-stale` (empty dir check) |
| Hardcoded home path in script | `bin/audit-nvim-plugins:7` (`/home/uzer/uz6r/dotfiles/...`) | MEDIUM — breaks if repo cloned elsewhere | `audit-hardcoded` (path detection) |

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 1 machine (current) | All checks run locally during `make verify`; pre-commit handles fast checks |
| 2-5 machines | CI is essential — `make verify` in GitHub Actions catches what pre-commit misses; macOS compat checks advisory only |
| Public repo | All strict checks must pass CI; `audit-secrets` becomes critical (public exposure); consider git-filter-repo for history |
| CI unavailable | `make verify` becomes the pre-push gate; document `git push` workflow requiring local verify pass |

### Scaling Priorities

1. **First bottleneck:** Secrets accidentally committed → solved by pre-commit secret scan + CI verify
2. **Second bottleneck:** Binary bloat over time → solved by pre-commit binary check + `audit-stale` periodic cleanup
3. **Third bottleneck:** Cross-platform drift → solved by `verify-macos` in CI (or periodic manual check on macOS)

## Anti-Patterns

### Anti-Pattern 1: Combining Audit with Test

**What people do:** Add audit/security checks to the existing `make test` target, mixing validation (syntax correctness) with inspection (finding issues).

**Why it's wrong:** `make test` should be fast and deterministic — it validates that dotfiles work. Audit checks (like secret scanning) are heuristic and probabilistic. Mixing them makes `make test` unpredictable and slow.

**Do this instead:** Keep `make test` as is (syntax + config validation + courtsite guard). Add `make verify` as the comprehensive gate that chains `test` + `audit` + `sanitize`. Different use cases, different targets.

**Current state (v1.2):** `make test` already includes `courtsite-guard` and `verify-cleanup`. This is correct — they validate a specific invariant ("no Courtsite references"). They stay in `make test`. New heuristic checks go in `make audit`.

### Anti-Pattern 2: Pre-commit Running Full Audit

**What people do:** Run all audit scripts in the pre-commit hook, making every commit take 5-10 seconds.

**Why it's wrong:** Pre-commit latency is cumulative pain. Developers avoid committing, commit less frequently, or disable hooks. The checks become "the boy who cried wolf."

**Do this instead:** Pre-commit runs only the fastest, highest-signal checks (secret scan of staged files, binary file check, courtsite guard). Full audit runs in CI or via `make verify` before push.

### Anti-Pattern 3: One Giant Audit Script

**What people do:** Create a single `bin/audit` script that does everything (secrets + binaries + stale + hardcoded + macOS + ...).

**Why it's wrong:** Single responsibility matters for scripts too — debugging a 500-line audit script is painful. Individual scripts are independently testable, composable via Makefile chaining, and replaceable.

**Do this instead:** One script per audit domain. Makefile targets chain them. `make audit` runs all four. `make audit-secrets` runs just one. This matches the existing pattern: `bin/profile-zsh` and `bin/audit-nvim-plugins` are already separate concerns.

### Anti-Pattern 4: Ignoring Stray Files Because "It's a Private Repo"

**What people do:** Leave credential files, binaries, and network configs in the repo because "nobody else can see it."

**Why it's wrong:** Private repos become public (accidental or intentional). History is forever. The ZTE_EC382D.nmconnection file with a WiFi password demonstrates this: even if the file is deleted, the password remains in git history unless filtered.

**Do this instead:** Treat private repos with the same discipline as public repos. Audit catches everything. `.gitignore` prevents re-addition. Git history cleanup (GIT-01, already deferred) handles what's already in history.

## Migration Path

### Phase Build Order

The architecture supports this build order (informs roadmap phases):

```
Phase A: Audit Infrastructure (foundation)
    └── Create bin/audit-secrets, bin/audit-binaries, bin/audit-stale, bin/audit-hardcoded
    └── Add Makefile audit-secrets, audit-binaries, audit-stale, audit-hardcoded targets
    └── Add Makefile audit meta-target
    └── Dependency: none (scripts are self-contained, no existing tooling to modify)
    └── Deliverable: make audit gives comprehensive report of repo state

Phase B: Sanitization Enforcement (gates)
    └── Add Makefile sanitize target (STRICT mode wrapper)
    └── Extend .githooks/pre-commit with secret + binary detection
    └── Extend .github/workflows/ci.yml with verify job
    └── Dependency: Phase A (scripts must exist before they can be called in strict mode)
    └── Deliverable: pre-commit blocks secrets/binaries; CI fails on sanitization violations

Phase C: Stray File Remediation (action)
    └── Remove ZTE_EC382D.nmconnection (contains WiFi password)
    └── Remove lazygit / lazygit.tar.gz (binary artifacts)
    └── Remove empty scripts/ directory
    └── Fix hardcoded paths in bin/audit-nvim-plugins
    └── Dependency: Phase B (gates prevent re-introduction of removed files)
    └── Deliverable: clean repo, no stray files, no secrets in tracked code

Phase D: Cross-Platform Verification (compatibility)
    └── Create bin/verify-macos
    └── Add Makefile verify-compat target
    └── Add Makefile verify super-meta target
    └── Dependency: Phase C (clean repo before verifying compatibility)
    └── Deliverable: make verify-macos reports Linux-only assumptions

Phase E: Private/Public Separation (boundary)
    └── Create private/ directory with README.md
    └── Update .gitignore with private/ and secret patterns
    └── Move .zshrc.local to private/ (document + relocate)
    └── Dependency: Phase C (clean repo before defining boundaries)
    └── Deliverable: explicit public-vs-private architecture
```

### Dependencies Between Components

```
bin/audit-secrets ─────────────────────┐
bin/audit-binaries ────────────────────┤
bin/audit-stale ───────────────────────┤
bin/audit-hardcoded ───────────────────┤
                                       ├──→ make audit (meta)
                                       ├──→ make sanitize (meta, STRICT)
                                       │        │
                                       │        ├──→ .githooks/pre-commit (extended)
                                       │        └──→ .github/workflows/ci.yml (verify job)
                                       │
bin/verify-macos ──────────────────────┼──→ make verify-compat
                                       │
make test (existing, unchanged) ───────┼──→ make verify (super-meta)
                                       │
.gitignore (extended) ─────────────────┘
private/ (created) ────────────────────┘
```

## Sources

- **Current dotfiles repository state** (2026-05-26) — HIGH confidence, examined all files directly
- **Existing Makefile** — HIGH confidence, analyzed all targets and patterns
- **Existing .githooks/pre-commit** — HIGH confidence, analyzed current hook logic
- **Existing .github/workflows/ci.yml** — HIGH confidence, analyzed CI pipeline
- **Existing .planning/research/ARCHITECTURE.md** (2026-04-30) — HIGH confidence, baseline architecture patterns
- **Existing .planning/RESEARCH.md v1.2** — HIGH confidence, cleanup patterns and pitfall documentation
- **PROJECT.md v1.3 milestone definition** — HIGH confidence, target features for this milestone
- **NetworkManager documentation** (freedesktop.org) — HIGH confidence, .nmconnection format includes psk= field with plaintext passwords
- **GitHub: "Removing sensitive data from a repository"** — HIGH confidence, git-filter-repo workflow for history cleanup
- **Make documentation** (GNU) — HIGH confidence, target chaining and exit code semantics

---

*Architecture research for: v1.3 Final Audit & Sanitization integration into dotfiles repo*
*Researched: 2026-05-26*
*Confidence: HIGH — all findings based on direct repository inspection and official documentation*
