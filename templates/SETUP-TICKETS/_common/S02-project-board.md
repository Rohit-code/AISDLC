# S2: Create project board with 12-column AISDLC pipeline

## What
Create a new GitHub Projects v2 board for this project with the standard 12-column AISDLC pipeline plus Priority, Owner, and Scope fields.

## Why
The board is the single source of truth for ticket state. Every project needs its own board so work doesn't mix across clients.

## Steps
1. Create project board via `gh project create --owner <owner> --title "<Project> - AI SDLC Pipeline"` (`<owner>` is a user login, e.g. `Rohit-code`, or an org)
2. Add Status field with 12 columns: 📥 Backlog, 📝 FRD Draft, 🤖 FRD Tech Plan, 🔧 Tech Plan Approved, 💻 AI Development, 👀 Code Review, 🧪 Staging Ready, 🎭 Staging Review, 🔄 Rework, 🚀 Ready for Production, ✅ Done, 🚨 Hotfix
3. Add Priority field: 🔴 P0, 🟠 P1, 🟡 P2, 🟢 P3
4. Add Owner field: 🧑‍💼 Product, 🔧 Tech, 🤖 AI
5. Add Scope field (stack-specific options — e.g. Backend, Frontend, Infra, Voice)
6. Capture `project_id`, `status_field_id`, and all option IDs for S3: `gh project field-list <N> --owner <owner> --format json`

## Idempotent check
```bash
# Fails until board.project_id is in $CONTEXT_DIR/board-config.yml
test -n "$BOARD_ID"
```

## Acceptance
- Board exists at `https://github.com/users/<login>/projects/<N>` (user-owned) or `https://github.com/orgs/<org>/projects/<N>` (org-owned)
- All 12 status columns present, names exactly as in step 2 (same list as `.claude/rules/kanban-workflow.md`)
- Priority, Owner, Scope fields present
- IDs captured for next ticket (S3)
