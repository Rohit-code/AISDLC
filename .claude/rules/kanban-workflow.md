# Kanban Workflow Rules

This file is the single source for the column table and for who may move a ticket where. Other files link here.

Board IDs: the framework board is `.claude/board-config.yml`; a project board is the file named by the stack file's `board_config` (ERP: `erp-context/board-config.yml`). If that file does not exist, do not invent IDs — stop and ask the user to run `/aisdlc-init` (setup tickets S2/S3 create it). ERP plan tickets are tracked in the owner's Google Sheet until the owner sets up the board (`.claude/rules/erp-guardrails.md`).

## The 12-Column Pipeline

| # | Column | Owner | AI Active? | Exits to (normal path) |
|---|--------|-------|-----------|------------------------|
| 0 | 📥 Backlog | Team | NO | 📝 FRD Draft (triage lead) or closed |
| 1 | 📝 FRD Draft | Product | ASSIST ONLY | 🤖 FRD Tech Plan |
| 2 | 🤖 FRD Tech Plan | AI | YES | 🔧 Tech Plan Approved (or back to 📝 FRD Draft with questions) |
| 3 | 🔧 Tech Plan Approved | Tech | NO | 💻 AI Development |
| 4 | 💻 AI Development | AI | YES | 👀 Code Review |
| 5 | 👀 Code Review | Tech | NO | 🧪 Staging Ready (or 🚀 Ready for Production when `staging: none`), or 🔄 Rework when changes are requested |
| 6 | 🧪 Staging Ready | AI | YES | 🎭 Staging Review |
| 7 | 🎭 Staging Review | Product | NO | 🚀 Ready for Production or 🔄 Rework |
| 8 | 🔄 Rework | AI | YES | 🎭 Staging Review or 👀 Code Review |
| 9 | 🚀 Ready for Production | Tech | NO | ✅ Done |
| 10 | ✅ Done | — | NO | — |
| 11 | 🚨 Hotfix | Tech/AI | YES | 👀 Code Review |

AI-active columns: 🤖 FRD Tech Plan, 💻 AI Development, 🧪 Staging Ready, 🔄 Rework, 🚨 Hotfix.

## Transition matrix

Mode comes from `framework.mode` in the stack file (`.claude/stack-be.yml` / `.claude/stack-fe.yml`); default team. Autonomous mode is a per-session grant in team mode (see below) and follows the solo/autonomous column.

| Move | Team mode | Solo or autonomous mode |
|------|-----------|-------------------------|
| create in 📥 Backlog | anyone (AI files chat-described work here) | AI may file in 📝 FRD Draft directly |
| 📥 Backlog → 📝 FRD Draft | triage lead | triage lead or AI |
| 📝 FRD Draft → 🤖 FRD Tech Plan | Product | Product or AI |
| 🤖 FRD Tech Plan → 📝 FRD Draft (blocking questions) | AI | AI |
| 🤖 FRD Tech Plan → 🔧 Tech Plan Approved | AI, after posting the plan and the contract | AI, after posting the plan and the contract |
| 🔧 Tech Plan Approved → 💻 AI Development | Tech (contract gate must pass) | Tech or AI (contract gate must pass) |
| 💻 AI Development → 👀 Code Review | AI (Verification Gate) | AI (Verification Gate) |
| 👀 Code Review → 🔄 Rework (changes requested; valid with `staging: none`) | Tech | Tech |
| 👀 Code Review → 🧪 Staging Ready | Tech | Tech or AI |
| 👀 Code Review → 🚀 Ready for Production (`staging: none` only) | Tech | Tech — **human only** |
| 🧪 Staging Ready → 🎭 Staging Review | AI (`@shipper`, staging URL posted) | AI |
| 🎭 Staging Review → 🔄 Rework | Product | Product or AI |
| 🎭 Staging Review → 🚀 Ready for Production | Product | Product — **human only** |
| 🔄 Rework → 👀 Code Review (valid with `staging: none`) / 🎭 Staging Review | AI | AI |
| 🚀 Ready for Production → ✅ Done | Tech, after merge (+ deploy) | Tech — **human only** |
| create in / → 🚨 Hotfix | Tech | Tech |
| 🚨 Hotfix → 👀 Code Review | AI (`@shipper`, Verification Gate) | AI |
| 👀 Code Review → 🚀 Ready for Production (hotfix) | Tech — **human only** | Tech — **human only** |

In plain words:
- **Team mode**: only humans move a ticket INTO an AI-active column. AI may move a ticket OUT of an AI-active column into the next human column — that is the handoff ("I'm done, your turn").
- **Solo / autonomous mode**: AI may also move tickets INTO AI-active columns and log each move as a ticket comment: *"Moved to <column> under <solo|autonomous> mode on <date>"*.
- **Every mode**: AI NEVER moves a ticket into 🚀 Ready for Production or ✅ Done, and never skips 🧪 Staging Ready / 🎭 Staging Review. Only the `staging: none` rule below lets a human skip them.

## `staging: none`

If the stack file says `staging: none` (ERP does), there is no staging deploy. A human moves 👀 Code Review → 🚀 Ready for Production directly; 🧪 Staging Ready and 🎭 Staging Review are skipped by that human move, never by AI. `@shipper` owns 🧪 Staging Ready only when the stack file defines staging.

## ✅ Done

Done = the PR is merged into its base (`pr_base` in the stack file — the default branch, or the ticket's stream branch such as ERP `plan/<stream>`) and deployed (or merged, when the project has no deploy step). Integrating stream branches into the default branch (ERP wave merges) is a separate human step. Merging is a human action (`.claude/rules/source-control.md`), so Done is always set by a human.

## Dependencies

A ticket declares dependencies with one line in its body: `Depends on: #N` (several: `Depends on: #12, #15`). It may start once each dependency's PR is merged — not when it reaches staging. Check command: `.claude/rules/gh-recipes.md` ("Check a dependency is merged").

## 📥 Backlog — the team-entry column

- **Any team member** (engineer, PM, designer, stakeholder) creates tickets in 📥 Backlog. That is the only column a non-triage team member touches; they don't write execution plans or move tickets into AI columns.
- A Backlog ticket is a **problem statement or idea**, not a plan. Minimum fields: title, problem, desired outcome, affected area (BE / FE / infra / framework). No tech design or acceptance criteria — those come in 📝 FRD Draft.
- The **triage lead** reviews Backlog on a cadence and decides what moves forward. Backlog → 📝 FRD Draft means *"this is real work we want to plan"*.
- Tickets can be **closed from Backlog** (duplicates, out of scope, won't do). Backlog has no SLA and no order. Team members cannot self-promote out of Backlog.

At team scale Backlog is the barrier between raw ideas and the AI pipeline: ticket creation is async, triage is batched, and non-technical people can describe problems without knowing the downstream columns.

## Autonomous mode (explicit delegation)

The user can relax team-mode rules for a session by saying so in chat ("you can move cards and work yourself", "go autonomous on this batch"). Moves then follow the solo/autonomous column of the matrix. Autonomous mode ends when the user says so, the session ends, or AI hits a blocking question. It never relaxes the Verification Gate, protected branches, the human-only moves above, or hard stops (scope discrepancy, security, destructive ops). Details: `.claude/rules/solo-vs-team-mode.md`.

## Verification Gate

No ticket moves to 👀 Code Review without pasted verification output or a "cannot verify — blocked by #X" comment. Full text: `.claude/agents/builder.md`, section "Verification Gate".

## Required Documents Per Transition

| Transition | Required Before Moving |
|-----------|----------------------|
| → 🤖 FRD Tech Plan | FRD on the ticket |
| → 🔧 Tech Plan Approved | Execution plan posted on the ticket |
| → 💻 AI Development | Tech DO's/DON'T's posted (may be "no constraints"); for BE+FE features the `[Contract]` sub-issue is approved by BE and FE and closed (`.claude/rules/contract-driven-flow.md`) |
| → 👀 Code Review | PR(s) linked, verification output and test results posted |
| → 🧪 Staging Ready | PR(s) approved |
| → 🎭 Staging Review | Staging URL, smoke-test results, production checklist |
| → 🔄 Rework | Review comments saying what must change |
| → 🚀 Ready for Production | Product approval comment, or (with `staging: none`) Tech's code-review approval; production checklist on the ticket (`templates/PRODUCTION-CHECKLIST-TEMPLATE.md`), written by `@shipper` — or by `@builder` when there is no shipper step |
| → ✅ Done | PR merged into its `pr_base` (default branch or stream branch), deploy confirmed (if the project deploys) — human only |

## Hotfix Flow

Bypasses stages 1-5 for production emergencies. Owned by `@shipper`.

One rule everywhere: **ticket first, fix, FRD after.**

1. Tech creates the issue first, with label `hotfix`, directly in 🚨 Hotfix (no FRD yet).
2. AI branches `hotfix/<id>-<slug>` from the default branch, builds and verifies the fix, opens a PR to the default branch (`.claude/rules/source-control.md`), and moves the ticket to 👀 Code Review.
3. A human reviews and moves 👀 Code Review → 🚀 Ready for Production, merges, and moves the ticket to ✅ Done.
4. After the merge AI writes the FRD retroactively on the ticket and posts a back-port note. Back-port = re-apply the fix onto the open feature branches and stream branches (e.g. ERP `plan/*`) that need it, each through its own PR.

## Stale Ticket Thresholds

- \>2 days in Code Review → ping reviewer
- \>3 days in any column → ping owner
- \>5 days → escalate to team lead

## Labels

Workflow: `frd-review`, `frd-approved`, `ai-blocked`, `needs-discussion`. Scope: `scope:be`, `scope:fe`, `scope:fe-mobile`, `scope:infra`, `scope:framework`. Priority: `p0-critical`, `p1-high`, `p2-medium`, `p3-low`. Special: `hotfix`, `security-review`. Full taxonomy: `docs/Board-Labels.md`.
