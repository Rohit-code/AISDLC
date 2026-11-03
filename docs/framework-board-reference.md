# Framework Board Reference

**Board**: AI SDLC Pipeline (user-owned by `Rohit-code`, project number 2)
**URL**: https://github.com/users/Rohit-code/projects/2
**Purpose**: Tracks framework improvements, learnings, and meta-work on AISDLC itself. Framework dogfoods its own SDLC here (solo mode).

## IDs for automation

All IDs (project, Status field, the 12 column option IDs, Priority options) live in **`.claude/board-config.yml`**. Read them from there; do not copy them into other files.

Columns, in order: `📥 Backlog`, `📝 FRD Draft`, `🤖 FRD Tech Plan`, `🔧 Tech Plan Approved`, `💻 AI Development`, `👀 Code Review`, `🧪 Staging Ready`, `🎭 Staging Review`, `🔄 Rework`, `🚀 Ready for Production`, `✅ Done`, `🚨 Hotfix`. Who may move a ticket between them: `.claude/rules/kanban-workflow.md`.

General gh / GraphQL recipes: `.claude/rules/gh-recipes.md`. The snippets below are the framework-board versions.

## File a framework ticket

Framework tickets are real issues in `Rohit-code/AISDLC` added to the board (not draft issues), so they can have sub-issues.

```bash
URL=$(gh issue create --repo Rohit-code/AISDLC --title "F99: Short title" --body-file body.md)
ITEM_ID=$(gh project item-add 2 --owner Rohit-code --url "$URL" --format json --jq .id)
```

For a one-line framework gap hit during project work, use `bin/aisdlc-observe.sh` instead (it files into Backlog):

```bash
bin/aisdlc-observe.sh --type rule --project erp --ticket 45 --summary "size-audit silent on background-job modules"
```

## Move an item to a column

```bash
gh project item-edit --project-id <board.project_id> --id "$ITEM_ID" \
  --field-id <board.status_field_id> --single-select-option-id <board.status_options.<column>>
```

Item IDs come from `gh project item-list 2 --owner Rohit-code --format json`.

## List all items with their current status

```graphql
{
  user(login: "Rohit-code") {
    projectV2(number: 2) {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue { number title state }
          }
          fieldValues(first: 10) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
                field { ... on ProjectV2SingleSelectField { name } }
              }
            }
          }
        }
      }
    }
  }
}
```

Run with `gh api graphql -f query='<query above>'`.

## Ticket naming convention

Framework tickets are prefixed with `F` (F1, F2, F3, ...). The number is monotonic across the framework's lifetime and does NOT reset per version. Find the highest used number with `gh issue list --repo Rohit-code/AISDLC --state all --limit 200 --json title --jq '.[].title' | grep -oE '^F[0-9]+' | sort -t F -k 2 -n | tail -n 1`.
