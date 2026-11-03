# S3: Record board IDs in `<project>-context/board-config.yml`

## What
Write the project board's IDs to `<project>-context/board-config.yml` so agents can move tickets via `gh` CLI without rediscovering IDs each session. Same shape as the framework's own `.claude/board-config.yml` (which holds only the framework board).

## Why
Without this, every agent that needs to move a ticket has to query the GitHub API for field/option IDs. Caching them in config eliminates 4+ discovery calls per session.

## Steps
1. Create `<project>-context/board-config.yml` (copy the shape of `.claude/board-config.yml` in the workspace (the AISDLC clone)) with a `board:` block:
   - `name`, `url` (`https://github.com/users/<login>/projects/<N>` or `https://github.com/orgs/<org>/projects/<N>`), `project_number`, `project_id`
   - `status_field_id` + all 12 `status_options` (`backlog`, `frd_draft`, `frd_tech_plan`, ... `hotfix`)
   - `priority_field_id` + option IDs
   - `owner_field_id` + option IDs
   - `scope_field_id` + option IDs
   - `repo:` — the `<owner>/<repo>` where this project's tickets are filed
2. IDs come from `gh project field-list <N> --owner <owner> --format json`
3. Point each stack file's `board_config:` at this file
4. Commit and push the context repo

## Idempotent check
```bash
grep -qE "^[[:space:]]*status_field_id:[[:space:]]*PVTSSF_" "$CONTEXT_DIR/board-config.yml" 2>/dev/null && grep -qE "^[[:space:]]*backlog:[[:space:]]*[0-9a-f]+" "$CONTEXT_DIR/board-config.yml"
```

## Acceptance
- `board-config.yml` exists in the context repo with every ID above
- All option IDs correct (verified by moving a test ticket and moving it back)
- Committed to the context repo

## Depends on
- S1 (context repo exists)
- S2 (board must exist before IDs can be captured)
