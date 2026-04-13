# TESTING.md — Test Structure & Practices

**Focus:** Testing framework, structure, mocking, and coverage

## Testing Approach

This is a dotfiles repository — no unit tests exist. Quality is maintained through:

| Method | Tool | Configuration |
|--------|------|----------------|
| Shell syntax validation | `zsh -n` | Makefile `lint` target |
| Shell linting | `shellcheck` | Makefile `lint` target |
| Shell formatting | `shfmt` | Makefile `format` target |
| YAML linting | `yamllint` | `.yamllint.yaml` |
| JSON validation | `jq` | Makefile `lint` target |
| Lua linting | `luacheck` | `.luacheckrc` |
| Lua formatting | `stylua` | Makefile `format` target |

## CI Pipeline

GitHub Actions (`.github/workflows/ci.yml`) runs:

```yaml
make ci-check
```

Which executes:
1. `make format` — auto-fix all files
2. `yamllint .` — strict YAML validation
3. `git diff --exit-code` — fail if formatted files not committed

## Pre-Commit Hook

`.githooks/pre-commit` runs:
- Formatters (shfmt, prettier, stylua)
- Linters (shellcheck, yamllint, luacheck)
- If changes detected, commit is blocked until formatted

## Manual Testing

| Command | Purpose |
|---------|---------|
| `make bootstrap` | Test stow symlink creation |
| `make status` | Verify symlinks are valid |
| `make lint` | Run all linters |
| `make format` | Run formatters |
| `make ci-check` | Simulate CI locally |
| `zsh -n zsh/.zshrc` | Syntax check shell config |

## No Test Frameworks

- No Jest, Vitest, or similar
- No pytest, unittest
- Dotfiles are configuration, not application code

## Validation Checklist

Before committing:
- [ ] `make ci-check` passes
- [ ] `zsh -n zsh/.zshrc` passes
- [ ] No new shellcheck warnings
- [ ] All formatted files committed