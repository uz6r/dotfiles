# Project Research Summary

**Project:** Dotfiles Cleanup — Remove Courtsite/Sinar Company Configuration
**Domain:** Dotfiles maintenance and decoupling from company-specific configuration
**Researched:** 2026-04-30
**Confidence:** HIGH

## Executive Summary

This is a dotfiles cleanup project focused on removing Courtsite/Sinar company-specific configuration from a personal dotfiles repository managed with GNU Stow. The repository contains zsh configuration (.zshrc, .zshrc.local), utility scripts (bin/), and configuration for git, neovim, and tmux. Expert approach: surgical removal of company references while preserving the cross-platform detection logic and the .zshrc.local override pattern that keeps machine-specific config out of the repo.

The recommended approach is a three-phase cleanup: first remove company functions and aliases from .zshrc (lines 153-184 localdev function, lines 312-328 commented aliases), second properly unstow and delete company scripts from bin/ (sinar-pi-setup, sinar-pi-wifi-setup), and third verify cleanup and update documentation. The .zshrc.local pattern should be preserved but documented for users to check their local files. GNU Stow's `stow -D` must be used before deleting files to prevent broken symlinks.

Key risks are breaking shell startup (syntax errors in .zshrc), leaving broken symlinks after deleting bin/ scripts, and stale PATH entries pointing to removed directories. These are mitigated by running `zsh -n .zshrc` syntax checks, using proper stow unstow workflow, and auditing the PATH line. Git history may contain company references—use git-filter-repo if the repo will go public, otherwise a simple commit suffices for private repos.

## Key Findings

### Recommended Stack

Core technologies: zsh 5.x+ (existing shell, no change), GNU Stow 2.x+ (symlink management, already in use), ripgrep 13.x+ (fast search for company references across repo). Supporting tools: git-filter-repo 2.38+ (history cleanup if needed), gitleaks 8.x+ (secret scanning), repgrep/sd (interactive find-replace alternatives to sed).

**Core technologies:**
- zsh 5.x+: Shell configuration — existing shell, cleanup focuses on removing content not replacing
- GNU Stow 2.x+: Symlink management — use `stow -D` before deleting files to prevent broken symlinks
- ripgrep 13.x+: Search references — 100x faster than grep, respects .gitignore, essential for finding all Courtsite references

### Expected Features

**Must have (table stakes):**
- Remove `localdev()` function from .zshrc (lines 153-184) — eliminates COURTSITE_DIR dependencies
- Delete commented Courtsite aliases from .zshrc (lines 312-328) — remove comment rot entirely
- Remove sinar-pi-setup and sinar-pi-wifi-setup from bin/ — delete 35KB of company-specific scripts
- Clean or truncate .zshrc.local — remove company aliases from local override file
- Update README.md — remove references to deleted scripts

**Should have (competitive):**
- Audit gitconfig, nvim/, tmux/ for any remaining company references — completeness check
- Git history cleanup with git-filter-repo — privacy if repo goes public (HIGH complexity)
- Automated cleanup verification script — `make audit` target using ripgrep

**Defer (v2+):**
- Modularize .zshrc into conf.d/ with numeric prefixes — nice to have, not cleanup-related
- Centralized local config in ~/.config/exports/ — architectural improvement for later

### Architecture Approach

The dotfiles use a standard GNU Stow structure with one directory per tool (zsh/, git/, nvim/, tmux/, bin/). The .zshrc.local pattern provides machine-specific overrides that stay out of git. Post-cleanup architecture remains identical but with zero Courtsite references in tracked files. Critical: preserve platform detection (is_darwin, is_linux functions at lines 36-50) and the .zshrc.local sourcing mechanism (lines 411-413).

**Major components:**
1. zsh/.zshrc — Main shell config, cleanup removes lines 153-184 and 312-328
2. zsh/.zshrc.local — Local overrides (gitignored), users must check manually after cleanup
3. bin/ — Utility scripts, remove sinar-pi-setup and sinar-pi-wifi-setup entirely

### Critical Pitfalls

1. **Breaking shell startup via incomplete function removal** — Always run `zsh -n .zshrc` before and after edits; remove entire block including `if is_linux; then ... fi` wrapper
2. **Broken symlinks after deleting bin/ scripts** — Run `stow -D bin` before deleting files, then `stow bin` after; verify with `chkstow -b`
3. **Cross-platform conditionals damaged** — Never edit platform detection block (lines 36-50); preserve is_darwin() and is_linux() functions
4. **Git history contains company references** — Run `git log -p --all -S "COURTSITE_DIR"` to check; use git-filter-repo if repo goes public
5. **Comment rot left in .zshrc** — Delete ALL commented Courtsite aliases (lines 311-328 entirely), not just uncomment them

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Clean .zshrc
**Rationale:** .zshrc is the core file that affects every shell startup; must be cleaned first and verified before proceeding. Dependencies: none (can start immediately).
**Delivers:** Clean .zshrc with zero Courtsite references, shell startup verified
**Addresses:** Remove localdev() function, delete commented Courtsite aliases, verify PATH line, fix typo in line 319
**Avoids:** Pitfall 1 (shell startup), Pitfall 2 (stale PATH), Pitfall 4 (cross-platform), Pitfall 5 (comment rot), Pitfall 8 (typo), Pitfall 10 (DOTFILES_DIR)

### Phase 2: Remove bin/ Scripts
**Rationale:** Must use proper GNU Stow workflow (stow -D before deletion) to prevent broken symlinks. Depends on: Phase 1 complete (no shell startup issues).
**Delivers:** bin/ directory with only generic portable utilities, no broken symlinks in ~/bin/
**Uses:** GNU Stow (`stow -D bin`, then `stow bin`), ripgrep to verify no references remain
**Implements:** Anti-pattern 3 fix (no company scripts in bin/)
**Avoids:** Pitfall 3 (broken symlinks)

### Phase 3: Verify and Update Documentation
**Rationale:** Final verification ensures complete cleanup; update README to reflect deleted scripts. Depends on: Phase 1 and 2 complete.
**Delivers:** Updated README.md, verification report (ripgrep scan clean), user documentation for .zshrc.local check
**Addresses:** README update (P1), audit for remaining references, document .zshrc.local check for users
**Avoids:** Pitfall 9 (README outdated), Pitfall 7 (.zshrc.local not checked)

### Phase 4 (Optional): Git History Cleanup
**Rationale:** Only needed if repo will go public or company paths in history are a concern. HIGH complexity, requires force push.
**Delivers:** Git history scrubbed of all Courtsite references using git-filter-repo
**Addresses:** Git history cleanup (P2 feature), secret scanning with gitleaks
**Avoids:** Pitfall 6 (git history leak), security mistakes
**Note:** Skip this phase if repo is private and staying private.

### Phase Ordering Rationale

- **Phase 1 first:** .zshrc affects every shell session; must be verified working before other changes
- **Phase 2 second:** bin/ scripts depend on stow workflow; must unstow before deletion to prevent symlink issues
- **Phase 3 third:** Documentation and verification come last when all code changes are complete
- **Phase 4 optional:** History rewriting is destructive and only needed for specific privacy requirements

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 4 (Git History Cleanup):** Complex git-filter-repo usage, requires fresh clone and coordination if repo has collaborators. Research needed if this phase is approved.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Clean .zshrc):** Well-documented patterns, use `zsh -n` for syntax check, manual review of each removal
- **Phase 2 (Remove bin/ scripts):** Standard GNU Stow workflow (stow -D, delete, stow), well-documented
- **Phase 3 (Verify & Update):** Standard documentation update, ripgrep verification

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All tools verified with official docs (ripgrep, GNU Stow, git-filter-repo) |
| Features | HIGH | Based on grep search of actual repo (74 matches found), clear P1/P2/P3 prioritization |
| Architecture | HIGH | Standard dotfiles patterns documented in multiple 2025-2026 sources, current state analyzed directly |
| Pitfalls | HIGH | 10 pitfalls identified with prevention strategies, mapped to phases, recovery strategies included |

**Overall confidence:** HIGH — All research based on official documentation, current repository state analysis, and multiple recent (2025-2026) community sources.

### Gaps to Address

- **Git history privacy decision:** Need to confirm if repo is private or may go public — determines if Phase 4 (git-filter-repo) is needed. Handle during planning: ask user about repo privacy intentions.
- **.zshrc.local local state:** Cannot verify users' local ~/.zshrc.local files — handle during execution: document check, user must verify manually.
- **Cross-platform testing:** Research assumes current cross-platform logic is correct — handle during execution: test `is_darwin` and `is_linux` functions after Phase 1.

## Sources

### Primary (HIGH confidence)
- [Context7: /burntsushi/ripgrep](https://github.com/burntsushi/ripgrep) — Search syntax, FAQ
- [GitHub Docs: Removing sensitive data](https://docs.github.com/articles/remove-sensitive-data) — git-filter-repo usage
- [git-filter-repo docs](https://www.mintlify.com/newren/git-filter-repo/) — Path filtering, sensitive data removal
- [GNU Stow manual](https://www.gnu.org/software/stow/manual/) — Delete/unstow operations, chkstow utility
- [Building Modern Cross-Platform Dotfiles](https://shinyaz.com/en/blog/2026/03/15/modern-dotfiles-guide) — Cross-platform guard patterns
- [ADR-083: Modular ZSH Configuration Architecture](https://docs.coditect.ai) — Architectural pattern
- Current repository state — Direct analysis of .zshrc, bin/, .zshrc.local (HIGH confidence)

### Secondary (MEDIUM confidence)
- [Carmelyne Thompson: Modularizing Your .zshrc](https://carmelyne.com/modularizing-your-zshrc/) — Shell startup safety (2026)
- [StackOverflow: .zshrc.local pattern](https://stackoverflow.com/questions/67375498/) — Not standard but common convention
- [timkicker/dotfiles security guide](https://github.com/timkicker/dotfiles/security) — Pre-push checklist, rg scanning
- [Evan Moses: Separating work and personal config](https://www.emoses.org/posts/keeping-work-separate/) — Conditional gitconfig includes
- [Prabesh: Stop Polluting Your .zshrc](https://office.qz.com/stop-polluting-your-zshrc) — Exports organization (2025)

### Tertiary (LOW confidence)
- [Websearch: dotfiles cleanup best practices 2026] — General patterns (MEDIUM-LOW, sparse recent content)

---
*Research completed: 2026-04-30*
*Ready for roadmap: yes*
