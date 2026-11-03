# Solo Mode vs Team Mode

The framework's **ownership chain** (ticket movement = permission) is a team-scale feature. When one human runs the pipeline alone, forcing manual ticket moves through 12 columns is overhead with no benefit. When 2+ humans are involved, those same movements are coordination points that make role boundaries visible.

So the framework operates in **two modes** declared per project. The mode changes the ceremony level — but not the safety rules.

## Solo Mode

**When to use**: exactly one human is involved in the pipeline. Internal tooling. Solo client work. Personal projects. One-person side initiatives.

### What changes
- AI runs autonomously by default. AI moves tickets through the pipeline itself, into AI-active columns and out of them (exact moves: the solo/autonomous column of the matrix in `.claude/rules/kanban-workflow.md`).
- AI logs each autonomous move as a comment on the ticket: *"Moved to <column> under solo mode on <date>"*
- The human's job is to **observe and unblock**: watch what AI is doing, verify outcomes (tests pass, staging looks right), answer blocking questions when AI hits one.
- The human does NOT need to line-review every test case, every commit, or every ticket move. That's what verification gates and code review checkpoints are for — they exist as outputs the human can spot-check, not as ceremonies the human must drive.

### What does NOT change in Solo mode
- **Verification Gate** still applies. Every handoff to a review column needs pasted command output proving the change works.
- **Size Audit** still applies. Pre-work file measurement and auto tech-debt ticketing happen on every ticket.
- **Scope-discrepancy escalation** still applies. Mid-build pause at 2× complexity budget.
- **Hard stops** still apply: destructive ops (rm -rf, drop table, reset --hard, force push), financial actions, security-sensitive changes (auth, permissions, secrets), and every command denied in `.claude/settings.json` (pushes to `master` / `main` / `plan/*`, force pushes and ref deletes, `gh pr merge`, `git reset --hard`, `git clean -f`, `git branch -D`, `rm -rf`, `pkill` / `killall`, delete calls on repos / issues / projects, reading `.env`) — these always require explicit human confirmation in chat, even in solo mode.
- **Protected branches and merging** — AI never pushes to a protected branch and never merges a PR, regardless of mode (`.claude/rules/source-control.md`).
- **Human-only moves** — 🚀 Ready for Production and ✅ Done are always set by a human; AI never skips the staging columns (`.claude/rules/kanban-workflow.md`).
- **Per-edit file approval** — file edits still go through Claude Code's permission flow; the framework doesn't override that.

### The trade
Solo mode trades ceremony for speed. The verification gate replaces the human-permission gate as the primary discipline. If verification stays rigorous, solo mode is faster with no loss of safety. If verification gets sloppy, solo mode silently accumulates bugs — and that's worse than team mode's overhead.

## Team Mode

**When to use**: 2+ humans involved in the pipeline. Anyone reviewing PRs other than the implementer. Anyone filing tickets in 📥 Backlog. Cross-functional work with PM/Design/Tech splits. Most client projects with a team.

### What changes
- Strict ownership chain — AI waits for human moves into AI-active columns. AI never self-promotes a ticket into 🤖 FRD Tech Plan, 💻 AI Development, 🧪 Staging Ready, 🔄 Rework, or 🚨 Hotfix.
- Every column transition is a coordination point (team column of the matrix in `.claude/rules/kanban-workflow.md`).
- Backlog → FRD Draft promotion is the triage lead's responsibility, not AI's.
- Code Review approval is a human action. AI does not self-approve PRs.
- Staging Review approval is Product's responsibility.

### Why the ceremony exists
At team scale, the column you're in tells everyone whose turn it is. Without the ceremony, two engineers + AI can stomp on each other, duplicate work, or skip stages. The 12 columns are coordination infrastructure.

### What stays the same as Solo mode
- Verification Gate, Size Audit, Scope-discrepancy escalation — all still hard rules.
- Protected branches, no AI merges, hard stops, per-edit approval.
- Dogfooding discipline (every framework change goes through the framework board).

## Declaring the mode

The mode is machine-read from the **stack file** — for ERP, `.claude/stack-be.yml` and `.claude/stack-fe.yml` (both `mode: team`). It is also stated in two human-readable places:

- the framework's own `CLAUDE.md`: AISDLC framework meta-work (tickets on the framework board) runs **solo** — this is the one case declared in CLAUDE.md rather than a stack file, because the stack files describe the project repos, not the framework. Project work always takes its mode from the stack files.
- the project's `CLAUDE.md` (in `<project>-context/`), as a line in the introduction:
   ```
   **Operating mode**: solo
   ```
   or
   ```
   **Operating mode**: team
   ```

Stack file field:
```yaml
framework:
  mode: team    # solo | team
```

If a CLAUDE.md line and the stack file disagree, the **stack file wins** — it's the source of truth for tooling. The CLAUDE.md line should be updated to match.

## When neither is declared

**Default to team mode.** Team mode is safer (more ceremony, more checkpoints) and never causes data loss or bypassed reviews. The cost of accidentally running team mode in a solo project is a few extra ticket moves; the cost of accidentally running solo mode in a team project is uncoordinated work and potentially merged-without-review code.

When in doubt, ask the human in chat: "Is this a solo project or team project?" and write the answer to the stack config.

## Mode transitions

A project can change modes over its lifetime — typically going from **solo → team** as the team grows. The transition is intentional, not automatic:

1. The triage lead explicitly updates `framework.mode` in the stack files (`mode: solo` → `mode: team`) and the mode line in the project `CLAUDE.md` in one change — one PR per repo that holds those files (the stack files live in the workspace repo, the project `CLAUDE.md` in `<project>-context`), merged together.
2. Branch: `feature/<ticket-id>-mode-solo-to-team`, like any other change (`.claude/rules/source-control.md`).
3. Open tickets at the time of transition keep their current state; new tickets follow the new mode.
4. Post a one-line note on the next 5 active tickets so the AI sees the change: *"Operating mode changed to team. Strict ownership chain now applies."*

**Going team → solo** is rare but legal — same process, reversed.

## Per-session override (autonomous mode)

Even in team mode, the human can grant a one-session autonomous override by saying something like *"go autonomous on this batch"* or *"you can move cards yourself for the rest of this session"*. This temporarily relaxes the ownership chain for the duration of the session and ends when the session does, when the human says so, or when AI hits a blocking question. Solo mode is essentially a permanent version of this, declared at the project level.

## Concrete examples

| Scenario | Mode |
|---|---|
| Rohit alone on the AISDLC framework (meta-work) | Solo |
| One engineer alone on a backend during early testing | Solo |
| ERP (erp-core + erp-fe), Rohit and Vijay working in parallel | Team (from `.claude/stack-be.yml` / `.claude/stack-fe.yml`) |
| Internal tooling, one engineer | Solo |
| Client engagement with client's PM filing tickets | Team (because Product is a separate human) |
| Hackathon prototype, one builder | Solo |
| Open-source side project, accepting PRs from contributors | Team |

The test isn't "how big is the team" — it's "how many humans need to coordinate via the ticket system". One coordinating human → solo. Two or more → team.

## Why this rule lives in the framework, not in one person's head

When engineers clone AISDLC onto a new project, the framework should boot up correctly without the framework owner having to explain it each time. The mode declaration in the stack file is the first thing the framework reads — it determines whether agents operate autonomously or wait for human moves. Without this rule, engineers would either drown in unnecessary ceremony on solo projects, or skip permission checks that actually matter on team projects. The rule has to be in the repo.
