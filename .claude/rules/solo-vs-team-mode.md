# Solo Mode vs Team Mode

The framework's **ownership chain** (ticket movement = permission) is a team-scale feature. When one human runs the pipeline alone, forcing manual ticket moves through 12 columns is overhead with no benefit. When 2+ humans are involved, those same movements are coordination points that make role boundaries visible.

So the framework operates in **two modes** declared per project. The mode changes the ceremony level — but not the safety rules.

## Solo Mode

**When to use**: exactly one human is involved in the pipeline. Internal tooling. Solo client work. Personal projects. One-person side initiatives.

### What changes
- AI runs autonomously by default. AI moves tickets through the pipeline itself, into AI-active columns and out of them.
- AI may merge to release branches without per-merge human approval (still never to master/main — that rule is universal).
- AI logs each autonomous move as a comment on the ticket: *"Moved to <column> under solo mode on <date>"*
- The human's job is to **observe and unblock**: watch what AI is doing, verify outcomes (tests pass, staging looks right), answer blocking questions when AI hits one.
- The human does NOT need to line-review every test case, every commit, or every ticket move. That's what verification gates and code review checkpoints are for — they exist as outputs the human can spot-check, not as ceremonies the human must drive.

### What does NOT change in Solo mode
- **Verification Gate** still applies. Every handoff to a review column needs pasted command output proving the change works.
- **Size Audit** still applies. Pre-work file measurement and auto tech-debt ticketing happen on every ticket.
- **Scope-discrepancy escalation** still applies. Mid-build pause at 2× complexity budget.
- **Hard stops** still apply: destructive ops (rm -rf, drop table, reset --hard, force push), financial actions, security-sensitive changes (auth, permissions, secrets), and anything in the prohibited_actions list — these always require explicit human confirmation in chat, even in solo mode.
- **Never merge to master/main** — release branches only, regardless of mode.
- **Done is human-only** — even in solo mode, the ✅ Done column means "merged to master and deployed", which is a human action.
- **Per-edit file approval** — file edits still go through Claude Code's permission flow; the framework doesn't override that.

### The trade
Solo mode trades ceremony for speed. The verification gate replaces the human-permission gate as the primary discipline. If verification stays rigorous, solo mode is faster with no loss of safety. If verification gets sloppy, solo mode silently accumulates bugs — and that's worse than team mode's overhead.

## Team Mode

**When to use**: 2+ humans involved in the pipeline. Anyone reviewing PRs other than the implementer. Anyone filing tickets in 📥 Backlog. Cross-functional work with PM/Design/Tech splits. Most client projects with a team.

### What changes
- Strict ownership chain — AI waits for human moves into AI-active columns. AI never self-promotes a ticket into 🤖 FRD Tech Plan, 💻 AI Development, 🧪 Staging Ready, or 🔄 Rework.
- Every column transition is a coordination point: triage lead → Product → AI → Tech → AI → Tech → AI → Product → Tech → Done.
- Backlog → FRD Draft promotion is the triage lead's responsibility, not AI's.
- Code Review approval is a human action. AI does not self-approve PRs.
- Staging Review approval is Product's responsibility.

### Why the ceremony exists
At team scale, the column you're in tells everyone whose turn it is. Without the ceremony, two engineers + AI can stomp on each other, duplicate work, or skip stages. The 12 columns are coordination infrastructure.

### What stays the same as Solo mode
- Verification Gate, Size Audit, Scope-discrepancy escalation — all still hard rules.
- Never merge to master, hard stops, per-edit approval.
- Dogfooding discipline (every framework change goes through the framework board).

## Declaring the mode

The mode lives in **two places** so it's both visible and machine-readable:

1. **Project root `CLAUDE.md`** — a human-readable line in the introduction:
   ```
   **Operating mode**: solo
   ```
   or
   ```
   **Operating mode**: team
   ```

2. **Stack config (`.claude/stack-be.yml` or equivalent)** — a machine-readable field:
   ```yaml
   framework:
     mode: solo    # solo | team
   ```

If the two disagree, the **stack config wins** — it's the source of truth for tooling. The CLAUDE.md line should be updated to match.

## When neither is declared

**Default to team mode.** Team mode is safer (more ceremony, more checkpoints) and never causes data loss or bypassed reviews. The cost of accidentally running team mode in a solo project is a few extra ticket moves; the cost of accidentally running solo mode in a team project is uncoordinated work and potentially merged-without-review code.

When in doubt, ask the human in chat: "Is this a solo project or team project?" and write the answer to the stack config.

## Mode transitions

A project can change modes over its lifetime — typically going from **solo → team** as the team grows. The transition is intentional, not automatic:

1. The triage lead explicitly updates `stack-*.yml` (`mode: solo` → `mode: team`) and the `CLAUDE.md` line in the same commit.
2. Filename: `feature/mode-solo-to-team` on a feature branch, just like any framework change.
3. Open tickets at the time of transition keep their current state; new tickets follow the new mode.
4. Post a one-line note on the next 5 active tickets so the AI sees the change: *"Operating mode changed to team. Strict ownership chain now applies."*

**Going team → solo** is rare but legal — same process, reversed.

## Per-session override (existing autonomous mode rule, unchanged)

Even in team mode, the human can grant a one-session autonomous override by saying something like *"go autonomous on this batch"* or *"you can move cards yourself for the rest of this session"*. This temporarily relaxes the ownership chain for the duration of the session and ends when the session does, when the human says so, or when AI hits a blocking question. Solo mode is essentially a permanent version of this, declared at the project level.

## Concrete examples

| Scenario | Mode |
|---|---|
| Rohit alone on the AISDLC framework | Solo |
| One engineer alone on a backend during early testing | Solo |
| ERP (erp-core + erp-fe), 2 engineers working in parallel | Team |
| Internal tooling, one engineer | Solo |
| Client engagement with client's PM filing tickets | Team (because Product is a separate human) |
| Hackathon prototype, one builder | Solo |
| Open-source side project, accepting PRs from contributors | Team |

The test isn't "how big is the team" — it's "how many humans need to coordinate via the ticket system". One coordinating human → solo. Two or more → team.

## Why this rule lives in the framework, not in one person's head

When engineers clone AISDLC onto a new project, the framework should boot up correctly without the framework owner having to explain it each time. The mode declaration in `stack-*.yml` is the first thing the framework reads — it determines whether agents operate autonomously or wait for human moves. Without this rule, engineers would either drown in unnecessary ceremony on solo projects, or skip permission checks that actually matter on team projects. The rule has to be in the repo.
