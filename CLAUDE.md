# AISDLC — AI-Driven Software Development Lifecycle Framework

## What This Is

A reusable, stack-agnostic framework for AI-driven software development with a clear **ownership chain**. Every stage has ONE owner (Product, Tech, or AI). Ticket movement = permission. In team mode, AI only works when humans move tickets into AI columns.

## Directory Layout

```
AISDLC/                        ← The workspace IS the AISDLC clone; project repos are cloned inside it (gitignored)
├── CLAUDE.md                  ← You are here (AGENTS.md is a symlink to it)
├── .claude/
│   ├── agents/<name>.md       ← One file per agent (builder, fe-builder, planner, project-wiki, shipper, tester, ticket-manager)
│   ├── rules/*.md             ← Kanban workflow, source control, communication, gh recipes, ERP guardrails, ...
│   ├── skills/aisdlc-init/    ← /aisdlc-init skill (SKILL.md)
│   ├── stack-be.yml           ← Project facts for the backend repo (ERP: erp-core) — swap per project
│   ├── stack-fe.yml           ← Project facts for the frontend repo (ERP: erp-fe) — swap per project
│   ├── stack-framework.yml    ← Facts for meta-work on this AISDLC repo itself (solo, remote origin, base main)
│   ├── board-config.yml       ← Framework board IDs (projects keep their own board-config.yml)
│   └── settings.json          ← Permission allow/deny list
├── bin/aisdlc-observe.sh      ← Files framework-gap tickets (F38)
├── templates/
│   ├── *.md / *.yaml          ← FRD, Execution Plan, API Contract, Production Checklist, etc.
│   ├── PROJECT-CONTEXT/       ← Template for per-project context directory
│   └── SETUP-TICKETS/         ← Init sequence: _common/ + one folder per stack variant
├── docs/                      ← Framework wiki, board labels, onboarding
├── archive/                   ← Historical material, not loaded as guidance
├── <project>-context/         ← Project context (own git, gitignored here)
│   ├── docs/                  ← Product Wiki, Tech Architecture (human-readable)
│   ├── contracts/             ← API contracts (agent + human readable)
│   └── indexes/               ← Codebase indexes (agent-operational)
├── <project-be>/              ← Backend repo (own git, gitignored here; ERP: erp-core/)
├── <project-fe>/              ← Frontend repo(s) (own git, gitignored here; ERP: erp-fe/)
└── .gitignore                 ← Ignores cloned repos (they have their own git)
```

## The 12-Column Kanban Pipeline

`📥 Backlog` → `📝 FRD Draft` → `🤖 FRD Tech Plan` → `🔧 Tech Plan Approved` → `💻 AI Development` → `👀 Code Review` → `🧪 Staging Ready` → `🎭 Staging Review` → `🔄 Rework` → `🚀 Ready for Production` → `✅ Done`, plus `🚨 Hotfix`.

AI-active columns: 🤖 FRD Tech Plan, 💻 AI Development, 🧪 Staging Ready, 🔄 Rework, 🚨 Hotfix. Owners, the transition matrix (who may move what, per mode), `staging: none`, the Done definition and required documents per move: `.claude/rules/kanban-workflow.md` — the single source.

**Team model**: the whole team creates tickets in 📥 Backlog. They don't write plans or move tickets forward — the triage lead reviews Backlog and promotes selected tickets to 📝 FRD Draft to enter the pipeline. This is the only way non-triage team members interact with the framework.

## Operating Mode

Every project runs in **Solo mode** or **Team mode**, read from `framework.mode` in its stack file (`.claude/stack-be.yml`, `.claude/stack-fe.yml`). Default when undeclared: **team**.

- **Solo** = one human running the pipeline; AI may also move tickets into AI-active columns.
- **Team** = 2+ humans; only humans move tickets into AI-active columns.

Mode changes the *ceremony*, not the *safety*: Verification Gate, Size Audit, scope-discrepancy escalation, protected branches, no AI merges and hard stops apply in both. Full rule: `.claude/rules/solo-vs-team-mode.md`.

**Operating mode**:
- AISDLC framework meta-work (this repo, framework board): **solo** (Rohit + AI), from `.claude/stack-framework.yml` (remote `origin`, base `main`, checks `python3 bin/check-framework.py` + `python3 bin/gen-cursor-rules.py --check`).
- ERP project (erp-core + erp-fe): **team** (Rohit and Vijay), from the stack files. ERP hard rules: `.claude/rules/erp-guardrails.md`.

## Core Rules

### Ticket Movement = Permission
Moving a ticket is giving permission. In team mode AI never moves a ticket INTO an AI-active column; AI never moves a ticket into 🚀 Ready for Production or ✅ Done in any mode. Every decision, assumption and handoff is logged on the ticket. Matrix: `.claude/rules/kanban-workflow.md`.

### Autonomous Mode (explicit delegation only)
Team-mode rules can be relaxed for one session only by an explicit user instruction in chat ("go autonomous on this batch"). AI then logs every move it makes, still stops for scope discrepancies, security, destructive or financial actions, and still never merges or touches protected branches. Details: `.claude/rules/kanban-workflow.md` and `.claude/rules/solo-vs-team-mode.md`.

### Verification Gate (hard rule)
No ticket moves to 👀 Code Review without pasted command output proving the change works, or an explicit "cannot verify — blocked by #X" comment. Full text: `.claude/agents/builder.md`, section "Verification Gate".

### Source control (hard rule)
No release branch. Branch `feature/<ticket-id>-<slug>` from `<remote>/<pr_base>` (stack file: ERP remote `github`, base = the ticket's `plan/<stream>` branch, else the default branch) in a fresh worktree `../wt-<repo>-<ticket-id>`, PR back into `<pr_base>`; the human squash-merges (one commit per ticket per repo); AI never pushes to `master`/`main`, never force-pushes, never merges. Commit attribution follows `commit_attribution` in the stack file (ERP: `none`). Full rule: `.claude/rules/source-control.md`; command recipes: `.claude/rules/gh-recipes.md`.

### Local dev env is prerequisite work
Before running AI development tickets on a new repo, the repo must have a one-command local dev setup (e.g., `docker compose up -d`) so agents can verify their work. If it doesn't exist, **create that ticket first** and ship it before test/build tickets. This rule exists because unverified work wastes real time.

### Client-facing boundary (hard rule)
The framework is the team's internal moat. AI is commodity; the discipline around it is not. Before any artifact (commit, PR body, release note, client-facing doc) crosses into a client-visible space, `@shipper` runs the **sanitization pass** per `.claude/rules/client-facing-boundary.md` — strips agent names, pipeline terminology, framework concepts, F-ticket IDs, and any reference to AISDLC. Plain engineering language only on the client side. Clients know we use AI; that's fine to say. The framework stays inside the team.

### Size Audit + auto tech-debt tickets (hard rule)
Before planning or building against unfamiliar code, agents run a size audit per `.claude/rules/size-audit.md` (separate BE and FE threshold tables). Any red threshold → pause, file one tech-debt ticket per distinct monolith, propose a narrowed scope inside the single-session complexity budget. Tech debt is never silently absorbed.

### Secrets management (hard rule)
Never commit `.env` files, API keys, or secrets. Before touching a new repo, agents run the pre-work `.env` audit per `.claude/rules/secrets-management.md`; committed secrets → stop, P0 ticket, flag the human. Every repo has a `.env.example` with safe placeholders.

### Ticket discipline (hard rule)
Every feature on the board before any code. Blockers get typed labels + product tagging + TAT pause. Every AI stage transition is posted as a ticket comment AND mirrored as a one-line chat summary so humans don't switch tabs. Chat-described features get AI-filed tickets. See `.claude/rules/ticket-discipline.md` for full rules (F39). Label taxonomy: `docs/Board-Labels.md`.

### Contract-driven feature flow (hard rule for API+FE projects)
Features that touch both BE and FE follow the contract-driven flow: parent ticket with required FRD sections, 3 linked sub-issues (`[Contract]`, `[BE]`, `[FE]`), contract validation gate (BOTH BE and FE approve the `[Contract]` sub-issue before 🔧 Tech Plan Approved → 💻 AI Development), TDD on both sides enforced by `@tester` before builders touch code, migration / gap callouts populated at FRD time and re-validated at build. See `.claude/rules/contract-driven-flow.md` for full rules (F40). `@ticket-manager` blocks transitions that skip the gate.

### Framework observation — proactive gap capture (hard rule, F38)
When AI hits a framework gap during project work (rule silent, pattern recurring, reality drifting, agent spec missing guidance), file a one-line Backlog ticket on the AISDLC framework board with `bin/aisdlc-observe.sh` and continue the project ticket. No gate. No plan. No pause. This is how Loop 2 (framework evolution) runs continuously without blocking Loop 1 (project execution). Every agent owns filing gaps they hit — not delegated. See `.claude/rules/framework-observation.md`.

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

## Agents

| Agent | Stage | What It Does |
|-------|-------|-------------|
| `@project-wiki` | Pre-board + Done | Generates & maintains living product wiki |
| `@ticket-manager` | All | Enforces column transitions, validates permissions |
| `@planner` | FRD Tech Plan | FRD assistance + execution plan + API contracts + decision logging |
| `@tester` | AI Development | Writes tests + fixtures from API contracts (TDD — tests BEFORE code) |
| `@builder` | AI Development | Models → APIs → pass tests → schema publish + contract validation |
| `@fe-builder` | AI Development | Components + screens + API client from contracts |
| `@shipper` | Staging Ready + Rework + Hotfix | Staging deploy (only when the stack file defines staging) + rework planning + hotfix lane + docs + prod checklist |

Agent specs: `.claude/agents/<name>.md`. If an agent grows too many concerns, split it into focused agents — only once the need is proven.

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
10. Staging → Review → Production (staging skipped by a human when the stack file says `staging: none`)
```

API contracts live in `<project>-context/contracts/` — single source of truth for BE and FE.

## Stack Agnostic

The framework doesn't depend on any specific tech stack. Stack details live in the stack files (`.claude/stack-be.yml`, `.claude/stack-fe.yml`). Agents read these configs to know what to generate. Same process works for Django or Express, Next.js or Nuxt, React Native or Flutter.

## How to Use on a New Project

AISDLC projects start by running the **init sequence** — an idempotent set of setup tickets that scaffold everything from the context repo to the first Product Wiki. Templates live in `templates/SETUP-TICKETS/`.

### Quick path

Run the `/aisdlc-init` skill (`.claude/skills/aisdlc-init/SKILL.md`, F28):

```
/aisdlc-init <project-slug> --stack=<variant> --repos=<a,b>
```

Stack variants (`templates/SETUP-TICKETS/<variant>/`):
- `spring-next` — Spring Boot BE + Next.js FE (the ERP shape)
- `django-react` — Django BE + React/Next FE(s)
- `voice-s2s` — OpenAI Realtime / streaming voice

Init runs each ticket's idempotent check, creates tickets for what's missing, and is safe to re-run.

### Manual path

1. **Clone** this repo — the clone IS the workspace: `git clone git@github.com:Rohit-code/AISDLC.git AISDLC && cd AISDLC`. Run `claude` here once and accept the "trust this folder" prompt — until then Claude Code ignores the allow list in `.claude/settings.json` (the deny list always applies). Check the framework with `python3 bin/check-framework.py`.
2. **Copy** `templates/PROJECT-CONTEXT/` → `<project>-context/` (inside the workspace, gitignored) and fill in `CLAUDE.md`
3. **Create the project board** with the 12 AISDLC columns + Priority/Owner/Scope fields
4. **Write** the project's own board config at `<project>-context/board-config.yml` (`.claude/board-config.yml` stays the framework board)
5. **Copy** `.claude/stack-be.yml` / `.claude/stack-fe.yml` and swap in the project's values (mode, repo, `remote`, default branch, `pr_base`, attribution, staging, tests, `board_config`)
6. **Clone** your project repos inside the workspace (gitignored, each keeps its own git), naming the remote as the stack file's `remote`. ERP:
   ```bash
   git clone -o github git@github-regnus-tech:RegnusTech/erp-core.git erp-core
   git clone -o github git@github-regnus-tech:RegnusTech/erp-fe.git erp-fe
   ```
   (`github-regnus-tech` is an SSH host alias on Rohit's Mac; others use `git@github.com:RegnusTech/erp-core.git`.)
7. **Run secrets audit** per `.claude/rules/secrets-management.md` — fix `.gitignore`, check for committed keys
8. **Read** `templates/SETUP-TICKETS/_common/manifest.yml` and create board tickets for each setup step not yet done
9. **For stack-specific work**: read `templates/SETUP-TICKETS/<variant>/manifest.yml` and create those tickets too
10. **Work through the setup tickets** — `@shipper` handles mechanical setup (env files, local dev env), `@project-wiki` generates the Product Wiki, `@planner` generates Tech Architecture, `@builder`/`@fe-builder` populate the codebase indexes
11. **The ownership chain begins** — regular feature tickets can start flowing through the pipeline

### What stays the same across projects
- Agents (`.claude/agents/`) — the process is universal
- Rules (`.claude/rules/`) — kanban workflow, communication protocol
- Templates (`templates/`) — FRD, execution plan, API contract, etc.

### What you swap per project
- Stack files (`.claude/stack-be.yml`, `.claude/stack-fe.yml`) — your project facts and tech stack
- `<project>-context/board-config.yml` — your project board IDs
- Repo CLAUDE.md files — codebase-specific context
- `<project>-context/` — project context (docs, contracts, indexes)
- `.gitignore` — your repo folder names

## Source Control

Use plain `gh`. Branches, PRs, commits, protected branches and attribution: `.claude/rules/source-control.md`. Board and GraphQL commands: `.claude/rules/gh-recipes.md`.

## Key Conventions

- Product Wiki : FRD = 1 : many (one wiki, multiple FRDs for features — wiki updates when FRD ships)
- FRD : Execution Plan = 1 : many (one per repo/scope)
- FRD : PR = 1 : many (one per repo)
- Every execution document lives ON THE TICKET. The issue thread IS the audit trail.
- Contract-first development: API contract defined before BE/FE build in parallel.
- One branch per ticket per repo (`@tester` creates it, builders continue on it).
