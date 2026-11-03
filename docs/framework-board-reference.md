# Framework Board Reference

**Board**: AI SDLC Pipeline
**URL**: https://github.com/orgs/<owner>/projects/<project-number>
**Purpose**: Tracks framework improvements, learnings, and meta-work on AISDLC itself. Framework dogfoods its own SDLC here.

## IDs for automation

```
Project ID:       <project-id>
Status Field ID:  <status-field-id>
```

## Column (Status) option IDs

| # | Column | Option ID |
|---|--------|-----------|
| 0 | 📥 Backlog | `<option-id>` |
| 1 | 📝 FRD Draft | `<option-id>` |
| 2 | 🤖 FRD Tech Plan Review | `<option-id>` |
| 3 | 🔧 Tech Plan Approved | `<option-id>` |
| 4 | 💻 AI Development | `<option-id>` |
| 5 | 👀 Code Review | `<option-id>` |
| 6 | 🧪 Staging Ready | `<option-id>` |
| 7 | 🎭 Staging Review | `<option-id>` |
| 8 | 🔄 Rework | `<option-id>` |
| 9 | 🚀 Ready for Production | `<option-id>` |
| 10 | ✅ Done | `<option-id>` |
| 11 | 🚨 Hotfix | `<option-id>` |

Note: this board labels column 2 as "🤖 FRD Tech Plan Review" while project boards use "🤖 FRD Tech Plan". Same column semantically — the framework board is slightly older and uses the original naming. Treat them as equivalent.

## GraphQL snippets

### Add a draft issue to the board

```graphql
mutation {
  addProjectV2DraftIssue(input: {
    projectId: "<project-id>"
    title: "F99: Short title"
    body: "Ticket body in markdown..."
  }) {
    projectItem { id }
  }
}
```

### Move an item to a column

```graphql
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "<project-id>"
    itemId: "<item_id_from_add>"
    fieldId: "<status-field-id>"
    value: { singleSelectOptionId: "<option_id_from_table_above>" }
  }) {
    projectV2Item { id }
  }
}
```

### List all items with their current status

```graphql
{
  organization(login: "<owner>") {
    projectV2(number: <project-number>) {
      items(first: 100) {
        nodes {
          id
          content {
            ... on DraftIssue { title }
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

## Ticket naming convention

Framework tickets are prefixed with `F` (F1, F2, F3, ...). The number is monotonic across the framework's lifetime and does NOT reset per version. Keep a running count here and update as new tickets are filed.

**Next F number**: <update when filing>
