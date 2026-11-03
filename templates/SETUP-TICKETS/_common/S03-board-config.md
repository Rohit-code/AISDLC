# S3: Register project in `.claude/board-config.yml`

## What
Add the project's board IDs to `.claude/board-config.yml` so agents can move tickets via `gh` CLI without rediscovering IDs each session.

## Why
Without this, every agent that needs to move a ticket has to query the GitHub API for field/option IDs. Caching them in config eliminates 4+ discovery calls per session.

## Steps
1. Open `.claude/board-config.yml`
2. Add entry under `boards:` with:
   - `name`, `url`, `project_number`, `project_id`
   - `status_field_id` + all `status_options` (12 option IDs)
   - `priority_field_id` + option IDs
   - `owner_field_id` + option IDs
   - `scope_field_id` + option IDs
   - `repo:` — the context repo URL
3. Commit and push

## Idempotent check
```bash
grep -q "$PROJECT" .claude/board-config.yml
```

## Acceptance
- Project entry exists in `board-config.yml`
- All option IDs present and correct (verified by a test ticket move)
- Committed to AISDLC repo

## Depends on
- S2 (board must exist before IDs can be captured)
