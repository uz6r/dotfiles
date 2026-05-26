# Phase 9: Comprehensive Audit & Sanitization - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-26
**Phase:** 09-comprehensive-audit-sanitization
**Areas discussed:** Secret scanning scope

---

## Secret Scanning Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Standard security patterns | .env*, *.pem, *.key, *.pfx, credentials/, .aws/, private/, *.nmconnection | |
| Standard + tokens in config | Above plus API tokens, access keys, bearer tokens in shell configs | |
| Comprehensive | All of the above + base64-encoded secrets, hex-encoded keys, credential patterns in shell history | ✓ |

**User's choice:** Comprehensive
**Notes:** User wants full coverage — not just standard patterns but also encoded secrets and credential patterns in shell history files.

---

## OpenCode's Discretion

- Pre-commit enforcement behavior (warn vs block)
- Documentation depth for WORKFLOW.md and PRE-RESET-CHECKLIST.md
- Make target naming conventions
- Binary detection policy beyond lazygit

## Deferred Ideas

None
