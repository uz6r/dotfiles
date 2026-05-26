# Phase 9: Comprehensive Audit & Sanitization - Context

**Gathered:** 2026-05-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Final audit and sanitization of dotfiles before laptop reset. Eliminate all sensitive traces, harden macOS compatibility, preserve portable workflows, and establish public/private boundaries. All 28 requirements across sanitization, macOS compatibility, maintainability, workflow preservation, and public-safe review are in scope as a single consolidated effort.

</domain>

<decisions>
## Implementation Decisions

### Secret Scanning Scope
- **D-16:** Comprehensive coverage — standard security patterns (.env*, *.pem, *.key, *.pfx, credentials/, .aws/, private/, *.nmconnection) PLUS API tokens, access keys, bearer tokens in shell configs PLUS base64-encoded secrets, hex-encoded keys, and credential patterns in shell history files

### OpenCode's Discretion
- Pre-commit enforcement behavior (warn vs block on secrets)
- Documentation depth for WORKFLOW.md and PRE-RESET-CHECKLIST.md
- Make target naming conventions (namespaced vs flat)
- Binary detection policy beyond lazygit

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase Definition
- `.planning/ROADMAP.md` §Phase 9 — Goal, success criteria, requirement list
- `.planning/REQUIREMENTS.md` — Full 28 requirement specs (SANI-01–08, MACO-01–06, MAIN-01–05, WORK-01–03, PUBS-01–04)

### Prior Decisions
- `.planning/STATE.md` — D-11 through D-15, A-01 through A-04, all v1.3 locked decisions

### Code Context
- `.planning/codebase/STRUCTURE.md` — Directory layout, stow packages, key files
- `.planning/codebase/CONVENTIONS.md` — Code style, error handling patterns
- `.planning/codebase/CONCERNS.md` — Known issues, security concerns, fragile areas

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `bin/audit-nvim-plugins` — Existing audit script pattern (dual-mode compatible)
- `bin/profile-zsh` — Existing profiling script
- `.githooks/pre-commit` — Existing pre-commit hook (lint + courtsite blocker)
- `Makefile` — Existing targets (test, status, lint, format, courtsite-guard, verify-cleanup)

### Established Patterns
- Script naming: lowercase, hyphenated in `bin/`
- Make targets: short descriptive names (flat, not namespaced)
- Pre-commit: bash script, exits non-zero to block
- Audit: dual-mode REPORT/STRICT (D-14)

### Integration Points
- Pre-commit hook — extend with secret scanning + binary detection
- Makefile — add new targets (audit, sanitize, verify, doctor, macos-check, public-ready, audit-home)
- `bin/` — add new scripts (audit-secrets, audit-workflow, verify-macos)
- `.gitignore` — expand with security patterns
- `.gitleaks.toml` — new file for gitleaks config

</code_context>

<specifics>
## Specific Ideas

No specific requirements beyond those captured in REQUIREMENTS.md and STATE.md — standard approaches appropriate for dotfiles sanitization.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 09-comprehensive-audit-sanitization*
*Context gathered: 2026-05-26*
