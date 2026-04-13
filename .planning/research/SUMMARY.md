# Research Summary

**Project:** Dotfiles Cross-Platform Compatibility (Linux ↔ macOS)
**Synthesized:** 2026-04-13

## Key Findings

### Stack
- **Package Manager:** Homebrew works on both platforms (Linuxbrew on Linux, Homebrew on macOS)
- **Core Tools:** Clipboard, network tools, and some flags differ between Linux and macOS
- **Solution:** Platform detection via `uname -s` + conditional aliases

### Table Stakes (Must Implement)
1. Platform detection in .zshrc (`uname -s` == Darwin vs Linux)
2. Unified clipboard aliases (copy/paste work on both)
3. Unified open command (xdg-open on Linux, native on macOS)
4. Homebrew path detection for both platforms
5. Network tool fixes (localip, ports)
6. install.sh updated for brew/brew detection

### Watch Out For
1. **GNU vs BSD tools:** `sed -i` flags differ, `ls --color` vs `-G`
2. **Homebrew paths:** Different by platform AND architecture on macOS
3. **xclip:** Linux-only, macOS has native `pbcopy`/`pbpaste`
4. **Hardcoded paths:** Use `$HOME` not `/home/username`
5. **Shellcheck ignores zsh:** Always test with `zsh -n`

## Architecture

Inline platform detection preferred for this project:

```zsh
if [[ "$(uname -s)" == "Darwin" ]]; then
  # macOS specific
else
  # Linux specific
fi
```

Keep platform-specific code grouped, source at end of .zshrc.

## Files to Update

1. **zsh/.zshrc** — Add platform detection, fix aliases
2. **install.sh** — Add brew detection alongside apt
3. **Makefile** — Ensure brew paths work (already handles apt/brew)

## Effort Estimate

- **Phase 1:** Platform detection + basic aliases (1-2 hours)
- **Phase 2:** install.sh update + scripts check (30 min)
- **Phase 3:** Testing on both platforms (1 hour, if Mac available)

---
*Summary synthesized: 2026-04-13*
