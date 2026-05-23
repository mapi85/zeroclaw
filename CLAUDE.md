# CLAUDE.md — ZeroClaw (Claude Code)

> **Shared instructions live in [`AGENTS.md`](./AGENTS.md).**
> This file contains only Claude Code-specific directives.

## Claude Code Settings

Claude Code should read and follow all instructions in `AGENTS.md` at the repository root for project conventions, commands, risk tiers, workflow rules, and anti-patterns.

## Hooks

_No custom hooks defined yet._

## Slash Commands

_No custom slash commands defined yet._

---

## Local Project Setup (branch: local/dev)

This local replica tracks `origin/master` (upstream) on branch `master`.
All local modifications live on branch `local/dev`.

**Sync strategy** — see `docs/local/git-strategy.md` for full workflow:
- `master` = clean mirror of upstream (`git pull origin master` to update)
- `local/dev` = local modifications, rebased on top of master after each upstream pull

**Local documentation** (not part of upstream — preserved on `local/dev`):
- `docs/local/architecture.md` — codebase navigation guide for the agent
- `docs/local/modification-guide.md` — safe intervention patterns for this codebase
- `docs/local/git-strategy.md` — upstream sync workflow with conflict resolution guide

When making code changes, always work on `local/dev` or a feature branch off it.
Never commit directly to `master`.
