# SETUP-TICKETS

Idempotent foundation tickets for initializing a new AISDLC project. `/aisdlc-init` (`.claude/skills/aisdlc-init/SKILL.md`) reads them.

## Structure

```
SETUP-TICKETS/
├── README.md              ← You are here
├── _common/               ← Universal S-tickets (apply to any project)
│   ├── manifest.yml       ← Ordered list + idempotent checks
│   └── S*.md              ← One file per ticket template
├── spring-next/           ← Spring Boot BE + Next.js FE(s)
│   ├── README.md          ← When to use this variant
│   ├── manifest.yml
│   └── J*.md
├── django-react/          ← Django BE + React/Next FEs
│   ├── README.md
│   ├── manifest.yml
│   └── C*.md
└── voice-s2s/             ← OpenAI Realtime / streaming voice
    ├── README.md
    ├── manifest.yml
    └── V*.md
```

## How init uses this

When `/aisdlc-init <project-slug> --stack=<spring-next|django-react|voice-s2s> --repos=<a,b> [--create]` runs from the project workspace root:

1. **Read `_common/manifest.yml`** — universal tickets
2. **Read `<stack>/manifest.yml`** — stack-specific additions; drop every `_common` ticket the stack lists under `overrides: - skip:`
3. **Resolve the variables** below, and drop tickets whose `applies_to` matches no declared repo
4. **For each ticket, in `depends_on` order**, run its `idempotent_check` with `bash -c` (once per repo when `runs_per` is set)
   - Exit 0 → already done, skip
   - Non-zero → the ticket is needed
5. **List first** (dry run): search the board repo for each needed id (open and closed issues), then print every ticket with its result — done, needed, already filed, not applicable, skipped by stack. Without `--create`, init stops here
6. **Create** each needed ticket on the project board (📥 Backlog) from its `template` file, in dependency order, unless an issue for that id already exists. Tickets whose dependencies are also needed get a `Depends on: #<n>` line
7. **Report summary** — created, already existed, skipped (check passed), not applicable

S1–S3 are the bootstrap (context repo, board, board config). Until they pass there is no board to file on: init lists every needed ticket and asks the human to do S1–S3 by hand, then re-run.

## Variables

Every check runs with the project workspace root as working directory. Init sets:

| Variable | Value |
|---|---|
| `$PROJECT` | project slug from the command (e.g. `erp`) |
| `$WORKSPACE` | absolute path of the project workspace root |
| `$CONTEXT_DIR` | `$WORKSPACE/$PROJECT-context` |
| `$MAIN_REPO` | path of the first backend repo in `--repos` (or the first repo when there is none) |
| `$BE_REPO` | path of the backend repo (empty when there is none) |
| `$FE_REPO` | path of the frontend repo; with `runs_per: frontend_repo` it is each FE repo in turn |
| `$BOARD_ID` | `board.project_id` from `$CONTEXT_DIR/board-config.yml`; empty until S2/S3 are done |

`--repos` is a comma list of workspace directory names, each optionally typed: `--repos=erp-core:be,erp-fe:fe`. Untyped: the first repo is `be`, the rest are `fe`. A stack can also declare `voice` repos (voice-s2s).

## Manifest keys

| Key | Required | Meaning |
|---|---|---|
| `id` | yes | Unique across `_common` and every stack: `S*` common, `J*` spring-next, `C*` django-react, `V*` voice-s2s |
| `title` | yes | Issue title; init prefixes the id: `S4 [setup] Clone code repo(s) into workspace` |
| `template` | yes | Ticket body file in the same directory |
| `priority` | yes | P0 / P1 / P2 / P3 |
| `owner` | yes | Product / Tech / AI — who moves it next |
| `idempotent_check` | yes | One bash command; exit 0 = already done. Glob-safe (`ls <glob> >/dev/null 2>&1`, never `test -f <glob>`) |
| `depends_on` | yes | List of ids (may name `_common` ids); `[]` when none |
| `applies_to` | no | `backend`, `frontend` or `fullstack` (needs both); omitted = always |
| `runs_per` | no | `frontend_repo` or `backend_repo`: check and ticket once per repo of that type; the id gets the repo name (`J07/erp-fe`) |
| `overrides` | no | Stack manifests only: `- skip: <common id>` drops a `_common` ticket the stack replaces |

The `idempotent_check` is what makes init safe to re-run. Running init on a fully-set-up project creates zero tickets. Running it on a half-set-up project creates only the missing ones.

## Adding a new stack variant

1. Create `SETUP-TICKETS/<stack>/` directory
2. Add `README.md` describing when to use this variant
3. Add `manifest.yml` listing stack-specific tickets with a new id letter
4. Write ticket templates as markdown files (What / Why / Steps / Idempotent check / Acceptance)
5. Add the stack name to the `--stack` list in `.claude/skills/aisdlc-init/SKILL.md` and in this README

Examples of future variants: `mobile-rn`, `data-pipeline`, `ml-inference`, `iot-edge`.
