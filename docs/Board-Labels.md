# Board Labels — Taxonomy

Canonical label set AISDLC projects use on their boards. Labels serve three purposes: filterability, reporting, and (for blockers) TAT pause signaling.

Project boards add these when set up. `@ticket-manager` applies them; agents read them.

---

## Scope labels

Tells downstream tooling / reports which surface the ticket affects.

| Label | Meaning |
|---|---|
| `scope:be` | Backend work |
| `scope:fe` | Frontend work (projects with several FE apps add `scope:fe-<app>` per app) |
| `scope:fe-mobile` | Mobile frontend |
| `scope:infra` | Infrastructure / deploy / CI |
| `scope:framework` | Framework-level change (only on AISDLC board) |

Projects add their own `scope:*` labels as needed (e.g. `scope:voice-pipeline`).

---

## Priority labels

| Label | Meaning |
|---|---|
| `p0-critical` | Production down, security incident, client blocker |
| `p1-high` | Near-term feature, important bug |
| `p2-medium` | Normal feature work |
| `p3-low` | Nice-to-have, later |

---

## Blocker labels

Applied per `ticket-discipline.md` Rule 2 when work is blocked on something outside the dev team. Presence of any `blocker:*` label pauses TAT measurement on the ticket.

| Label | Use when |
|---|---|
| `blocker:client-input` | Waiting on client answer, decision, or approval |
| `blocker:credentials` | Waiting on secret / API key / access grant |
| `blocker:3rd-party` | Waiting on external vendor (provider API, webhook registration, service signup) |
| `blocker:design` | Waiting on design spec, mockup, or asset |
| `blocker:data` | Waiting on seed data, migration data, or sample data |
| `blocker:spec` | Spec ambiguous, needs product clarification |
| `blocker:review` | Waiting on human PR review (team mode; solo mode should not use this) |
| `blocker:legal` | Waiting on legal, compliance, or contract clarification |
| `blocker:billing` | Blocked by account tier, billing issue, or budget approval |

### Blocker label lifecycle

1. Agent or human applies label when blocked.
2. Ticket comment logs the block with type, owner tagged, and start date.
3. TAT timer pauses.
4. When unblocked: remove label, log resumption comment, TAT resumes.

---

## Workflow labels

Used by the kanban workflow (`.claude/rules/kanban-workflow.md`) and the agents.

| Label | Meaning |
|---|---|
| `frd-review` | FRD written; Product / Tech are reviewing it in 📝 FRD Draft |
| `frd-approved` | FRD reviewed and accepted; ready to move into 🤖 FRD Tech Plan |
| `ai-blocked` | AI cannot continue: blocking question posted, or a `Depends on: #N` PR is not merged yet. Removed when unblocked |
| `needs-discussion` | A disagreement or open question needs a live sync; the ticket waits for the outcome comment |
| `hotfix` | Production emergency in the 🚨 Hotfix lane (ticket first, fix, FRD after) |
| `security-review` | Touches auth, permissions, tenant context, money, KYC or data exposure; the PR lists it under "Security review" and gets a second read before merge |

---

## Feature-flow labels

Optional labels that mark where in the contract-driven flow (`.claude/rules/contract-driven-flow.md`) a ticket is:

| Label | Meaning |
|---|---|
| `feature:parent` | Parent feature ticket (should have sub-issues) |
| `feature:be` | BE sub-issue for a parent feature |
| `feature:fe` | FE sub-issue for a parent feature |
| `feature:contract` | Contract validation sub-issue (tagged to both BE and FE) |

The `[Contract]` sub-issue must be approved by BE and FE (closed) before the parent moves 🔧 Tech Plan Approved → 💻 AI Development.

---

## Special states

| Label | Meaning |
|---|---|
| `tech-debt` | Ticket was auto-filed by size-audit; represents a monolith to split later |
| `incomplete-spec` | Filed with insufficient detail; triage should follow up or close |
| `needs-triage` | Explicitly flags items stuck in 📥 Backlog that need a promotion decision |
| `autopilot-ok` | Eligible for tech-debt autopilot pickup (F5 — once that lands) |
| `release-blocker` | Must ship before the next release cut |

---

## Framework-board-only labels

These only exist in the `Rohit-code/AISDLC` repo (framework board). `bin/aisdlc-observe.sh` applies them; if a label is missing it files the issue without it and warns. Create one with `gh label create gap:rule --repo Rohit-code/AISDLC`.

| Label | Meaning |
|---|---|
| `gap:rule` | Filed by F38 observation — rule was silent on a case |
| `gap:agent` | Filed by F38 observation — agent spec missing guidance |
| `gap:pattern` | Filed by F38 observation — pattern recurring across projects |
| `gap:drift` | Filed by F38 observation — reality and framework disagree |

---

## When to create a new label

Don't proliferate. Ask:

1. Does a similar label already exist?
2. Will this label be applied to 5+ tickets over the next 3 months?
3. Is it needed for filtering or reporting that agents or humans will actually run?

If yes to all three, add it. If not, skip.

New labels for framework-wide use land via an F-ticket on the framework board.
