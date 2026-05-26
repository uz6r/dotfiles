# Private Directory

This directory is gitignored entirely.
Everything inside is LOCAL-ONLY and machine-specific.

## Purpose

Separate public-tracked state from private-local state.
Files that should NEVER be committed to the repo belong here.

## What Goes Here

- `.zshrc.local` — Machine-specific zsh overrides
- `.gitconfig.local` — Machine-specific git config (name, email, signing key)
- `secrets/` — API keys, tokens, credentials (if needed for local scripts)
- `machine/` — Per-machine notes, setup docs, backup references

## Rules

- Nothing in this directory is ever committed to git
- Do NOT symlink or reference private/ files from tracked configs
- If a config needs machine-specific values, use the `.local` override pattern

## Before Machine Wipe

Review this directory and back up anything you want to keep.
Then securely delete the entire directory before wiping the machine.

See PRE-RESET-CHECKLIST.md at repo root for the full pre-wipe checklist.
