# FRD: [Feature Name]

**PRD**: [link to PRD wiki page] | **Status**: Draft / Approved / In Progress / Complete
**Written by**: Product | **AI Assisted**: Yes/No

---

## Problem + User Story
[What are we solving? In user terms — who hits this and what do they experience today?]

## Scope
- [ ] Backend (`<project>-be`)
- [ ] Frontend (`<project>-fe`) — add one line per extra FE repo (`<project>-<fe-repo>`)
- [ ] Infrastructure

## Out-of-Scope (required — prevents scope creep)
[What this feature explicitly does NOT include. Every FRD must list at least one thing out-of-scope.]
- [Out-of-scope item 1]
- [Out-of-scope item 2]

## What We're Building
[Clear description of the feature from Product's perspective. What does the user see/do?]

## Functional Requirements
- [ ] [Requirement 1: specific and testable]
- [ ] [Requirement 2]

## Affected Surfaces (required — used for sub-issue planning per F40)

### BE endpoints (new / changed)
- [ ] `[METHOD] /path/to/endpoint` — short description (new / changed / deprecated)

### FE screens / flows (new / changed)
- [ ] `[Screen name / route]` — short description (in which FE repo)

### DB models / migrations
- [ ] New model: [ModelName] / Changed fields: [Model.field] / Destructive migration? Y/N

### External integrations (new / changed)
- [ ] [Service name] — what changes in the integration

## UI/UX Requirements
[Figma links, flow descriptions, or text descriptions of the expected UI]

## Async / Background Processing
[Any tasks that should happen in the background? Notifications? Syncs?]

## Non-Functional Requirements
[Performance, security, scale considerations]

## Migration / Gap Callouts (required — populated by `@planner` at Tech Plan)

Populate every applicable row. If a row doesn't apply, write "N/A" — don't leave blank. If a row is an unknown at FRD time, write "UNKNOWN — asking Product" and post a ticket comment to resolve it before 🤖 FRD Tech Plan exits.

| Callout | Answer |
|---|---|
| Data migrations (backfills, one-off scripts) | |
| Schema migrations — expand/contract pattern applicable? (per F29) | |
| New env vars / secrets to add (and how staging/prod get them) | |
| Feature flags — is this gated? Who owns flag lifecycle? | |
| Rollout plan (all at once / gradual / shadow deploy) | |
| Rollback plan (how do we undo if this breaks) | |

## Architecture Impact (filled by `@planner` at Tech Plan per F44 — once shipped)

`arch-impact:none | low | medium | high` (label applied on the parent ticket).

For `medium` / `high`: `@planner` posts a separate **Architecture Note** comment covering structural changes, new patterns, risks, and decoupling options. Tech lead review required before 🔧 Tech Plan Approved.

## Acceptance Criteria
[How will Product test this on staging?]
- [ ] [Criterion 1: "Given X, when Y, then Z"]
- [ ] [Criterion 2]

## Open Questions
- [ ] [Question 1]
- [ ] [Question 2]

---

## Contract-driven flow checklist (per F40)

Before moving this ticket out of 🤖 FRD Tech Plan, `@planner` confirms:

- [ ] Three sub-issues created and linked: `[Contract] <feature>`, `[BE] <feature>`, `[FE] <feature>` (or the relevant subset if feature is BE-only or FE-only).
- [ ] API contract drafted at `<project>-context/contracts/<feature>.yaml`.
- [ ] Both BE and FE approval comments present on the `[Contract]` sub-issue. In solo mode, one human approves with both lenses.
- [ ] Migration / gap callouts section populated above (no blank rows).
- [ ] Architecture impact label applied (once F44 ships).

Only after this checklist clears does the parent ticket move to 🔧 Tech Plan Approved.
