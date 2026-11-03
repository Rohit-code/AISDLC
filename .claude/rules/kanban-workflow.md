# Kanban Workflow Rules

## The 12-Column Pipeline

| # | Column | Owner | Enters By | Exits By | AI Active? |
|---|--------|-------|-----------|----------|-----------|
| 0 | 📥 Backlog | Team | Any team member creates a ticket | Triage lead moves to FRD Draft | NO |
| 1 | 📝 FRD Draft | Product | Triage lead moves from Backlog | Product moves | ASSIST ONLY |
| 2 | 🤖 FRD Tech Plan | AI | Product moves | AI moves | YES |
| 3 | 🔧 Tech Plan Approved | Tech | AI moves | Tech moves | NO |
| 4 | 💻 AI Development | AI | Tech moves | AI moves | YES |
| 5 | 👀 Code Review | Tech | AI moves | Tech moves | NO |
| 6 | 🧪 Staging Ready | AI | Tech moves | AI moves | YES |
| 7 | 🎭 Staging Review | Product | AI moves | Product moves | NO |
| 8 | 🔄 Rework | AI | Product moves | AI moves | YES |
| 9 | 🚀 Ready for Production | Tech | Product moves | Tech moves | NO |
| 10 | ✅ Done | — | Tech moves | — | NO |
| 11 | 🚨 Hotfix | Tech/AI | Tech creates | Tech moves | YES |

## 📥 Backlog — the team-entry column

The Backlog is where **any team member** (engineer, PM, designer, stakeholder) creates a ticket. It's the only column a non-triage team member ever touches. The rules are:

- **Team members create tickets in 📥 Backlog. That's it.** They don't write execution plans, don't move tickets into AI columns, don't touch code through the framework.
- A ticket in Backlog is a **problem statement or idea**, not a plan. Minimum fields: title, problem, desired outcome, affected area (BE / FE / infra / framework). No tech design, no acceptance criteria — those come later in 📝 FRD Draft.
- The **triage lead** (typically the CTO / eng lead / whoever owns the pipeline for that project) reviews Backlog on a cadence (daily or every few days) and decides what moves forward. Moving a ticket from 📥 Backlog → 📝 FRD Draft means *"this is real work we want to plan"*.
- Tickets can also be **closed from Backlog** without ever entering the pipeline — duplicates, out-of-scope requests, won't-do items.
- Backlog has **no SLA** and is **not ordered**. Ordering happens when triage lifts a ticket into FRD Draft.
- Team members **cannot** self-promote a ticket out of Backlog. Only the triage lead moves tickets out.

### Why Backlog exists (the team-scale reason)

When the framework runs in a single-person context, Backlog is overhead. When it runs at 10+ engineers, Backlog is the **protective barrier** between the team's raw thoughts and the AI pipeline. Without it, the triage lead gets interrupted constantly; with it, ticket creation is async and triage is batched.

This is also where non-technical team members can participate safely — they can describe problems without understanding the downstream columns.

## Operating mode determines ticket movement rules

The rules in this section apply in **team mode** (the default). In **solo mode**, AI moves tickets in both directions autonomously and logs each move as a comment. See `.claude/rules/solo-vs-team-mode.md` for the full mode rules. The Verification Gate, Size Audit, and hard-stop rules below apply in BOTH modes.

## Ticket Movement = Permission (team mode)

**AI CANNOT move a ticket INTO an AI-active column.** Only HUMANS give AI permission to work by moving tickets into AI columns.

**AI CAN move a ticket OUT of an AI-active column** into a human-review column. This is the handoff — "I'm done, your turn."

### Invalid AI Moves (NEVER do these)
- Anything → Tech Plan Approved (only Tech)
- Anything → AI Development (only Tech)
- Anything → Staging Review or Ready for Production (only Product)
- Anything → Done (only Tech)

### Valid AI Moves
- FRD Tech Plan → FRD Draft (blocking questions — move back and assign to the person who moved it here)
- AI Development → Code Review (code done, PR ready)
- Staging Ready → Staging Review (staging deployed)
- Rework → Staging Review (rework applied)
- Rework → Code Review (significant rework needs re-review)

**Note**: AI does NOT move tickets from FRD Tech Plan → Tech Plan Approved. AI posts the execution plan and waits. Tech team reviews and moves it themselves.

## Autonomous Mode (explicit delegation)

The rules above are the default. The user can temporarily relax them by explicitly saying so in chat — "you can move cards and work yourself", "go autonomous on this batch", etc.

When autonomous mode is active:
- AI can move cards into AI-active columns (to pick up the next ticket itself)
- AI can move cards from Code Review → Ready for Production after merging to a release branch (never master)
- AI must log each autonomous move as a comment on the ticket: *"Moved to <column> under autonomous mode granted by @user on <date>"*
- AI **cannot** move tickets to ✅ Done — only a human marks Done, because Done means "merged to master and deployed"
- AI **cannot** skip the Verification Gate (see below) — autonomous mode makes AI faster, not less rigorous
- Scope creep, security issues, and destructive ops still require a blocking question

Autonomous mode ends when: the user says so, the session ends, or AI hits a blocking question.

## Verification Gate (hard rule)

No ticket moves to 👀 Code Review without one of:
- **(a)** Pasted command output proving the change works (test run, curl response, migration output, etc.)
- **(b)** Explicit "cannot verify — blocked by #X" comment naming the blocker

Unverified handoffs silently accumulate bugs. This rule applies in both default and autonomous mode.

## Required Documents Per Transition

| Transition | Required Before Moving |
|-----------|----------------------|
| → FRD Tech Plan | FRD must exist on the ticket |
| → Tech Plan Approved | Execution plan posted on ticket |
| → AI Development | Tech DO's/DON'T's posted (can be empty = "no constraints") |
| → Code Review | PR(s) linked to ticket, **verification output posted** (see Verification Gate), test results posted |
| → Staging Ready | PR(s) approved |
| → Staging Review | Staging URL posted, smoke test results, production checklist |
| → Ready for Production | Product approval comment **OR** (autonomous mode) merged to release branch |
| → Done | Release branch merged to master, deployment confirmed — HUMAN ONLY |

## Hotfix Flow

Bypasses stages 1-5 for production emergencies.

1. Tech creates issue with label `hotfix`
2. Ticket goes directly to 💻 AI Development
3. AI builds fix → 👀 Code Review → 🚀 Ready for Production → ✅ Done
4. AI creates retroactive PRD/FRD docs AFTER fix is live

## Stale Ticket Thresholds

- \>2 days in Code Review → ping reviewer
- \>3 days in any column → ping owner
- \>5 days → escalate to team lead

## Labels

### Workflow
- `frd-review` — FRD needs review
- `frd-approved` — FRD approved
- `ai-blocked` — AI needs clarification (waiting for human)
- `needs-discussion` — Product and Tech disagree, need sync

### Scope
- `scope:be`, `scope:fe`, `scope:fe-mobile`, `scope:infra`, `scope:framework`

### Priority
- `p0-critical` — Production down
- `p1-high` — Major feature / important bug
- `p2-medium` — Standard feature
- `p3-low` — Nice to have

### Special
- `hotfix` — Emergency fix, bypasses pipeline
- `security-review` — Needs security review before development
