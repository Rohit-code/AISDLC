# Framework Board Reference

**Board**: AI SDLC Pipeline
**URL**: https://github.com/users/Rohit-code/projects/2
**Purpose**: Tracks framework improvements, learnings, and meta-work on AISDLC itself. Framework dogfoods its own SDLC here.

## IDs for automation

```
Project ID:       PVT_kwHOAy3qVs4BqCgb
Status Field ID:  PVTSSF_lAHOAy3qVs4BqCgbzhobWqk
```

## Column (Status) option IDs

| # | Column | Option ID |
|---|--------|-----------|
| 0 | 📥 Backlog | `24c75ca4` |
| 1 | 📝 FRD Draft | `8c837498` |
| 2 | 🤖 FRD Tech Plan Review | `63a0b10f` |
| 3 | 🔧 Tech Plan Approved | `c2c8461e` |
| 4 | 💻 AI Development | `9016f692` |
| 5 | 👀 Code Review | `b35efeea` |
| 6 | 🧪 Staging Ready | `9042d52e` |
| 7 | 🎭 Staging Review | `61a830eb` |
| 8 | 🔄 Rework | `ec2363f8` |
| 9 | 🚀 Ready for Production | `4bdda5f6` |
| 10 | ✅ Done | `5a0a2d19` |
| 11 | 🚨 Hotfix | `7762c251` |

Note: this board labels column 2 as "🤖 FRD Tech Plan Review" while project boards use "🤖 FRD Tech Plan". Same column semantically — the framework board is slightly older and uses the original naming. Treat them as equivalent.

## GraphQL snippets

### Add a draft issue to the board

```graphql
mutation {
  addProjectV2DraftIssue(input: {
    projectId: "PVT_kwHOAy3qVs4BqCgb"
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
    projectId: "PVT_kwHOAy3qVs4BqCgb"
    itemId: "<item_id_from_add>"
    fieldId: "PVTSSF_lAHOAy3qVs4BqCgbzhobWqk"
    value: { singleSelectOptionId: "<option_id_from_table_above>" }
  }) {
    projectV2Item { id }
  }
}
```

### List all items with their current status

```graphql
{
  user(login: "Rohit-code") {
    projectV2(number: 2) {
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
