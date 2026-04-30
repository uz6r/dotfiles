# Roadmap: Milestone v1.2 - Cleanup & Decoupling

**Milestone Goal:** Remove Courtsite/company-specific configuration since leaving the company

**Granularity:** Coarse
**Phases:** 3 (Phase 6-8)

---

## Phases

- [ ] **Phase 6: Clean Shell Configuration** - Remove Courtsite references from .zshrc
- [ ] **Phase 7: Remove Company Scripts** - Delete bin/ scripts and verify symlinks
- [ ] **Phase 8: Verify & Update Documentation** - Final verification and README update

---

## Phase Details

### Phase 6: Clean Shell Configuration
**Goal**: User can use dotfiles with zero Courtsite references in .zshrc while preserving cross-platform detection

**Depends on**: Nothing (first phase of v1.2)

**Requirements**: SHELL-01, SHELL-02, SHELL-03, SHELL-04

**Success Criteria** (what must be TRUE):
  1. User can start a new zsh session without errors (`zsh -n .zshrc` passes)
  2. User can use shell without `localdev()` function available (function removed)
  3. User can view .zshrc with no commented Courtsite aliases (lines 311-328 removed entirely)
  4. User can verify cross-platform detection works (`is_darwin()`, `is_linux()` functions present and functional)

**Plans**: 2 plans

Plans:
- [ ] 06-01-PLAN.md — Remove Courtsite references from .zshrc and delete update-migration-pr script
- [ ] 06-02-PLAN.md — Add courtsite-guard to Makefile and pre-commit hook

---

### Phase 7: Remove Company Scripts
**Goal**: User can use dotfiles with only generic portable utilities in bin/ and no broken symlinks

**Depends on**: Phase 6 (shell startup working correctly)

**Requirements**: SCRIPT-01, SCRIPT-02, SCRIPT-03

**Success Criteria** (what must be TRUE):
  1. User can verify `sinar-pi-setup` and `sinar-pi-wifi-setup` no longer exist in bin/
  2. User can run GNU Stow operations without broken symlink errors (`stow -D bin && stow bin` succeeds)
  3. User can verify PATH configuration doesn't reference non-existent `scripts/` directory (line 80 audited)

**Plans**: TBD

---

### Phase 8: Verify & Update Documentation
**Goal**: User can verify complete cleanup and has updated documentation with zero Courtsite references

**Depends on**: Phase 6 and Phase 7 (all code changes complete)

**Requirements**: DOC-01, DOC-02, DOC-03

**Success Criteria** (what must be TRUE):
  1. User can read README.md without any Courtsite/sinar/enjin references
  2. User can run `rg -i "courtsite|sinar|enjin|COURTSITE_DIR"` with zero matches in the repository
  3. User has clear instructions to check `~/.zshrc.local` manually for any remaining Courtsite references

**Plans**: TBD

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 6. Clean Shell Configuration | 0/2 | Not started | - |
| 7. Remove Company Scripts | 0/3 | Not started | - |
| 8. Verify & Update Documentation | 0/3 | Not started | - |

---

## Deferred to Future Milestones

| Requirement | Reason |
|-------------|--------|
| GIT-01 | Repo is private; only needed if repo goes public (requires git-filter-repo, force push) |

---

*Roadmap created: 2026-04-30 for milestone v1.2*
