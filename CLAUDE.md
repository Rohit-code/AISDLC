# AISDLC — AI-Driven Software Development Lifecycle Framework

## What This Is

A reusable, stack-agnostic framework for AI-driven software development with a clear **ownership chain**. Every stage has ONE owner (Product, Tech, or AI). Ticket movement = permission. AI only works when humans move tickets into AI columns.

## Directory Layout

```
AISDLC/
├── CLAUDE.md                  ← You are here
├── .claude/
│   ├── agents/                ← All agents (project-wiki, planner, tester, builder, etc.)
│   ├── rules/                 ← Kanban workflow, communication protocol
│   ├── stack-*.yml            ← Stack configs (swap these per project)
│   ├── board-config.yml       ← Board IDs (swap per project — agents read this to move tickets)
│   └── settings.json
├── templates/
│   ├── *.md / *.yaml          ← FRD, Execution Plan, API Contract, Production Checklist, etc.
│   └── PROJECT-CONTEXT/       ← Template for per-project context directory
├── <project>-context/         ← Project context (own git, gitignored here)
│   ├── docs/                  ← Product Wiki, Tech Architecture (human-readable)
│   ├── contracts/             ← API contracts (agent + human readable)
│   └── indexes/               ← Codebase indexes (agent-operational)
├── <project-be>/              ← Backend repo (own git, gitignored here)
├── <project-fe>/              ← Frontend repo(s) (own git, gitignored here)
└── .gitignore                 ← Ignores cloned repos (they have their own git)
```

## The 12-Column Kanban Pipeline

| # | Column | Owner | AI Active? |
|---|--------|-------|-----------|
| 0 | 📥 Backlog | Team (anyone can create) | NO — waiting for triage |
| 1 | 📝 FRD Draft | Product | Assist only |
| 2 | 🤖 FRD Tech Plan | AI | YES — generates execution plan |
| 3 | 🔧 Tech Plan Approved | Tech | NO — waiting for approval |
| 4 | 💻 AI Development | AI | YES — builds code |
| 5 | 👀 Code Review | Tech | NO — human reviews |
| 6 | 🧪 Staging Ready | AI | YES — deploys staging |
| 7 | 🎭 Staging Review | Product | NO — Product tests |
| 8 | 🔄 Rework | AI | YES — applies feedback |
| 9 | 🚀 Ready for Production | Tech | NO — human deploys |
| 10 | ✅ Done | — | — |
| 11 | 🚨 Hotfix | Tech/AI | YES — emergency bypass |

**Team model**: the whole team creates tickets in 📥 Backlog. They don't write plans or move tickets forward — the triage lead reviews Backlog and promotes selected tickets to 📝 FRD Draft to enter the pipeline. This is the only way non-triage team members interact with the framework.

## Operating Mode (declared per project)

Every project runs in either **Solo mode** or **Team mode** — declared in `.claude/stack-*.yml` (`framework: { mode: solo | team }`) and mirrored in this CLAUDE.md introduction. Default when undeclared: **team** (safer).

- **Solo mode** = one human running the pipeline. AI moves tickets autonomously, merges to release branches, observes verification gates as primary discipline. Human observes and unblocks.
- **Team mode** = 2+ humans involved. Strict ownership chain: AI waits for human moves into AI-active columns. Every transition is a coordination point.

Both modes share the same hard safety rules (Verification Gate, Size Audit, Scope-discrepancy, never-merge-to-master, hard stops on destructive/financial/security ops). Mode only changes the *ceremony*, not the *safety*.

See `.claude/rules/solo-vs-team-mode.md` for the full rule, decision criteria, and per-session overrides.

**Operating mode for this project**: solo (Rohit + AI on the AISDLC framework itself)

## Core Rules

### Ticket Movement = Permission (Team mode default)
- In **team mode**, AI CANNOT move a ticket INTO an AI-active column. Only HUMANS can.
- AI CAN move a ticket OUT of an AI-active column into a human-review column.
- Every decision, assumption, and handoff is logged on the ticket.
- In **solo mode**, AI moves tickets in both directions autonomously and logs each move as a comment.

### Autonomous Mode (explicit delegation only)
The ownership chain above is the safe default. It can be relaxed — **but only via an explicit user instruction in chat** (e.g., "you can move cards and work yourself" or "go autonomous on this batch"). When autonomous mode is active:

- AI may move cards into AI-active columns to pick up the next ticket itself
- AI may merge its own work into a **release branch** (never directly to master/main)
- AI must log every autonomous move as a comment on the ticket: *"Moved to 💻 AI Development under autonomous mode granted by @user on <date>"*
- AI must still stop and ask for: scope discrepancies, security issues, destructive ops, financial actions, and anything in the `prohibited_actions` list
- Autonomous mode ends when: the user says so, the session ends, or AI hits a blocking question

Autonomous mode is a productivity shortcut, not a safety override. All hard safety rules still apply.

### Verification Gate (hard rule)
No ticket moves to 👀 Code Review without either:
- (a) **pasted command output** proving the change works (tests passing, endpoint responding, migration applied, curl output, etc.), OR
- (b) an explicit "cannot verify — blocked by #X" comment naming the blocker

Unverified handoffs silently accumulate bugs. See `.claude/agents/builder/agent.md`.

### Local dev env is prerequisite work
Before running AI development tickets on a new repo, the repo must have a one-command local dev setup (e.g., `docker compose up -d`) so agents can verify their work. If it doesn't exist, **create that ticket first** and ship it before test/build tickets. This rule exists because unverified work wastes real time.

### Client-facing boundary (hard rule)
The framework is the team's internal moat. AI is commodity; the discipline around it is not. Before any artifact (commit, PR body, release note, client-facing doc) crosses into a client-visible space, `@shipper` runs the **sanitization pass** per `.claude/rules/client-facing-boundary.md` — strips agent names, pipeline terminology, framework concepts, F-ticket IDs, and any reference to AISDLC. Plain engineering language only on the client side. Clients know we use AI; that's fine to say. The framework stays inside the team.

### Size Audit + auto tech-debt tickets (hard rule)
Before planning or building against unfamiliar code, agents run a size audit per `.claude/rules/size-audit.md`. Separate threshold tables exist for **BE** (e.g., 1500+ LOC file, 600+ LOC class, 25+ endpoints on one controller, 40+ fields on one entity) and **FE** (e.g., 300+ LOC component, 800+ LOC screen, 15+ props, 5+ useEffects). If any red threshold is hit, the agent **pauses**, creates tech-debt tickets for each distinct monolith, and proposes a narrowed scope that fits inside a single-session complexity budget. Tech debt gets filed as its own ticket — never silently absorbed. This rule exists because scope explosions found mid-build cost far more than ones found at planning time.

### Secrets management (hard rule)
Never commit `.env` files, API keys, or secrets. Before touching a new repo, agents run a pre-work `.env` audit per `.claude/rules/secrets-management.md` — check `.gitignore`, check if `.env` is tracked, check docker-compose files for inline secrets. If committed secrets are found: stop, create P0 ticket, flag the human. Every repo must have `.env.example` with safe placeholders. This rule exists because committed secrets are a common finding when a team takes over an existing codebase.

### Ticket discipline (hard rule)
Every feature on the board before any code. Blockers get typed labels + product tagging + TAT pause. Every AI stage transition is posted as a ticket comment AND mirrored as a one-line chat summary so humans don't switch tabs. Chat-described features get AI-filed tickets. See `.claude/rules/ticket-discipline.md` for full rules (F39). Label taxonomy: `docs/Board-Labels.md`.

### Contract-driven feature flow (hard rule for API+FE projects)
Features that touch both BE and FE follow the contract-driven flow: parent ticket with required FRD sections, 3 linked sub-issues (`[Contract]`, `[BE]`, `[FE]`), contract validation gate (BOTH BE and FE approve before any build), TDD on both sides enforced by `@tester` before builders touch code, migration / gap callouts populated at FRD time and re-validated at build. See `.claude/rules/contract-driven-flow.md` for full rules (F40). `@ticket-manager` blocks transitions that skip the gate.

### Framework observation — proactive gap capture (hard rule, F38)
When AI hits a framework gap during project work (rule silent, pattern recurring, reality drifting, agent spec missing guidance), file a one-line Backlog ticket on the AISDLC framework board (IDs in `.claude/board-config.yml`) and continue the project ticket. No gate. No plan. No pause. This is how Loop 2 (framework evolution) runs continuously without blocking Loop 1 (project execution). Every agent owns filing gaps they hit — not delegated. See `.claude/rules/framework-observation.md`.

### Ask, Don't Assume
- When unclear, agents ask questions on the ticket — they don't guess.
- Ambiguity during development = comment on ticket, continue non-blocking work.

### Document Chain
- **Product Wiki** → Living doc of what the product IS today (`<project>-context/docs/Product-Wiki.md`)
- **FRD** → Issue on the board (feature request with scope decisions)
- **Execution Plan** → Sub-tasks under FRD issue
- **Tech DO's/DON'T's** → Comments on FRD issue
- **PR Description** → Linked to FRD
- **Production Checklist** → Comment on FRD issue

## Agents (Simplified — 4 stage agents + 2 utilities)

| Agent | Stage | What It Does |
|-------|-------|-------------|
| `@project-wiki` | Pre-board + Done | Generates & maintains living product wiki |
| `@ticket-manager` | All | Enforces column transitions, validates permissions |
| `@planner` | FRD Tech Plan | FRD assistance + execution plan + API contracts + decision logging |
| `@tester` | AI Development | Writes tests + fixtures from API contracts (TDD — tests BEFORE code) |
| `@builder` | AI Development | Models → APIs → pass tests → schema publish + contract validation |
| `@fe-builder` | AI Development | Components + screens + API client from contracts |
| `@shipper` | Staging Ready + Rework | Staging deploy + rework planning + docs + prod checklist |

> **TODO**: If any agent becomes too complex or handles too many concerns, split it into focused sub-agents. Keep minimal until the need is proven.

## TDD Build Order (per feature)

```
1. Product Wiki (what the product IS — living doc)
2. FRD (what to build next — scope decisions)
3. Execution Plan + API Contracts + Permission Matrix + Error Schemas
4. Tests + Fixtures (written FIRST — TDD)
5. Models + Migrations
6. API building (make tests pass)
7. Contract validation (built API matches spec)
8. FE builds from contract (parallel from step 3)
9. Integration verification
10. Staging → Review → Production
```

API contracts live in `<project>-context/contracts/` — single source of truth for BE and FE.

## Stack Agnostic

The framework doesn't depend on any specific tech stack. Stack details live in `stack-*.yml` config files. Agents read these configs to know what to generate. Same process works for Django or Express, Next.js or Nuxt, React Native or Flutter.

## How to Use on a New Project

AISDLC projects start by running the **init sequence** — an idempotent set of setup tickets that scaffold everything from the context repo to the first Product Wiki. Templates live in `templates/SETUP-TICKETS/`.

### Quick path (the future state — see F28)

```
/aisdlc-init <project-slug> --stack=<variant> --repos=<repo1,repo2,...>
```

Stack variants today:
- `django-react` — Django BE + React/Next FE(s)
- `voice-s2s` — OpenAI Realtime / streaming voice

Init runs each ticket's idempotent check. Creates tickets for what's missing. Safe to re-run anytime.

### Manual path (until the init slash command lands)

1. **Clone** this repo into a new workspace directory
2. **Copy** `templates/PROJECT-CONTEXT/` → `<project>-context/` and fill in `CLAUDE.md`
3. **Create the project board** with 12 AISDLC columns + Priority/Owner/Scope fields
4. **Update** `.claude/board-config.yml` with board IDs
5. **Create** `.claude/stack-<project>.yml` declaring stack + operating mode
6. **Clone** your project repos as siblings of `<project>-context/`
7. **Run secrets audit** per `.claude/rules/secrets-management.md` — fix `.gitignore`, check for committed keys
8. **Read** `templates/SETUP-TICKETS/_common/manifest.yml` and create board tickets for each setup step not yet done
9. **For stack-specific work**: read `templates/SETUP-TICKETS/<stack>/manifest.yml` and create those tickets too
10. **Work through the setup tickets** — `@shipper` handles mechanical setup (env files, docker-compose, release branches), `@project-wiki` generates the Product Wiki, `@planner` generates Tech Architecture, `@builder`/`@fe-builder` populate the codebase indexes
11. **The ownership chain begins** — regular feature tickets can start flowing through the pipeline

### What stays the same across projects
- Agents (`.claude/agents/`) — the process is universal
- Rules (`.claude/rules/`) — kanban workflow, communication protocol
- Templates (`templates/`) — FRD, execution plan, API contract, etc.

### What you swap per project
- Stack configs (`.claude/stack-*.yml`) — your tech stack choices
- Board config (`.claude/board-config.yml`) — your project board IDs
- Repo CLAUDE.md files — codebase-specific context
- `<project>-context/` — project context (docs, contracts, indexes)
- `.gitignore` — your repo folder names

## GitHub CLI

Use the GitHub CLI (`gh`) for GitHub operations.

## Branching Convention

We use a **release-branch flow** — feature branches merge into a long-lived release branch, which periodically merges into master/main for actual deploys.

```
master/main
    │
    └── release/ai-sdlc-v<N>       ← long-lived release branch
            │
            ├── feature/101-be-local-dev-setup
            ├── feature/102-be-test-infrastructure
            └── feature/103-be-auth-tests
```

### Per-ticket workflow

1. Pull latest from the **release branch** (or master if no release branch exists yet):
   ```bash
   git checkout release/ai-sdlc-v1 && git pull origin release/ai-sdlc-v1
   ```
2. Create a feature branch: `feature/<ticket-id>-<short-description>`
   - Example: `feature/102-be-test-infrastructure`
   - Ticket ID references the GitHub issue for traceability
3. Do the work, commit, verify
4. Merge the feature branch into the release branch (no-ff merge preserves history):
   ```bash
   git checkout release/ai-sdlc-v1 && git merge --no-ff feature/102-be-test-infrastructure
   ```
5. Ticket moves to 🚀 Ready for Production (= "in release branch, awaiting cut")
6. When the release is cut, `release/ai-sdlc-v1` → master, tickets move to ✅ Done

### Rules
- One feature branch per repo per ticket — if a feature touches BE and FE, each repo gets its own branch
- Feature branches are short-lived — delete after merging to release branch
- **Never merge directly to master** — even in autonomous mode, AI only merges to release branches
- Release branch is cut to master by a **human** (AI never touches master)
- PR title references the ticket: `[#102] Add test infrastructure for BE`

## Key Conventions

- Product Wiki : FRD = 1 : many (one wiki, multiple FRDs for features — wiki updates when FRD ships)
- FRD : Execution Plan = 1 : many (one per repo/scope)
- FRD : PR = 1 : many (one per repo)
- Every execution document lives ON THE TICKET. The issue thread IS the audit trail.
- Contract-first development: API contract defined before BE/FE build in parallel.
