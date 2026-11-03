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

- **Solo mode** — one human operator, AI runs autonomously. AI may also move tickets into AI-active columns. It still never merges, never moves into 🚀 Ready for Production / ✅ Done, and never skips the staging columns. The AISDLC repo itself runs solo.
- **Team mode** — 2+ humans coordinate. AI only exits AI-active columns; humans move tickets into them. PR review and merge are human actions. The ERP project (erp-core + erp-fe) runs team.

Mode is declared in `.claude/stack-*.yml` (`framework.mode`; missing = team) and echoed in the project's `AGENTS.md` / `CLAUDE.md`. Stack config wins if they disagree. See `.claude/rules/solo-vs-team-mode.md`.

## The agents (7 total)

| Agent | Stage | What it does |
|-------|-------|-------------|
| `@project-wiki` | Pre-board + Done | Generates & maintains Product Wiki + Architecture docs |
| `@ticket-manager` | All | Enforces column transitions, validates permissions, mode-aware |
| `@planner` | FRD Tech Plan | FRD assist + execution plan + API contracts + decision logging |
| `@tester` | AI Development | Writes failing tests + fixtures from API contracts (TDD — before code) |
| `@builder` | AI Development | BE models → APIs → pass tests → contract validation |
| `@fe-builder` | AI Development | FE components + screens + API client from contracts |
| `@shipper` | Staging Ready + Rework + 🚨 Hotfix | Staging deploy (only when the stack file defines staging) + rework + hotfix lane + docs + production checklist |

Agent definitions live in `.claude/agents/`, one flat file per agent: `.claude/agents/<name>.md` (e.g. `.claude/agents/builder.md`).

## Hard rules (the non-negotiable ones)

Each one maps to a specific production incident, scope explosion, or client-engagement lesson:

1. **Verification Gate** (full text: `.claude/agents/builder.md`, section "Verification Gate") — No ticket moves to 👀 Code Review without pasted command output proving the change works, or an explicit "cannot verify — blocked by #X" comment naming the blocker.

2. **Size Audit + auto tech-debt ticketing** (F1, `.claude/rules/size-audit.md`) — Before planning or building against unfamiliar code, agents measure the target files. Red thresholds (per stack, listed in the rule) trigger a pause, auto-ticketing of tech debt, and a proposed narrowed scope.

3. **Scope discrepancy escalation** (F2, `.claude/rules/size-audit.md`) — Mid-build, if actual scope trends past 2× the complexity budget, the agent pauses and posts a scope question instead of silently absorbing.

4. **Operating mode governs autonomy** (F13, `.claude/rules/solo-vs-team-mode.md`) — Solo = AI runs; team = AI waits. Declared per project. 🚀 Ready for Production and ✅ Done are always human-only, regardless of mode.

5. **Ticket movement = permission** (`.claude/rules/kanban-workflow.md`) — In team mode, AI never self-promotes into an AI-active column. In solo mode, it does, and logs every move as a ticket comment.

6. **Secrets management** (F15, `.claude/rules/secrets-management.md`) — Never commit `.env`, API keys, or credentials. Every repo needs `.env.example`. If committed secrets discovered, file P0 ticket; rotation is a coordinated human action.

7. **Client-facing boundary** (F8, `.claude/rules/client-facing-boundary.md`) — Clients never see the framework repo, agent names, or framework terminology. `@shipper` runs a sanitization pass before pushing to any client-owned repo.

8. **Parent ticket + sub-issues** (F32, `.claude/rules/agent-communication.md`) — Any task with 3+ related sub-tasks must be modeled as a GitHub Issue parent with linked sub-issues (not flat lists, not draft items).

9. **Framework gap capture** (F38, `.claude/rules/framework-observation.md`) — When AI hits a gap mid-project-work (rule silent, agent missing guidance, reality drift), file a one-line Backlog ticket on the framework board with `bin/aisdlc-observe.sh --type <rule|pattern|drift|agent> --project <p> --ticket <n> --summary "..."` and keep working. No gate. No plan. Just capture.

10. **Source control** (`.claude/rules/source-control.md`) — Branch `feature/<ticket-id>-<slug>` from `<remote>/<pr_base>` (stack file), PR back into `<pr_base>`; the human squash-merges. AI never commits or pushes to the default branch, never force-pushes, never merges. Commit attribution follows `commit_attribution` in the stack file (ERP: `none`).

## Directory layout

### Framework repo (`AISDLC/`)

```
AISDLC/                             ← the framework repo
├── CLAUDE.md
├── AGENTS.md → CLAUDE.md           ← symlink (Cursor auto-reads)
├── .claude/
│   ├── agents/<name>.md            ← 7 agent definitions (flat files)
│   ├── rules/                      ← kanban, source-control, gh-recipes, size-audit,
│   │                                  secrets, ticket-discipline, ... (one file each)
│   ├── skills/aisdlc-init/         ← /aisdlc-init project setup skill
│   ├── board-config.yml            ← framework board IDs
│   └── settings.json
├── bin/aisdlc-observe.sh           ← files a framework-gap ticket
├── .cursor/
│   └── rules/                      ← 12 framework Cursor rules (pointer pattern)
├── templates/
│   ├── *.md / *.yaml               ← FRD, Execution Plan, API Contract, etc.
│   ├── PROJECT-CONTEXT/            ← template for per-project context repo
│   └── SETUP-TICKETS/              ← idempotent setup tickets used by /aisdlc-init
├── archive/                        ← historical files, not loaded
└── docs/
    ├── Framework-Wiki.md           ← this file
    ├── Engineer-Quickstart.md      ← engineer-facing guide
    ├── Team-Onboarding-GitHub.md   ← triage-lead guide for GitHub Projects
    └── framework-board-reference.md ← framework board IDs + GraphQL snippets
```

### Project workspace (consumer)

The workspace IS the AISDLC clone. Project repos are cloned inside it and gitignored there (each keeps its own git) — see the root `.gitignore` and `CLAUDE.md`.

```
AISDLC/                             ← the workspace = the framework clone
├── CLAUDE.md, AGENTS.md → CLAUDE.md
├── .claude/
│   ├── agents/, rules/, skills/    ← framework (shared by every project)
│   ├── board-config.yml            ← framework board only
│   ├── stack-be.yml, stack-fe.yml  ← the project's facts (ERP: erp-core, erp-fe)
│   └── stack-framework.yml         ← facts for meta-work on AISDLC itself
├── <project>-context/              ← per-project context repo (gitignored here, own git)
│   ├── board-config.yml            ← the project board IDs
│   ├── docs/, contracts/, indexes/
├── <project-be>/                   ← backend repo (gitignored here; ERP: erp-core/)
└── <project-fe>/                   ← frontend repo(s) (gitignored here; ERP: erp-fe/)
```

## Bringing the framework to a new project

`/aisdlc-init <project-slug> --stack=<spring-next|django-react|voice-s2s> --repos=<a,b>` (`.claude/skills/aisdlc-init/SKILL.md`) checks each step below and files a setup ticket for every one that is missing. By hand, the steps are:

1. Clone AISDLC — the clone is the workspace: `git clone git@github.com:Rohit-code/AISDLC.git AISDLC && cd AISDLC`.
2. Clone your project's code repos inside it, naming the remote as the stack file's `remote` (add their folder names to `.gitignore`). ERP: `git clone -o github git@github-regnus-tech:RegnusTech/erp-core.git erp-core` and the same for `erp-fe` (`github-regnus-tech` is an SSH host alias on Rohit's Mac; others use `git@github.com:RegnusTech/...`).
3. Create `<project>-context/` from `templates/PROJECT-CONTEXT/` and push it to your org's GitHub.
4. Project config:
   - Create `<project>-context/board-config.yml` with your project's board IDs (`.claude/board-config.yml` stays the framework board).
   - Set `.claude/stack-*.yml` for your repos: `framework.mode`, `repo`, `remote`, `default_branch`, `pr_base`, `protected_branches`, `commit_attribution`, `staging`, test commands, `board_config` (examples: `.claude/stack-be.yml`, `.claude/stack-fe.yml`).
5. Cursor: the framework rules are already in `.cursor/rules/` (generated by `bin/gen-cursor-rules.py`).
6. Add `AGENTS.md → CLAUDE.md` symlinks in each code repo if they don't have one.
7. Create a GitHub Project board with the 12 columns, priority/owner/scope fields (`templates/SETUP-TICKETS/_common/S02-project-board.md`).
8. Run `@project-wiki` Generate mode to produce `<project>-context/docs/Product-Wiki.md`, `<project>-context/docs/TECH-Architecture-BE.md`, and `<project>-context/docs/TECH-Architecture-FE.md`.
9. First build ticket runs size audit → populates `<project>-context/indexes/`.
10. Protect each repo's default branch (no release branch: feature branches PR into `pr_base` — the default branch or a stream branch).
11. Start filing tickets in 📥 Backlog.

## The framework evolves through its own board

The framework itself lives on its own GitHub project board, **"AI SDLC Pipeline"**. Every framework improvement (new rule, new agent, refactor) goes through the same FRD → plan → build → review flow as a client feature. Tickets are prefixed with `F` (F1, F2, F3 …) and, per F32, real parent/child relationships use GitHub sub-issues.

Additionally, per F38, AI **proactively files framework-gap tickets** on this board when it hits gaps during project work. No gate, no plan — capture and continue. Triage on the framework board happens out-of-band.

The board is user-owned: https://github.com/users/Rohit-code/projects/2. IDs live in `.claude/board-config.yml`; `docs/framework-board-reference.md` has the framework-board snippets.

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
- F29 — Deployment rule (expand/contract migrations + blue-green patterns).
- F30 — aws-ecs-bluegreen setup variant.
- F31 — Extend `@shipper` for AWS deploys.
- F34 — `framework.tools` field in stack-*.yml schema (sub-issue of F33).
- F35 — Tool parity doc (sub-issue of F33).
- F39 — Ticket discipline (intake, blockers, dual-channel status) — **Tier 1**.
- F40 — Contract-driven feature flow (API+FE) — **Tier 1**.

### Epic parents (for tracking)

- **F-Deploy Epic** — F29 + F30 + F31.
- **F-DevAutonomy Epic** — F23 + F24 + F25 (F26 unlinked, now standalone Tier 1).
- **F33** — parent of F34 + F35.
