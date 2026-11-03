# AISDLC Framework — Wiki (v1)

**What this doc IS**: a living description of the AISDLC framework as it exists today — its pipeline, agents, rules, and how to bring it onto a new project. It evolves every time a framework F-ticket ships.

**What this doc is NOT**: a marketing page, a roadmap, or a per-project reference. Per-project docs (Product Wiki, Tech Architecture, integrations) live in `<project>-context/docs/`; agent-operational files (indexes, contracts) live in `<project>-context/` alongside them. Each code repo keeps its own `README.md` and `CLAUDE.md` only.

---

## Doc map

Four docs live alongside this one. Read the one that matches your role:

| Doc | Audience | Read when |
|---|---|---|
| `Engineer-Quickstart.md` | Engineer | Day 1 on a project, or any day you're shipping a feature |
| `Framework-Wiki.md` (this doc) | Architect / adopter | Understanding what AISDLC is and how the pieces compose |
| `Team-Onboarding-GitHub.md` | Triage lead / tech lead | Setting up a team on a GitHub Projects-backed project |
| `framework-board-reference.md` | Automation author | Calling the framework board via `gh` or GraphQL |

---

## What AISDLC is

A reusable, stack-agnostic framework for AI-driven software development with a clear **ownership chain**. Every stage of the SDLC has exactly one owner (Team, Product, Tech, or AI). Ticket movement on a kanban board = permission to act. The operating mode (solo / team) determines whether AI self-promotes tickets or waits for humans.

The framework's job is to make AI a **disciplined collaborator**, not an autonomous hacker. Discipline comes from four places:
1. **Ownership chain** — who is allowed to move a ticket into which column (modulated by operating mode).
2. **Verification gate** — no handoff to human review without proof the change works.
3. **Size audit** — measure files before touching them; split monoliths into tech-debt tickets before building.
4. **Client-facing boundary** — framework artifacts (agent names, rule terminology) never appear in client-owned repos.

## Tool support

The framework ships adapters for **Claude Code** (`.claude/agents/`, `.claude/rules/`) and **Cursor** (`.cursor/rules/`). Both read the same canonical content via thin pointer rules. A project declares which tool(s) it supports in `stack-*.yml` (via `framework.tools`, once F34 lands) and consumes framework primitives by symlinking them into the workspace.

## The 12-column pipeline

| # | Column | Owner | AI Active? |
|---|--------|-------|-----------|
| 0 | 📥 Backlog | Team | NO |
| 1 | 📝 FRD Draft | Product | Assist only |
| 2 | 🤖 FRD Tech Plan | AI | YES |
| 3 | 🔧 Tech Plan Approved | Tech | NO |
| 4 | 💻 AI Development | AI | YES |
| 5 | 👀 Code Review | Tech | NO |
| 6 | 🧪 Staging Ready | AI | YES |
| 7 | 🎭 Staging Review | Product | NO |
| 8 | 🔄 Rework | AI | YES |
| 9 | 🚀 Ready for Production | Tech | NO |
| 10 | ✅ Done | — | — |
| 11 | 🚨 Hotfix | Tech/AI | YES |

**Backlog** is where the team drops ideas and problem statements. Nothing in Backlog has a tech plan, acceptance criteria, or a timeline — it's raw input. The triage lead promotes selected tickets into 📝 FRD Draft when they're ready to plan.

See `.claude/rules/kanban-workflow.md` for full per-column ownership rules and valid AI moves.

## Operating modes (F13)

- **Solo mode** — one human operator, AI runs autonomously. AI self-promotes tickets into AI-active columns and merges to release branches without per-merge approval.
- **Team mode** — 2+ humans coordinate. AI only exits AI-active columns; humans move tickets into them. PR review is a human action.

Mode is declared in `.claude/stack-*.yml` (`framework.mode`) and echoed in the project's `AGENTS.md` / `CLAUDE.md`. Stack config wins if they disagree. See `.claude/rules/solo-vs-team-mode.md`.

## The agents (7 total)

| Agent | Stage | What it does |
|-------|-------|-------------|
| `@project-wiki` | Pre-board + Done | Generates & maintains Product Wiki + Architecture docs |
| `@ticket-manager` | All | Enforces column transitions, validates permissions, mode-aware |
| `@planner` | FRD Tech Plan | FRD assist + execution plan + API contracts + decision logging |
| `@tester` | AI Development | Writes failing tests + fixtures from API contracts (TDD — before code) |
| `@builder` | AI Development | BE models → APIs → pass tests → contract validation |
| `@fe-builder` | AI Development | FE components + screens + API client from contracts |
| `@shipper` | Staging Ready + Rework | Staging deploy + rework + docs + production checklist + release composition |

Agent definitions live in `.claude/agents/`. Each agent has one file: `agent.md`.

## Hard rules (the non-negotiable ones)

Each one maps to a specific production incident, scope explosion, or client-engagement lesson:

1. **Verification Gate** (`.claude/rules/kanban-workflow.md`) — No ticket moves to 👀 Code Review without pasted command output proving the change works, or an explicit "cannot verify — blocked by #X" comment naming the blocker.

2. **Size Audit + auto tech-debt ticketing** (F1, `.claude/rules/size-audit.md`) — Before planning or building against unfamiliar code, agents measure the target files. Red thresholds (1500+ LOC file, 600+ LOC class, 25+ ViewSet actions, 300+ LOC component) trigger a pause, auto-ticketing of tech debt, and a proposed narrowed scope.

3. **Scope discrepancy escalation** (F2, `.claude/rules/size-audit.md`) — Mid-build, if actual scope trends past 2× the complexity budget, the agent pauses and posts a scope question instead of silently absorbing.

4. **Operating mode governs autonomy** (F13, `.claude/rules/solo-vs-team-mode.md`) — Solo = AI runs; team = AI waits. Declared per project. ✅ Done is always human-only, regardless of mode.

5. **Ticket movement = permission** (`.claude/rules/kanban-workflow.md`) — In team mode, AI never self-promotes into an AI-active column. In solo mode, it does, and logs every move as a ticket comment.

6. **Secrets management** (F15, `.claude/rules/secrets-management.md`) — Never commit `.env`, API keys, or credentials. Every repo needs `.env.example`. If committed secrets discovered, file P0 ticket; rotation is a coordinated human action.

7. **Client-facing boundary** (F8, `.claude/rules/client-facing-boundary.md`) — Clients never see the framework repo, agent names, or framework terminology. `@shipper` runs a sanitization pass before pushing to any client-owned repo.

8. **Parent ticket + sub-issues** (F32, `.claude/rules/agent-communication.md`) — Any task with 3+ related sub-tasks must be modeled as a GitHub Issue parent with linked sub-issues (not flat lists, not draft items).

9. **Framework gap capture** (F38 — rule pending, ticket filed) — When AI hits a gap mid-project-work (rule silent, agent missing guidance, reality drift), file a one-line Backlog ticket on the framework board and keep working. No gate. No plan. Just capture.

## Directory layout

### Framework repo (`AISDLC/`)

```
AISDLC/                             ← the framework repo
├── CLAUDE.md
├── AGENTS.md → CLAUDE.md           ← symlink (Cursor auto-reads)
├── .claude/
│   ├── agents/                     ← 7 agent definitions
│   ├── rules/                      ← kanban, communication, size-audit, secrets,
│   │                                  client-facing-boundary, solo-vs-team
│   └── settings.json
├── .cursor/
│   └── rules/                      ← 12 framework Cursor rules (pointer pattern)
├── templates/
│   ├── *.md / *.yaml               ← FRD, Execution Plan, API Contract, etc.
│   └── PROJECT-CONTEXT/            ← template for per-project context repo
└── docs/
    ├── Framework-Wiki.md           ← this file
    ├── Engineer-Quickstart.md      ← engineer-facing guide
    ├── Team-Onboarding-GitHub.md   ← triage-lead guide for GitHub Projects
    └── framework-board-reference.md ← framework board IDs + GraphQL snippets
```

### Project workspace (consumer)

```
<project>/                          ← workspace folder, not a git repo
├── aisdlc/                         ← framework clone (sibling)
├── <project>-context/              ← per-project context (internal by default)
│   ├── contracts/
│   ├── indexes/
│   └── decisions/
├── <project>-<service>/            ← application repo(s), 1..N
├── CLAUDE.md
├── AGENTS.md → CLAUDE.md
├── .claude/
│   ├── agents → ../aisdlc/.claude/agents        (symlink)
│   ├── rules  → ../aisdlc/.claude/rules         (symlink)
│   ├── board-config.yml                         (project-specific)
│   └── stack-*.yml                              (project-specific)
└── .cursor/
    └── rules/
        ├── framework → ../../aisdlc/.cursor/rules   (symlink — framework rules)
        └── <project-specific>.mdc                    (repo lists, globs, overrides)
```

## Bringing the framework to a new project

Today's process is mostly manual. F28 (project init command) will collapse it to one command; until F28 ships, run through these steps:

1. Create the workspace folder: `mkdir -p <project> && cd <project>`.
2. Clone AISDLC as a sibling: `git clone git@github.com:<owner>/AISDLC.git aisdlc`.
3. Clone your project's code repos as siblings (they'll be gitignored from AISDLC's perspective).
4. Create `<project>-context/` from `aisdlc/templates/PROJECT-CONTEXT/` and push to your org's GitHub.
5. Wire `.claude/`:
   - `mkdir -p .claude && ln -s ../aisdlc/.claude/agents .claude/agents && ln -s ../aisdlc/.claude/rules .claude/rules`.
   - Create `.claude/board-config.yml` with your project's board IDs.
   - Create `stack-*.yml` with `framework.mode` and (once F34 lands) `framework.tools`.
6. Wire `.cursor/` (if using Cursor):
   - `mkdir -p .cursor/rules && ln -s ../../aisdlc/.cursor/rules .cursor/rules/framework`.
7. Add `AGENTS.md → CLAUDE.md` symlinks at workspace root and in each code repo.
8. Create a GitHub Project board with the 12 columns, priority/owner/scope fields.
9. Run `@project-wiki` Generate mode to produce `<project>-context/docs/Product-Wiki.md`, `<project>-context/docs/TECH-Architecture-BE.md`, and `<project>-context/docs/TECH-Architecture-FE.md`.
10. First build ticket runs size audit → populates `<project>-context/indexes/`.
11. Create `release/<version>` long-lived branches per code repo.
12. Start filing tickets in 📥 Backlog.

## The framework evolves through its own board

The framework itself lives on its own GitHub project board, **"AI SDLC Pipeline"**. Every framework improvement (new rule, new agent, refactor) goes through the same FRD → plan → build → review flow as a client feature. Tickets are prefixed with `F` (F1, F2, F3 …) and, per F32, real parent/child relationships use GitHub sub-issues.

Additionally, per F38, AI **proactively files framework-gap tickets** on this board when it hits gaps during project work. No gate, no plan — capture and continue. Triage on the framework board happens out-of-band.

See `docs/framework-board-reference.md` for the Project ID, field ID, and column option IDs needed for GraphQL automation.

## What's shipped vs what's next

### Shipped (v0 → v1)

- F1 — Size audit + auto tech-debt ticketing.
- F2 — Scope-discrepancy escalation rule.
- F3 — S/M/L tech-debt sizing convention.
- F4 — Codebase Index (BE + FE) + split TECH-Architecture.
- F7 — Team onboarding runbook.
- F8 — Client-facing boundary rules + `@shipper` sanitization pass.
- F11 — Framework board bootstrap + 📥 Backlog column + dogfooding.
- F13 — Solo mode vs Team mode — operating mode declaration.
- F14 — FE size audit thresholds + adapt-per-stack guidance.
- F15 — Secrets management rule.
- F16 — Cross-repo batch work pattern for multi-repo tickets.
- F17 — Board config as code.
- F19 — Update `@fe-builder` for design tokens, codebase index, TW version awareness.
- F21 — Restructure per-project context (`<project>-context/` convention).
- F32 — Parent ticket + sub-issues rule (real issues, not draft items).
- F33 — Cursor adapter (first-class Cursor support alongside Claude Code).

### On the board, not yet built

Active (FRD Draft or Backlog on the framework board):

- F5 — Tech-debt autopilot (deferred until more projects have used it).
- F6 — Project-branch strategy for AISDLC repo (deferred until a second project adopts the framework).
- F9 — Pre-commit size guard.
- F10 — Weekly tech-debt review ceremony.
- F12 — Tracker abstraction layer (unlocks Jira / YouTrack / Linear via MCP dispatch).
- F18 — Doc hygiene rule (verify doc splits, stale refs).
- F20 — API contract generation for existing BE endpoints.
- F22 — Multi-model routing (LiteLLM gateway).
- F23 — Ambient layer (observer agent + auto-board + dev-first tracking) — **deferred**.
- F24 — Data layer (SQLite event log) — **deferred**.
- F25 — Git ownership (AI manages branches, commits, PRs, releases).
- F26 — Release composition intelligence + auto release notes — **Tier 1**.
- F27 — Cross-project framework shape — **deferred**.
- F28 — Project init command (idempotent setup with stack variants).
- F29 — Deployment rule (expand/contract migrations + blue-green patterns).
- F30 — aws-ecs-bluegreen setup variant.
- F31 — Extend `@shipper` for AWS deploys.
- F34 — `framework.tools` field in stack-*.yml schema (sub-issue of F33).
- F35 — Tool parity doc (sub-issue of F33).
- F38 — Framework gap capture (filed; rule pending implementation).
- F39 — Ticket discipline (intake, blockers, dual-channel status) — **Tier 1**.
- F40 — Contract-driven feature flow (API+FE) — **Tier 1**.

### Epic parents (for tracking)

- **F-Deploy Epic** — F29 + F30 + F31.
- **F-DevAutonomy Epic** — F23 + F24 + F25 (F26 unlinked, now standalone Tier 1).
- **F33** — parent of F34 + F35.
