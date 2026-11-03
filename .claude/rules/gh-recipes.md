# gh / GraphQL recipes

How-to commands for issues, boards and sub-issues. The protocol (when to create what, comment formats) lives in `.claude/rules/agent-communication.md`; branch and PR rules live in `.claude/rules/source-control.md`.

Use plain `gh`. Board IDs (project number, project ID, field IDs, option IDs) come from a board config file — never rediscover them by hand each session:

- Framework board: `.claude/board-config.yml` — user-owned, `--owner Rohit-code`, project number 2, https://github.com/users/Rohit-code/projects/2. Framework tickets are real issues in `Rohit-code/AISDLC`.
- Project boards: the project's own `board-config.yml` (path in the stack file's `board_config`, e.g. `erp-context/board-config.yml`). If that file does not exist, do not invent IDs — stop and ask the user to run `/aisdlc-init` (setup tickets S2/S3 create it).

`<owner>` below is a user login or an organization. Board URLs are `https://github.com/users/<owner>/projects/<n>` for a user and `https://github.com/orgs/<owner>/projects/<n>` for an org; GraphQL uses `user(login: ...)` or `organization(login: ...)` to match.

## Issues

```bash
gh issue list   --repo <owner>/<repo>
gh issue view   <number> --repo <owner>/<repo>
gh issue create --repo <owner>/<repo> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
gh issue comment <number> --repo <owner>/<repo> --body "<comment>"
```

## Check a dependency is merged

A ticket lists dependencies as one line in its body: `Depends on: #N` (several: `Depends on: #12, #15`). Before starting, check each one:

```bash
# merged PRs that mention the dependency in their body
gh pr list --repo <owner>/<repo> --state merged --search "#<N> in:body" --json number,title,mergedAt
# or: the PRs that closed the dependency issue
gh issue view <N> --repo <owner>/<repo> --json state,closedByPullRequestsReferences
```

No merged PR → the dependency is not met; comment on the ticket and wait.

## Add an issue to a board

```bash
gh project item-add <project-number> --owner <owner> --url https://github.com/<owner>/<repo>/issues/<number>
# framework board:
gh project item-add 2 --owner Rohit-code --url https://github.com/Rohit-code/AISDLC/issues/<number>
```

## Get item IDs

```bash
gh project item-list <project-number> --owner <owner> --format json --limit 200
# framework board, item ID for issue #57:
gh project item-list 2 --owner Rohit-code --format json --limit 200 \
  --jq '.items[] | select(.content.number == 57) | .id'
```

## Set Status / Priority

`project_id`, `status_field_id`, `priority_field_id` and the option IDs come from the board config.

```bash
gh project item-edit \
  --project-id <project_id> \
  --id <item_id> \
  --field-id <status_field_id> \
  --single-select-option-id <status_options.code_review>

gh project item-edit \
  --project-id <project_id> \
  --id <item_id> \
  --field-id <priority_field_id> \
  --single-select-option-id <priority_options.p2>
```

Who may move a ticket into which column: `.claude/rules/kanban-workflow.md`.

## Read the board via GraphQL

```bash
# user-owned board (framework board)
gh api graphql -f query='
query {
  user(login: "Rohit-code") {
    projectV2(number: 2) {
      id
      fields(first: 30) { nodes { ... on ProjectV2SingleSelectField { id name options { id name } } } }
    }
  }
}'
# org-owned board: replace user(login: ...) with organization(login: "<org>")
```

## Link sub-issues (parent + children)

Sub-issues work only between **real issues**, not draft items.

```bash
# 1. node IDs of parent and child
gh api graphql -f query='
query {
  repository(owner: "<owner>", name: "<repo>") {
    parent: issue(number: <parent-number>) { id }
    child:  issue(number: <child-number>)  { id }
  }
}'

# 2. link child to parent
gh api graphql -f query='
mutation {
  addSubIssue(input: { issueId: "<parent-issue-id>", subIssueId: "<child-issue-id>" }) {
    subIssue { number title }
  }
}'
```

## Convert a draft item into a real issue

```bash
gh api graphql -f query='
mutation {
  convertProjectV2DraftIssueItemToIssue(input: {
    itemId: "<project-item-id>",
    repositoryId: "<repo-node-id>"
  }) {
    item { content { ... on Issue { id number } } }
  }
}'
```

The project item keeps its board position and Status. Get `<repo-node-id>` with `gh api graphql -f query='query { repository(owner: "<owner>", name: "<repo>") { id } }'`.
