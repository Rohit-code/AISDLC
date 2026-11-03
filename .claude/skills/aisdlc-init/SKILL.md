---
name: aisdlc-init
description: Set up a new or half-set-up project for AISDLC. Use when the user runs /aisdlc-init or asks to initialize, onboard or bootstrap a project onto the framework (context repo, board, stack files, test infra). Checks every setup step and files a setup ticket on the project board only for the steps that are missing; safe to re-run.
---

# /aisdlc-init

```
/aisdlc-init <project-slug> --stack=<spring-next|django-react|voice-s2s> --repos=<a,b> [--create]
```

- `<project-slug>` — e.g. `erp`
- `--stack` — a directory under `templates/SETUP-TICKETS/`
- `--repos` — workspace repo directories, optionally typed: `--repos=erp-core:be,erp-fe:fe`. Untyped: first = `be`, rest = `fe`
- Without `--create` the run is a dry run: it lists what it would file and creates nothing. Always do the dry run first and show it to the user; pass `--create` (or get the user's "go") to file the tickets.

Run from the workspace root — the workspace IS the AISDLC clone, with the project repos and `<project>-context/` cloned inside it (gitignored; layout in `CLAUDE.md`). The full contract is `templates/SETUP-TICKETS/README.md`; if it and this skill disagree, the README wins and the skill gets a framework-gap ticket (`bin/aisdlc-observe.sh --type drift ...`).

## Steps

1. **Read** `templates/SETUP-TICKETS/README.md`, `_common/manifest.yml` and `<stack>/manifest.yml`. Unknown stack → stop and list the stack directories.
2. **Merge** the ticket lists: `_common` first, then the stack's; drop every `_common` id the stack lists under `overrides: - skip:`.
3. **Resolve the variables** (`$PROJECT`, `$WORKSPACE`, `$CONTEXT_DIR`, `$MAIN_REPO`, `$BE_REPO`, `$FE_REPO`, `$BOARD_ID`) exactly as the README's Variables table says. `$BOARD_ID` = `board.project_id` from `$CONTEXT_DIR/board-config.yml`, empty if that file is missing.
4. **Filter by `applies_to`**: `backend` needs a `be` repo, `frontend` an `fe` repo, `fullstack` both. A ticket whose dependency was dropped as not applicable is dropped too.
5. **Order by `depends_on`** (topological; ids may point at `_common` ids). An id that names no ticket is a manifest bug: stop and report it.
6. **Run each `idempotent_check`** with `bash -c '<check>'` and the variables exported, cwd = workspace root. With `runs_per: frontend_repo` (or `backend_repo`) run it once per repo of that type, binding `$FE_REPO` (or `$BE_REPO`); the instance id is `<id>/<repo>` (e.g. `J07/erp-fe`). Exit 0 = done; anything else = needed.
7. **Find existing tickets** for every needed id before creating anything. Tickets are titled `<id> [setup] ...`; search open and closed:
   ```bash
   gh issue list --repo <board repo> --state all --search "\"<id> [setup]\" in:title" --json number,title,state
   ```
   `<board repo>` is `board.repo` in `$CONTEXT_DIR/board-config.yml`. If that file does not exist yet, never invent IDs — that is the bootstrap gap (step 9). A match (open or closed) means: do not create, report it as "already filed (#n)".
8. **Dry-run listing** — print one table: id, title, result (`done` / `needed` / `already filed #n` / `not applicable` / `skipped by stack`), and dependencies still needed. Stop here unless `--create`.
9. **Bootstrap gap** — if S1, S2 or S3 is needed, there is no board to file on yet. Do not create anything; print the S1–S3 template steps for the human and ask them to re-run after.
10. **Create** each needed ticket in dependency order:
    ```bash
    URL=$(gh issue create --repo <board repo> --title "<id> [setup] <title without the [setup] prefix>" --body-file <filled template>)
    ITEM_ID=$(gh project item-add <project_number> --owner <owner> --url "$URL" --format json --jq .id)
    gh project item-edit --project-id <project_id> --id "$ITEM_ID" --field-id <status_field_id> --single-select-option-id <status_options.backlog>
    ```
    Body = the `template` file with `<project>` and the variables filled in, plus one line `Depends on: #<n>, #<m>` listing every dependency that is also needed or open (the framework-wide dependency syntax; check recipe in `.claude/rules/gh-recipes.md`). `<owner>` is the user login or org in `board.url` (`/users/<login>/` or `/orgs/<org>/`). Set Priority from the manifest when the board has a Priority field. Tickets go into 📥 Backlog only.
11. **Report** — created (with URLs), already filed, done, not applicable, skipped by stack. Re-running right after must create zero tickets.

## Never

- Never create a ticket whose id is already on the board (open or closed) — search first, every run.
- Never run a check that writes: checks are read-only. If a check in a manifest changes files, stop and file a framework-gap ticket.
- Never do the setup work itself in this skill; it only files tickets. The work happens later, ticket by ticket, through the normal pipeline.
- Never move a ticket out of 📥 Backlog.
