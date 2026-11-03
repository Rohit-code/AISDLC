# Team Onboarding — Filing Tickets in the AISDLC Pipeline

**Audience**: engineers, designers, PMs, and stakeholders working on a project that uses the AISDLC framework on GitHub Projects.

**Reading time**: 5 minutes.

**Pass status**: Pass 1 — covers team-managed projects on GitHub Projects only. For client-dictated projects on Jira / YouTrack / Linear, see Pass 2 once F12 (tracker abstraction) ships.

---

## What this framework is, in 30 seconds

We use an AI-driven SDLC pipeline. AI agents (planner, builder, tester, shipper) do the heavy lifting on planning, code, tests, and staging deploys. Humans set direction, review, and approve.

The whole pipeline runs on a 12-column GitHub Projects board — Backlog → FRD Draft → Tech Plan → AI Development → Code Review → Staging → Production → Done. Tickets move across columns as work progresses; **moving a ticket is how you grant permission for the next stage to start.**

## What you need to do

**One thing**: file tickets in the **📥 Backlog** column.

You don't write execution plans. You don't move tickets through the pipeline. You don't touch the framework's internals. You file a ticket describing a problem or an idea, and the triage lead picks it up from there.

That's it. The rest of the framework happens around you.

## How to write a good ticket

A good Backlog ticket describes a **problem and a desired outcome** — not a solution or a tech plan. Three required sections, one optional:

```
### Problem
[What's broken, missing, or painful. Be specific.]

### Desired outcome
[What "done" looks like from a user's perspective. What changes for them?]

### Affected area
[BE / FE / infra / framework — pick one or more]

### Context (optional)
[Links to PRs, screenshots, prior tickets, customer messages, etc.]
```

That's the whole template. Copy it, fill it in, file the ticket. Don't over-think it.

### What NOT to put in a Backlog ticket

- ❌ A tech design ("we should use Redis with a 5-minute TTL")
- ❌ Implementation details ("add a column to the orders table")
- ❌ Acceptance criteria checkboxes (those come later in FRD Draft)
- ❌ Time estimates (those come later in execution planning)
- ❌ Assignee names (the triage lead handles ownership)

The reason: if you pre-decide the solution, the planner can't explore alternatives, and we lose the value of having AI in the loop. State the problem and trust the pipeline.

## Examples — good vs bad

### ✅ Good ticket

```
Title: [BE] Export-report endpoint returns 500 when user has no department

### Problem
Users who joined through an invite and were never given a department get
500 errors when calling /reports/{id}/export. The endpoint reads
report.owner.department, which is null for these users.

### Desired outcome
Export works for all users, regardless of department. Users without one
either get the export cleanly or a 400 with a clear message.

### Affected area
BE

### Context
Found while testing the report-sharing ticket. Same code path also affects scheduled exports.
```

Why it's good: real problem, observable symptom, scoped to one endpoint, clear "done" criteria. Doesn't tell the AI *how* to fix it.

### ❌ Bad ticket

```
Title: Refactor invoices module

### Problem
The invoices code is messy and hard to work with.

### Desired outcome
Cleaner code.
```

Why it's bad: vague problem, no observable symptom, no measurable outcome, no scope. The triage lead can't decide if this is worth doing, the planner can't audit anything, and "cleaner" means different things to different people. If you want a refactor, name *what specifically* is broken (e.g., "InvoiceController has 50 endpoints in one class, causing merge conflicts every sprint") and *what specifically* should change ("split by responsibility into invoices + payments + approvals controllers").

### ✅ Good ticket (frontend)

```
Title: [FE] Invoice list loses scroll position when user goes back from invoice detail

### Problem
On the invoice list (erp-fe), if a user opens an invoice and clicks Back,
they're returned to the top of the list instead of the row they had opened.
Forces them to scroll and re-find their place, which slows down reviews.

### Desired outcome
Browser back navigation preserves scroll position on the invoice list.

### Affected area
FE (erp-fe)

### Context
Reported by several users. Recording: <link>
```

### ❌ Bad ticket (frontend)

```
Title: Add useReducer to the invoice form

### Problem
The invoice form uses too many useState calls.

### Desired outcome
Use useReducer instead.
```

Why it's bad: prescribes a solution without naming a problem. "Too many useState calls" isn't a user-visible symptom or a concrete pain. If there's a real bug or maintainability issue, name *that*, not the implementation choice.

## What happens after you file

1. **Sits in 📥 Backlog**. No SLA. No promises.
2. **Triage lead reviews on a cadence** (daily-ish for active projects). Three outcomes:
   - **Promoted to 📝 FRD Draft** — "we're going to plan this." Now the FRD process kicks off.
   - **Closed as duplicate / out-of-scope / won't-do** — with a one-line reason.
   - **Stays in Backlog** — "interesting, not now." Will be revisited later.
3. **If promoted**, you'll see the ticket move into FRD Draft and eventually through the rest of the pipeline. You can comment with extra context, but you don't need to drive anything — the pipeline handles itself.
4. **You don't need to follow the ticket**. The triage lead and AI will handle it. If you want updates, subscribe to the issue.

## Client confidentiality — what you can and can't say

You can talk about our use of AI for code generation. Clients know this. Be clear and confident about it.

What you **cannot** share with clients:

- ❌ The AISDLC repo, its directory structure, or any file under `.claude/`
- ❌ Agent names like `@builder`, `@planner`, `@shipper`
- ❌ The 12-column pipeline terminology, column names, or column emoji
- ❌ FRD / Execution Plan / Verification Gate / Size Audit terminology
- ❌ Framework rule files, templates, or prompts
- ❌ Screenshots of the framework board
- ❌ Any file containing the word "framework" in the AISDLC sense

What you **can** share:

- ✅ "Yes, we use AI heavily for code generation and review."
- ✅ "We have an internal process for AI-assisted development with human review at every step."
- ✅ "All AI-generated code goes through verification and human code review before merging."
- ✅ The actual code, PRs, and commits in the client's repos.

If a client asks to see the framework or wants details on the methodology — **escalate to the framework owner, do not share**. The AI is commodity; the discipline around it is the team's moat.

## Where to file

**For team-managed projects** (most internal tooling, increasingly most client work): **GitHub Projects board** for that specific project. The triage lead will tell you which board.

**For client-dictated projects** (client uses Jira / YouTrack / Linear): use the client's tracker as you normally would. The framework reads from the client's existing MCP — you don't need to learn anything new. (Tracked: F12.)

## The minimum ticket — copy this

```markdown
### Problem


### Desired outcome


### Affected area
BE / FE / infra / framework

### Context

```

That's the whole interface. Five minutes to file, problem solved.

## Questions

- **What if my problem is urgent?** — File it as usual but add `urgent` to the title. Triage will see it sooner. For actual production fires, ask the tech lead to put it in the 🚨 Hotfix lane (a human moves it in; `@shipper` handles the hotfix branch and PR).
- **What if I already know the fix?** — Great, write it in the Context section as "Suggested fix: …". Don't put it in the Problem or Desired Outcome — those should describe the *user-visible* situation.
- **What if I'm not sure if it's a bug or a feature?** — Doesn't matter. File it. Triage will decide.
- **Can I file something I'm not sure about?** — Yes. Backlog has no commitment. "I noticed something weird, here's what I saw" is a valid ticket.
- **Do I have to use this template?** — Yes, even if your ticket is one sentence. The structure makes triage 10x faster.

## What this doc is NOT

- Not a guide to the framework's internals (that's `docs/Framework-Wiki.md`, and you don't need to read it)
- Not a tutorial on how to write FRDs (that comes after triage)
- Not documentation of the AI agents (you don't interact with them directly)

You file tickets. The framework does the rest.
