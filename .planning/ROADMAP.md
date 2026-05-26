# Roadmap: Dotfiles

## Milestones

- ✅ **v1.0** — Cross-Platform Compatibility — Phases 1-2 (shipped 2026-04-13)
- ✅ **v1.1** — Shell Optimization — Phases 3-5 (shipped 2026-04-14)
- ✅ **v1.2** — Cleanup & Decoupling — Phases 6-8 (shipped 2026-05-26)
- 🔲 **v1.3** — Final Audit & Sanitization before Laptop Reset — Phase 9

## Completed

<details>
<summary>✅ v1.2 Cleanup & Decoupling (Phases 6-8) — SHIPPED 2026-05-26</summary>

- [x] Phase 6: Clean Shell Configuration (2/2 plans) — completed 2026-04-30
- [x] Phase 7: Remove Company Scripts (1/1 plan) — completed 2026-05-26
- [x] Phase 8: Verify & Update Documentation (2/2 plans) — completed 2026-05-26

See `milestones/v1.2-ROADMAP.md` for full details.

</details>

<details>
<summary>✅ v1.1 Shell Optimization (Phases 3-5) — SHIPPED 2026-04-14</summary>

See `milestones/v1.1-ROADMAP.md` for full details.

</details>

<details>
<summary>✅ v1.0 Cross-Platform Compatibility (Phases 1-2) — SHIPPED 2026-04-13</summary>

Phase details archived.

</details>

---

## Phases

- [ ] **Phase 9: Comprehensive Audit & Sanitization** (3 plans) — Eliminate all sensitive traces, harden macOS compatibility, preserve portable workflows, and establish public/private boundaries before machine wipe

## Phase Details

### Phase 9: Comprehensive Audit & Sanitization
**Goal**: Repo is audited, sanitized, macOS-compatible, and ready for machine wipe — all sensitive traces eliminated, portable workflows preserved, and public/private boundaries established. The audit, sanitization, compatibility review, portability validation, and migration preparation are executed together as a single consolidated effort while access to the current machine and environment still exists.

**Depends on**: Phase 8 (v1.2 — repo is clean of Courtsite references, guard infrastructure is in place)

**Requirements**:
SANI-01, SANI-02, SANI-03, SANI-04, SANI-05, SANI-06, SANI-07, SANI-08,
MACO-01, MACO-02, MACO-03, MACO-04, MACO-05, MACO-06,
MAIN-01, MAIN-02, MAIN-03, MAIN-04, MAIN-05,
WORK-01, WORK-02, WORK-03,
PUBS-01, PUBS-02, PUBS-03, PUBS-04

**Success Criteria** (what must be TRUE):

1. **`make sanitize` exits 0 with zero findings** — no secrets, no binaries, no hardcoded paths, no sensitive tracked files in the repo; gitleaks passes clean; pre-commit hook blocks secrets and binaries from being staged

2. **`make macos-check` reports zero Linux-only incompatibilities across all tracked scripts and configs** — `duh` alias works on both platforms, `readlink -f` has greadlink fallback, `grep` and `date` calls are portable, platform guards are in place for all flag differences

3. **`make doctor` passes comprehensively** — aggregates test + sanitize + compat + gitignore audit + stale config check into a single clean report; install.sh runs idempotently; CONCERNS.md reflects current state; `.zshrc.local.example` template exists for new machine setup

4. **`bin/audit-workflow` generates WORKFLOW.md from shell history with anonymized paths** — top commands, custom functions, and aliases preserved; no raw secrets, hostnames, or internal paths leaked in the output

5. **PRE-RESET-CHECKLIST.md is actionable and `make audit-home` scans home directory for sensitive data outside the repo** — `private/` directory exists as explicit public/private boundary; `make public-ready` aggregates all pre-public checks; user knows exactly what to back up and what to securely delete before machine wipe

**Plans**: 3 plans

Plans:
- [x] 09-01-PLAN.md — Security Triage & Git Hygiene (remove secrets, fix paths, gitleaks, private/)
- [x] 09-02-PLAN.md — Audit Tooling, Enforcement & macOS Compatibility (audit scripts, pre-commit, compat fixes)
- [x] 09-03-PLAN.md — Workflow Preservation & Final Documentation (WORKFLOW.md, PRE-RESET-CHECKLIST, make targets)

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 9. Comprehensive Audit & Sanitization | 0/3 | Ready to execute | — |

---

## Deferred to Future Milestones

| Requirement | Reason |
|-------------|--------|
| GIT-01 | Repo is private; only needed if repo goes public (requires git-filter-repo, force push) |

---

*Last updated: 2026-05-26 — Phase 9 defined for v1.3 milestone*
