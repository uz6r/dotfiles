# Testing

This dotfiles repository uses linting and formatting tools rather than traditional unit tests.

## Test Framework

**None** - This is a configuration repository, not an application.

## Linting Tools

| Tool | File Types | Config Location |
|------|------------|-----------------|
| **shellcheck** | `.sh` scripts | `Makefile` |
| **luacheck** | `.lua` (Neovim) | `.luacheckrc`, `Makefile` |
| **yamllint** | `.yml`, `.yaml` | `.yamllint.yaml` |
| **jq** | `.json` | `Makefile` |
| **zsh -n** | `.zshrc` | `Makefile` |

## Formatting Tools

| Tool | File Types | Config Location |
|------|------------|-----------------|
| **shfmt** | Shell scripts | `Makefile` (indent: 2, ci) |
| **stylua** | Lua | `Makefile` |
| **prettier** | YAML, JSON, Markdown | `Makefile` |

## Test Targets (Makefile)

```makefile
make lint        # Run linters only (no auto-fix)
make format      # Lint + format (auto-fix)
make ci-check    # Full CI pipeline (strict yamllint + diff check)
```

## CI Pipeline (`.github/workflows/ci.yml`)

1. Install dependencies (shellcheck, shfmt, yamllint, jq, lua5.4, luarocks, cargo)
2. Install tools (luacheck via luarocks, stylua via cargo, prettier via npm)
3. Run `make format`
4. Run `yamllint .` (strict mode)
5. Check for uncommitted changes (fails if diff exists)

## Coverage

Not applicable - configuration files are validated through linting/formatting, not code coverage.

## Manual Validation

- `make status` - Verify symlinks are correct
- `make bootstrap` - Test on fresh system (or VM)