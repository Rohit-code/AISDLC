# Framework Observation — Proactive Gap Capture

Hard rule for AI behavior. When AI hits a framework gap during project work, it MUST file a one-line Backlog ticket on the AISDLC framework board and continue the project ticket it was working on. No gate. No plan. No pause.

This is the mechanism that turns every project engagement into a framework learning signal (**Loop 2** in the two-loop operating model — see `docs/Framework-Wiki.md`).

---

## The rule

When a framework gap is **observed** — by AI itself, or expressed by the human in chat — AI:

1. Files a one-line Backlog ticket on the framework board with `bin/aisdlc-observe.sh` (see Command below). **Does not ask for permission first.**
2. Continues the project ticket it was working on — does not block on the framework issue.
3. Mirrors both actions in chat (per `ticket-discipline.md` Rule 3 dual-channel status).

That's it. No gate, no plan, no pause. Triage (the framework owner) promotes Backlog items into FRD Draft at cadence; most die in Backlog as duplicates or out-of-scope. That's the filter, not the filing.

### Two observation sources

**Self-detection** — AI notices a gap while working on a project ticket (e.g., running a size audit, drafting a contract, moving a ticket). Files automatically.

**Human-expressed** — the human mentions a gap in chat, explicitly or implicitly:
- Explicitly: *"the rule doesn't say what to do when X."*
- Implicitly: *"this is annoying — I had to work around the size-audit to do Y."*
- Questioning: *"should I file this as a framework issue?"* — yes, and AI files it without asking again.

**AI bias**: over-capture. If a chat signal plausibly maps to a gap trigger, file it. Don't ask "should I file this?" — just file. Duplicates and misfires are cheap (triage closes them). Missed signal is expensive (friction repeats, framework doesn't learn).

---

## What counts as a framework gap (four triggers)

1. **Rule-silence** — a canonical rule is silent on the case AI just hit.
   - *Example*: `size-audit.md` thresholds cover controllers but AI encounters a 2,000-line scheduled-job class. Rule doesn't say what threshold to use.

2. **Pattern-repeat** — the same workaround has come up 2+ times.
   - *Example*: two different tickets have needed to mock the same vendor API. Recurring pattern deserves codification.

3. **Reality-drift** — framework and reality disagree.
   - *Example*: rule says `@shipper` pushes to GitHub via `gh`. Reality: a project's code is on another git host whose CLI is needed. Rule needs updating.

4. **Agent-gap** — canonical agent spec is missing guidance AI needed.
   - *Example*: `@fe-builder` spec doesn't mention how to handle a11y on new screens. AI had to guess.

Any of these four → file on Backlog, continue working.

---

## Ticket shape

**Title**: `Framework gap: <one-line summary>`

**Body** (minimum required fields):
```
## Hit while working

<project>#<ticket-id> — <what the AI was doing>

## Gap type

rule-silence | pattern-repeat | reality-drift | agent-gap

## Context

<1–3 lines: what was silent / what pattern / what drift / what missing>

## Proposed next

triage
```

**Labels** (apply at filing time — see `docs/Board-Labels.md` framework-board section):
- `gap:rule` — rule-silence
- `gap:pattern` — pattern-repeat
- `gap:drift` — reality-drift
- `gap:agent` — agent-gap

---

## Command

Use the wrapper `bin/aisdlc-observe.sh` (run from the AISDLC root). It creates the issue in `Rohit-code/AISDLC`, applies the `gap:*` label, adds it to the framework board and sets 📥 Backlog (IDs from `.claude/board-config.yml`):

Usage:
```
bin/aisdlc-observe.sh --type <rule|pattern|drift|agent> \
  --project <project-slug> \
  --ticket <N> \
  --summary "<one-line>" \
  [--context "<1-3 lines>"] \
  [--dry-run]
```

Example:
```bash
bin/aisdlc-observe.sh --type rule --project erp --ticket 45 \
  --summary "size-audit silent on scheduled-job classes" \
  --context "billing/InvoiceScheduler.java is 2100 LOC; no threshold defined for BE background-job files"
```

`--type`, `--project`, `--ticket` and `--summary` are required; `--dry-run` prints what would be filed and calls nothing; `bin/aisdlc-observe.sh --help` prints the usage. If the script can't run, file the same ticket by hand with the commands in `.claude/rules/gh-recipes.md` (create issue in `Rohit-code/AISDLC`, add to board, set Status = 📥 Backlog).

---

## Non-negotiables

- **No gate.** Creation is zero-ceremony. If AI hesitates to file because the gap seems small, it's a framework violation.
- **Backlog only.** Never skip into FRD Draft. That's triage's job.
- **One ticket per gap.** Don't bundle. Per `size-audit.md`: never silently absorb scope.
- **Do not pause the project ticket.** Filing is parallel work, not serial.
- **Framework board only.** Project-specific issues go on the project board per `ticket-discipline.md` Rule 1.

---

## What's NOT a framework gap (don't file)

- **Project-specific bugs** — goes on project board as a bug / tech-debt ticket (see `ticket-discipline.md`).
- **Questions** — framework unclear on a thing but you can infer intent. Ask in chat; if the ambiguity persists, then file.
- **Opinions** — "I'd prefer the kanban pipeline had 11 columns instead of 12." File under opinion-ware, not framework-gap. (Triage will close as won't-fix.)

---

## Interaction with other rules

- **`ticket-discipline.md` (F39)** — Rule 3 (dual-channel status) applies. Framework-gap filings mirror as chat summary: `AISDLC#<N>: Framework gap filed. <link>.`
- **`agent-communication.md`** — no parent/sub-issue link needed for gap tickets (they're atoms).
- **`contract-driven-flow.md` (F40)** — irrelevant to framework gaps.
- **`size-audit.md`** — if the gap is about missing thresholds for a stack, file as rule-silence gap.

---

## Enforcement responsibility

| Agent | When it files |
|---|---|
| `@planner` | Rule silent during FRD generation; pattern recurring across tickets; agent-gap in `@planner` itself. |
| `@builder`, `@fe-builder` | Rule silent during build (stack threshold gaps, test pattern gaps); agent-gap in their own spec. |
| `@tester` | Rule silent on testing patterns; fixture generation gaps. |
| `@shipper` | Release/deploy flow gaps; runbook gaps. |
| `@ticket-manager` | Kanban rule ambiguities; transition validation gaps. |
| `@project-wiki` | Doc-hygiene gaps; index schema gaps. |

Every agent is responsible for filing gaps they hit. This is not a delegated responsibility — it's part of the agent's own job.

---

## Dogfooding

Gaps such as F44 (arch-impact labels), F46 (duplicate-check) and F47 (docs consolidation) are examples of the capture-first pattern: filed mid-work, then triaged later.

Once this rule is live, the pattern is explicit: **every agent files gaps without asking**. No framework issue dies in chat.

---

## Learned from

- F1 auto tech-debt ticketing — same capture-first philosophy, applied to framework gaps.
- Owner requirement: gap capture is done by the agent, proactively, with no gate, because it only creates tickets.
