# Feature Research

**Domain:** Dotfiles cleanup & company config removal
**Researched:** 2026-04-30
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features expected when removing company-specific configuration from personal dotfiles. Missing these = incomplete cleanup.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Complete removal of company aliases | Leftover aliases cause confusion and potential path errors | LOW | Currently commented out in .zshrc:315-328, active in .zshrc.local |
| Remove company-specific functions | Functions like `localdev()` reference company paths (COURTSITE_DIR) | LOW | Found at .zshrc:153-184, wrapped in `is_linux` guard |
| Delete company-specific scripts | Scripts `sinar-pi-setup` and `sinar-pi-wifi-setup` are company tools | LOW | Located in bin/, 35KB combined, heavily references Courtsite infrastructure |
| Clean COURTSITE_DIR usage | Environment variable paths hardcoded to ~/Courtsite | LOW | Used in .zshrc and .zshrc.local for path resolution |
| Preserve cross-platform compatibility | Cleanup must not break macOS/Linux detection and paths | MEDIUM | .zshrc has platform detection at lines 36-50, must remain intact |
| Source .zshrc.local pattern | Keep the local override mechanism for machine-specific config | LOW | Already implemented at .zshrc:411-413, should be preserved |
| Update documentation (README) | README references company scripts, needs cleanup | LOW | Lines 97-98 mention sinar-pi-setup and sinar-pi-wifi-setup |

### Differentiators (Best Practices for Cleanup)

Features that set apart a thorough cleanup from a partial one. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Git history cleanup | Remove company references from git history for privacy/security | HIGH | Use `git filter-branch` or `git filter-repo` to purge company paths from history |
| Audit all config files | Check nvim/, tmux/, git/ for any company references | MEDIUM | Current search found references in scripts/update-migration-pr (COURTSITE_DIR usage) |
| Modular .zshrc approach | Split .zshrc into smaller files (.zshrc.d/*.zsh) for maintainability | MEDIUM | Research shows this is best practice (Carmelyne Thompson, 2026) |
| Centralized local config | Move all local/private configs to ~/.config/exports/ or similar | MEDIUM | Separate public dotfiles from private machine-specific config (Prabesh, 2025) |
| Conditional includes for gitconfig | Use `includeIf` for machine-specific git configs | LOW | Git supports conditional includes based on repo path (Evan Moses, 2025) |
| Automated cleanup verification | Script to scan for company references before committing | LOW | Use `grep -r "COURTSITE\|sinar\|Courtsite" ~/` pattern |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good during cleanup but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Keep commented aliases "for reference" | "Might need them later" | Commented code rots, creates confusion about what's active | Delete completely; use git history to recover if needed |
| Leave company scripts in bin/ "just in case" | "They might be useful for others" | Scripts contain company-specific URLs, paths, credentials patterns | Delete from repo; keep a private backup if needed locally |
| Use company paths with conditionals | "Can toggle with if-statement" | Defeats purpose of cleanup; still leaks company info in public repo | Remove completely; use .zshrc.local for any local needs |
| Bulk find-replace company name | "Quick way to remove references" | Can break things; may miss context-specific usages | Manual review of each reference is safer |
| Skip git history cleanup | "Too complex/dangerous" | Company paths remain in public git history indefinitely | Use `git filter-repo` — it's safer than it seems with proper backup |

## Feature Dependencies

```
[Remove company scripts from bin/]
    └──requires──> [Update .zshrc aliases that reference those scripts]
                       └──requires──> [Remove sinar-pi-setup and sinar-pi-wifi-setup aliases]

[Remove localdev() function]
    └──requires──> [Verify no other functions depend on it]
                       └──requires──> [Remove COURTSITE_DIR variable usage]

[Clean .zshrc.local]
    └──enhances──> [Clean .zshrc] (both should be consistent)

[Update README.md]
    └──requires──> [All cleanup in code complete]
```

### Dependency Notes

- **Remove company scripts requires updating .zshrc:** The .zshrc:321-322 aliases point to scripts in bin/. Remove both simultaneously.
- **localdev() function cleanup:** This function at .zshrc:153-184 is Linux-only. Must verify no other functions call it before removal.
- **.zshrc.local cleanup enhances .zshrc cleanup:** Both files should be consistent. Currently .zshrc.local:1-16 contains the same aliases that are commented out in .zshrc.

## MVP Definition

### Launch With (v1.2 — Cleanup Complete)

Minimum viable cleanup — what's needed to safely remove company config.

- [x] **Remove Courtsite aliases from .zshrc** — delete commented aliases at lines 315-328 (already commented, just delete)
- [x] **Remove `localdev()` function** — delete lines 153-184 (Linux-only function with COURTSITE_DIR)
- [x] **Remove sinar-pi-setup and sinar-pi-wifi-setup from bin/** — delete the two scripts (35KB total)
- [x] **Remove sinar-pi-setup aliases from .zshrc** — delete lines 321-322
- [x] **Clean .zshrc.local** — remove or empty the file (currently contains company aliases)
- [x] **Update README.md** — remove references to company scripts in documentation

### Add After Validation (v1.2.x)

Features to add once core cleanup is verified.

- [ ] **Audit gitconfig for company references** — check .gitconfig and any included files
- [ ] **Scan nvim/ config for company paths** — check lua configs, especially any hardcoded paths
- [ ] **Clean scripts/update-migration-pr** — contains COURTSITE_DIR usage at lines 42-43
- [ ] **Git history cleanup** — use git-filter-repo to remove company paths from entire git history

### Future Consideration (v1.3+)

Features to defer until after cleanup is validated.

- [ ] **Modularize .zshrc** — split into .zshrc.d/ with numeric prefixes (00-exports.zsh, 10-functions.zsh, etc.)
- [ ] **Move to ~/.config/exports/ pattern** — centralized local config management
- [ ] **Add Makefile target for cleanup verification** — `make audit` to scan for company references

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Remove company aliases from .zshrc | HIGH (privacy/cleanliness) | LOW (delete lines) | P1 |
| Delete company scripts from bin/ | HIGH (repo瘦身) | LOW (rm files) | P1 |
| Remove localdev() function | HIGH (remove company deps) | LOW (delete function) | P1 |
| Clean .zshrc.local | HIGH (remove company refs) | LOW (truncate file) | P1 |
| Update README.md | MEDIUM (accuracy) | LOW (edit docs) | P1 |
| Audit all config files | MEDIUM (completeness) | MEDIUM (search + verify) | P2 |
| Git history cleanup | HIGH (privacy) | HIGH (git-filter-repo) | P2 |
| Modularize .zshrc | LOW (nice to have) | MEDIUM (refactor) | P3 |
| Centralized local config | LOW (organization) | MEDIUM (restructure) | P3 |

**Priority key:**
- P1: Must have for v1.2 (cleanup milestone)
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Current State Analysis

### Files Containing Company References

| File | Line Numbers | Type | Action |
|------|---------------|------|--------|
| `zsh/.zshrc` | 153-184 | `localdev()` function with COURTSITE_DIR | DELETE function |
| `zsh/.zshrc` | 312-328 | Commented Courtsite aliases + sinar script aliases | DELETE lines |
| `zsh/.zshrc.local` | 1-16 | Active Courtsite aliases | TRUNCATE or remove file |
| `bin/sinar-pi-setup` | entire file | 24KB script for Pi setup | DELETE file |
| `bin/sinar-pi-wifi-setup` | entire file | 11KB script for Pi wifi | DELETE file |
| `scripts/update-migration-pr` | 12, 42-43 | References COURTSITE_DIR, courtsite domains | AUDIT/EDIT |
| `README.md` | 97-98 | Documents sinar-pi-* scripts | UPDATE docs |

### What Should Be Preserved

| Config | Why Preserve | Notes |
|--------|--------------|-------|
| Platform detection (is_darwin, is_linux) | Core cross-platform functionality | .zshrc:36-50 |
| PATH configuration | Required for all environments | .zshrc:52-81 |
| Generic aliases (ll, .., git shortcuts) | Personal productivity tools | .zshrc:102-298 |
| pnpm/docker/git shortcuts | Personal workflow | .zshrc:216-310 |
| Powerlevel10k config | Personal prompt setup | .zshrc:344-348 |
| .zshrc.local sourcing | Pattern for local overrides | .zshrc:411-413 (PRESERVE the mechanism, not the content) |
| Oh My Zsh setup | Shell framework | .zshrc:16-30 |

## Sources

- **Evan Moses (2025)** — "Separating work and personal config" — Using `.local/git.config` includes and conditional gitconfig — https://www.emoses.org/posts/keeping-work-separate/
- **Carmelyne Thompson (2026)** — "2 Step Defense in Depth for Dotfiles: Modularizing Your .zshrc" — Numeric prefixes for load order — https://carmelyne.com/modularizing-your-zshrc/
- **Prabesh (2025)** — "Stop Polluting Your .zshrc" — Separate exports into `~/.config/exports/` — https://office.qz.com/stop-polluting-your-zshrc-heres-how-to-organize-your-shell-exports-like-a-pro-5ec545a341c0
- **GitHub Docs** — "Best practices for leaving your company" — Clean up repo associations, local copies — https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-user-account/managing-user-account-settings/best-practices-for-leaving-your-company
- **sethwebster/dotfiles (2026)** — Example of `.zshrc.local` pattern for machine-specific config — https://github.com/sethwebster/dotfiles
- **Current state analysis** — Grep search across repo found 74 matches for courtsite/sinar/COURTSITE patterns

---

*Feature research for: Dotfiles cleanup & Courtsite decoupling*
*Researched: 2026-04-30*
