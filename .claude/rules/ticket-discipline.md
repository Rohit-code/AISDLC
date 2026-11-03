# Ticket Discipline

Hard rules for how AI (and humans) manage tickets. Covers intake, blocker tracking, dual-channel status, and chat-to-ticket creation.

"The board" is the project board named by the stack file's `board_config`. If that file does not exist, do not invent IDs — stop and ask the user to run `/aisdlc-init`. ERP plan tickets are tracked in the owner's Google Sheet until then (`.claude/rules/erp-guardrails.md`).

These rules exist because three failure patterns kept recurring in client engagements:

- Dev work happened off the board; when clients asked "why is this slow?" there was no paper trail.
- Blockers lived in Slack threads and dev heads, never on the ticket. Product got blamed for delays they caused.
- AI status updates lived only in chat. Humans had to switch tabs constantly to understand state.

---

## Rule 1 — All feature work starts on the board

Every feature, fix, or change of >15 minutes of work must be a ticket on the project board **before any code is written**.

### Enforcement

- **AI**: refuses to start coding without a ticket. If no ticket exists and a dev describes work in chat, AI files one (see Rule 4).
- **Humans**: file a ticket, even a one-line one, before opening an editor. If it's quick enough to skip the board, it's quick enough to write a 30-second ticket.

### Exceptions (narrow, explicit)
- Read-only investigation (no code change, no state change).
- Fixing your own local environment (not committing anything).
- Hotfix lane — the ticket is created first (in 🚨 Hotfix), then the fix, then the FRD is written retroactively after (`.claude/rules/kanban-workflow.md`, Hotfix Flow).

---

## Rule 2 — Blocker tracking: typed labels, product tagging, timer pause

When work on a ticket is blocked by something outside the dev team — client input, credentials, 3rd-party API, design, data, spec clarification — the block must be logged on the ticket within the hour.

### Required actions when blocked

1. **Add a ticket comment** in this shape:

    ```
    **Blocked**: <type> — <one-line summary>.
    Waiting on: <who / which party>.
    Started: <YYYY-MM-DD>.
    ```

2. **Apply the blocker label** (see `docs/Board-Labels.md` for the full taxonomy):

    | Label | Use when |
    |---|---|
    | `blocker:client-input` | Waiting on client answer, decision, or approval |
    | `blocker:credentials` | Waiting on secret / API key / access |
    | `blocker:3rd-party` | Waiting on external vendor (provider API, webhook) |
    | `blocker:design` | Waiting on design spec or asset |
    | `blocker:data` | Waiting on seed data, migration data, or sample data |
    | `blocker:spec` | Spec is ambiguous, needs product clarification |

3. **Tag the responsible party** in the comment with `@<product-lead>` or the relevant owner. If responsibility is unclear, tag the triage lead.

4. **Pause the TAT timer** at the blocker. Until F24 data layer lands and automates this, note explicitly: `TAT paused at <date>`.

### Required actions when unblocked

1. Add a follow-up comment:

    ```
    **Unblocked** <YYYY-MM-DD>. Duration: <N> days. Resuming.
    ```

2. Remove the `blocker:*` label.
3. Resume ticket work.

### Why this matters
Three months from now, when someone asks why a feature slipped, the board answers. "Dev was slow" never wins an argument against "4 days waiting on the bank-connector API key, product was tagged on day 1."

---

## Rule 3 — Dual-channel status: ticket + chat, always

Every AI agent stage transition, decision, or blocker must be posted in **both** places:

1. **Ticket comment** (persistent audit trail).
2. **Chat reply summary** — one line, with the link.

### Chat-summary shape

```
#<ticket>: <action>. <link>.
```

### Examples

- `#45: Moved to Staging Ready. Tests green, staging deployed. https://.../pull/123`
- `#47: Blocked on SMTP credentials for invoice emails, tagged @tech-lead. https://.../issues/47#issuecomment-...`
- `#51: Filed. FRD drafted, pending triage. https://.../issues/51`

### Why this matters
Devs shouldn't have to switch tabs to understand AI state. If AI did something, the dev sees it in the chat *and* has the board as the source of truth. No gap.

### Enforcement
If an agent takes a board action without mirroring in chat (or vice versa), it's a framework violation. File a framework-gap ticket per `framework-observation.md` (F38).

---

## Rule 4 — Chat-to-ticket intake

When a dev describes a feature or a bug in chat with enough context, AI files the ticket. Dev does not have to open the board.

### Trigger

A chat message with:
- What the problem is or what the feature should do.
- Which surfaces it affects (BE, FE, context repo, infra).
- Any constraints (deadline, stakeholder, dependency).

### AI behavior

1. **If the description is clear enough**: draft the ticket using `templates/FRD-TEMPLATE.md`, file it on the project board (Backlog in team mode, FRD Draft in solo mode).
2. **If ambiguous on one point**: ask one clarifying question in chat. Only one. Then file.
3. **If ambiguous on multiple points**: file in Backlog with an `incomplete-spec` note, leave clarifying questions as ticket comments (not chat interruptions), ping triage.

### Reply shape

```
Filed as #<N> on <board-name>. <link>.
```

Optionally followed by any one-line caveat (e.g., "Moved to FRD Draft, `@planner` will draft the execution plan next.").

### Why this matters
Board admin friction is what makes teams hate SDLC frameworks. Removing it is a first-class feature.

---

## Interaction with other rules

- **Verification Gate** (`.claude/agents/builder.md`): dual-channel status (Rule 3) means the Verification Gate evidence is posted on the ticket *and* summarized in chat when the gate passes.
- **Solo / team mode** (`solo-vs-team-mode.md`): Rule 3's chat mirroring applies in both modes. Rule 4's intake destination (Backlog vs FRD Draft) differs by mode.
- **Size audit** (`size-audit.md`): tech-debt tickets auto-filed during audits must also mirror in chat per Rule 3.
- **Framework gap capture** (`framework-observation.md`, F38): same dual-channel discipline applies to framework-board filings — ticket comment + chat summary.

---

## Enforcement responsibility

| Agent | Responsibility |
|---|---|
| `@ticket-manager` | Enforces Rule 1 (no code without ticket) and Rule 2 (blocker labels applied) |
| `@planner` | Enforces Rule 4 (chat-to-ticket intake in its FRD-drafting mode) |
| All agents | Enforce Rule 3 (dual-channel status on every action they take) |

---

## Learned from

- Off-board fix sessions become invisible within a week.
- Blocker duration that is not on the ticket is invisible to product.
- Requirement (F33): make dual-channel status a hard rule, not a habit.
