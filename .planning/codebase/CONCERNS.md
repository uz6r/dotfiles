# CONCERNS.md — Technical Debt & Issues

## Known Issues (v1.3 State)

### 1. Git History Contains WiFi Password
- **Severity:** Critical (deferred)
- **Issue:** ZTE_EC382D.nmconnection (psk=7A33S6282B) exists in git history even though it's been removed from HEAD
- **Mitigation:** File removed from tracking and .gitignore'd. Full history scrub (git-filter-repo) deferred (GIT-01) — only needed if repo goes public

### 2. macOS Compatibility (Static Analysis Only)
- **Severity:** Medium
- **Issue:** macOS compat fixed for known incompatibilities (duh, readlink, grep, date) but verified via static analysis only
- **Impact:** Untested on actual macOS hardware
- **Mitigation:** bin/verify-macos catches known GNU-only patterns; manual smoke test recommended before declaring cross-platform ready

### 3. No Actual Test Suite
- **Severity:** Low
- **Issue:** No automated test suite for dotfiles functionality
- **Mitigation:** `make doctor` runs all verification targets; pre-commit hook and CI catch regressions

### 4. Pre-Commit Hook Runs Format Check
- **Severity:** Low
- **Issue:** `make format` runs on every commit, which can be slow if many formatters run
- **Mitigation:** Format check is fast (<2s); only blocks on unformatted files, doesn't auto-format without review

## Security Posture (v1.3)

| Threat | Status | Notes |
|--------|--------|-------|
| Secrets in tracking | ✅ Mitigated | Gitleaks + pre-commit secret scan + make sanitize |
| Binary bloat | ✅ Mitigated | Pre-commit binary detection + make sanitize |
| Hardcoded paths | ✅ Mitigated | All /home/uzer replaced with $HOME |
| Pre-commit bypass | ✅ Mitigated | Hook blocks secrets, binaries, Courtsite |
| .gitignore coverage | ✅ Mitigated | Security patterns for nmconnection, pem, key, env* |
| Git history secrets | ⚠️ Deferred (GIT-01) | WiFi password in history; git-filter-repo if repo goes public |

## Performance Concerns

- **Shell startup time** — zsh with oh-my-zsh + plugins (~950ms measured in v1.1). P10k instant prompt mitigates perceived latency.
- **Lazy loading** — Neovim plugins (nvim-cmp, LSP) load on demand via lazy.nvim.

## Tech Debt

1. **Oh-my-zsh dependency** — Heavy, but standard for zsh configuration
2. **Powerlevel10k config** — Large `.p10k.zsh` file (~700 lines)
3. **Plugin count** — 20+ neovim plugins, some may be unused (audit via `bin/audit-nvim-plugins`)
4. **macOS CI runner** — Deferred to v1.4+ (cost/benefit for personal dotfiles)
5. **Modular nvim init.lua** — 472 lines monolithic; split into lua/ modules deferred to v1.4+

## Fragile Areas

| Area | Risk | Reason |
|------|------|--------|
| `.zshrc` (365 lines) | Medium | Large file, many conditional branches, platform guards |
| Platform detection | Low | Simple `uname -s` check |
| Pre-commit hook | Low | 4 check sections; ensure new checks don't slow commits |
