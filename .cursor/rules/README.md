# AISDLC — Cursor Adapter (F33)

This folder ships the framework's Cursor rules. Projects consume them by symlinking this directory into their workspace.

## What's here

Twelve framework-level `.mdc` rules that mirror canonical `.claude/rules/` and `.claude/agents/` content for Cursor:

| Rule | Scope | Description |
|---|---|---|
| `secrets-management.mdc` | alwaysApply | Never commit secrets |
| `kanban-workflow.mdc` | alwaysApply | 12-column pipeline, board move commands |
| `source-control.mdc` | alwaysApply | gh + glab CLI-first policy |
| `solo-vs-team-mode.mdc` | alwaysApply | Autonomy per operating mode |
| `framework-agents.mdc` | description | Persona map |
| `agent-communication.mdc` | description | Handoff conventions |
| `client-facing-boundary.mdc` | description | What stays internal |
| `size-audit.mdc` | description | Pre-work file audit, tech-debt ticketing |
| `persona-planner.mdc` | description | FRD Tech Plan + contracts |
| `persona-tester.mdc` | description | TDD from contracts |
| `persona-shipper.mdc` | description | Staging deploy + release composition |
| `persona-ticket-manager.mdc` | description | Board moves + mode-awareness |

All reference canonical content via relative paths (`../../.claude/rules/...`, `../../.claude/agents/...`) so symlinks resolve correctly from project workspaces.

## How projects consume

In the project workspace root (`<project>/`):

```bash
mkdir -p .cursor/rules
ln -s ../../aisdlc/.cursor/rules .cursor/rules/framework
```

Cursor auto-loads all `.mdc` files under `.cursor/rules/` recursively, so the framework rules activate automatically. Project-specific rules (repo lists, stack globs, operating-mode declarations) live as peer files in `.cursor/rules/` alongside the `framework/` symlink.

## Project-specific rules (examples)

These stay in the project's own `.cursor/rules/`, not in the framework:

- `000-<project>-overview.mdc` — repo layout, branches, operating mode declaration.
- `stack-*.mdc` with project globs — e.g., `globs: <project>-be/**` for a Django repo.
- `persona-builder.mdc` with project globs — e.g., `globs: <project>-be/**`.
- `persona-fe-builder.mdc` with project globs — e.g., `globs: <project>-fe/**, <project>-admin/**`.
- `persona-project-wiki.mdc` with doc globs — e.g., `globs: <project>-be/docs/**`.

## Path resolution

All framework rules reference canonical content with paths relative to the rule file's location:

```
aisdlc/.cursor/rules/secrets-management.mdc
  references: ../../.claude/rules/secrets-management.md
  resolves to: aisdlc/.claude/rules/secrets-management.md
```

Because Cursor resolves paths relative to the file's access path (through the project symlink), the same reference works when the file is accessed as `<project>/.cursor/rules/framework/secrets-management.mdc` — it resolves to `<project>/.claude/rules/secrets-management.md`, which is itself a symlink to `aisdlc/.claude/rules/secrets-management.md`. Either resolution path leads to the same file.

## Ticket reference

- F33: Cursor adapter (parent)
- F34: `framework.tools` field in stack-*.yml schema
- F35: Tool parity doc — Claude Code ↔ Cursor capability map
