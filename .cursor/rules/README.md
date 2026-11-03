# AISDLC — Cursor Adapter (F33)

This folder ships the framework's rules for Cursor. Every `.mdc` here is **generated** by `bin/gen-cursor-rules.py` from the Claude files, which are the only source:

- `.claude/rules/<name>.md` → `<name>.mdc`
- `.claude/agents/<name>.md` → `persona-<name>.mdc`
- `framework-agents.mdc` — index of the personas

Each `.mdc` is a short pointer that pulls its source in with an `@../../<path>` reference, so the Cursor and Claude copies cannot drift. **Never edit an `.mdc` by hand** — edit the source, then:

```bash
python3 bin/gen-cursor-rules.py          # rewrite this folder
python3 bin/gen-cursor-rules.py --check  # fails if anything is out of date
```

`bin/check-framework.py` also fails when a rule or agent has no `.mdc`, or an `.mdc` has no source.

## Always-on vs on-demand

Always-on rules (`alwaysApply: true`) load into every chat and cost context, so only the rules that apply to every action are always on: `kanban-workflow`, `solo-vs-team-mode`, `source-control`, `secrets-management`, `ticket-discipline`. The rest load when their description matches the task. The list lives in `RULES` at the top of the generator.

## How projects consume

In the project workspace root (`<project>/`):

```bash
mkdir -p .cursor/rules
ln -s ../../aisdlc/.cursor/rules .cursor/rules/framework
```

Cursor loads all `.mdc` files under `.cursor/rules/` recursively. The `@../../.claude/...` references are relative to the rule file, so they resolve inside the framework clone even when reached through the symlink.

Project-specific rules stay in the project's own `.cursor/rules/`, next to the `framework/` symlink — for example `000-<project>-overview.mdc` (repos, branches, mode) or stack rules with globs such as `globs: erp-core/**`.

## Ticket reference

- F33: Cursor adapter (parent)
- F34: `framework.tools` field in the stack file schema
- F35: Tool parity doc — Claude Code ↔ Cursor capability map
