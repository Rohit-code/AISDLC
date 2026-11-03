# Agent Communication Protocol

## Principles

1. **Ticket is the single source of truth** — All communication happens on the ticket (issue comments). No side channels.
2. **Ask, don't assume** — When unclear, post a question on the ticket. Don't guess.
3. **Log every decision** — Use the decision log format for any non-trivial choice.
4. **Handoff explicitly** — When done, post a summary comment and move the ticket.
5. **Multi-step work = parent ticket + sub-issues** — Never create a flat list of related tickets. If a task has 3+ related sub-tasks, create a parent epic and link children via GitHub's native sub-issue feature. See [Parent tickets and sub-issues](#parent-tickets-and-sub-issues).

## Communication Format

### Status Update
```
### Status: [Starting/In Progress/Blocked/Complete]
**Agent**: @agent-name | **Date**: YYYY-MM-DD

[What was done or what's happening]
```

### Question (when blocked)
```
### Question: [Brief title]
**Agent**: @agent-name | **Blocking**: Yes/No | **Date**: YYYY-MM-DD

**Context**: [Why this question came up]
**Options**: [What AI sees as possibilities]
**Recommendation**: [What AI would do if no answer comes]
**Needed from**: [Product/Tech]
```

Common question categories (use as the question title when applicable):
- **"Scope discrepancy"** — Actual scope discovered during build is wider or narrower than the ticket says. Pause work, document what was found, propose a scope decision. Example: ticket says "fix 1 file", the same defect is in 9 files → pause and ask before expanding.
- **"Ambiguity in spec"** — Two equally valid interpretations of the FRD / API contract.
- **"Dependency discovered"** — Work requires another ticket to land first.
- **"Tech choice"** — A non-obvious technical decision that should be logged as a Decision.

### Tech-debt Observation
When an agent notices tech debt worth fixing *outside* the current ticket's scope, don't bury it in the current ticket's comments. Use this format and create a follow-up ticket.

```
### Tech-debt Observation: [Brief title]
**Agent**: @agent-name | **Noticed during**: #<ticket> | **Date**: YYYY-MM-DD

**What**: [The debt — code smell, anti-pattern, brittle design]
**Why it matters**: [Impact on testability, maintenance, performance, security]
**Proposed fix**: [Rough sketch of what a cleanup would look like]
**Effort**: [S / M / L — see sizing below]
**Follow-up ticket**: #<new-ticket>
```

**Sizing convention** (use these exact definitions — not vibes):
- **S** = fits in one ticket. ≤500 LOC changed, ≤8 files, ≤1 session. No FRD needed — it's a direct tech-debt ticket. (Automatic pickup of S tickets by an agent is future work, tracked as framework ticket F5; until then a human picks them.)
- **M** = needs an FRD. Multi-session, multiple sub-tickets, probably touches >1 app. Goes through the normal planner flow.
- **L** = needs a phase. Multi-week, cross-cutting, likely architectural (e.g., "split a large `billing` module into `billing` + `invoicing` + `collections`"). Goes in the roadmap, not the current sprint.

After posting the observation, create a separate issue with label `tech-debt`: in **📥 Backlog in team mode**; **📝 FRD Draft is allowed in solo mode** (`.claude/rules/kanban-workflow.md`). M/L tickets need Product triage before the planner touches them. The current ticket's work is NOT blocked — tech debt is always a follow-up.

### Decision Log
```
### Decision: [Title]
**Column**: [0-11, per `.claude/rules/kanban-workflow.md`] | **Decided by**: [Product/Tech/AI] | **Date**: YYYY-MM-DD
**Context**: [Why this decision was needed]
**Decision**: [What was decided]
**Alternatives**: [What else was considered]
**Impact**: [What this affects]
**References**: [Links to Figma, meetings, Slack, etc.]
```

### Handoff
```
### Handoff: [Column moved to]
**Agent**: @agent-name | **Date**: YYYY-MM-DD

**Done**:
- [List of completed items]

**For reviewer**:
- [What to look at]
- [Known issues or open items]

**Links**:
- PR: [url]
- Staging: [url]
- Tests: [pass/fail summary]
```

## Parent tickets and sub-issues

**Rule**: Any task that decomposes into 3 or more related sub-tasks MUST be created as a parent ticket with linked sub-issues. Never create a flat list of related tickets.

### Why

Flat ticket lists lose the "we're shipping one thing" framing. Sub-issue linking:
- Gives the board a visible epic-scoped view
- Shows progress as "X of Y sub-issues done"
- Prevents one sub-task from getting merged while another is forgotten
- Makes the parent-child dependency tree queryable for reports

### When to apply

Create a parent + sub-issues when the work:
- Is a multi-phase rollout (e.g., a multi-phase rollout epic)
- Spans multiple repos with the same logical goal
- Has work items that share acceptance criteria at the top level
- Would be reasonable for a single person to claim as "their project for the next N weeks"

Do NOT create a parent when:
- The task is 1-2 sub-tasks (just create the tickets flat)
- Sub-tasks are completely independent (e.g., 5 unrelated bug fixes)
- The parent would have no content of its own beyond listing children

### How to create parent + sub-issues

Sub-issues only work between **real GitHub issues**, never project-level draft items (framework tickets are real issues in `Rohit-code/AISDLC`; project tickets are real issues in the repo named by the project's board config).

1. Create the parent issue, then each child issue.
2. Add every issue to the board.
3. Link each child to the parent (`addSubIssue`).
4. Set Status and Priority on each board item (moves allowed per `.claude/rules/kanban-workflow.md`).
5. Drafts created by mistake are converted to real issues first.

Commands for every step: `.claude/rules/gh-recipes.md`.

### Parent ticket body template

```markdown
## What
[One-sentence summary of the epic.]

## Why
[Why this is a multi-phase effort rather than a single ticket.]

## Sub-issues
- #<N> <subtitle-1> — <one-line scope>
- #<N> <subtitle-2> — <one-line scope>
- ...

(GitHub auto-renders the sub-issue checklist; you don't have to manually maintain this list. This is a readable fallback.)

## Dependencies
- [Framework tickets needed: F##, F##]
- [External prerequisites]

## Acceptance (top-level)
- [Outcome that signals the entire epic is done, not just each sub-issue]

## Size: [S/M/L/epic]
```

### Sub-issue body template

Same as a regular ticket, plus:

```markdown
Depends on: #<N>, #<M>
```

Always declare dependencies explicitly, as one `Depends on: #N` line (several: `Depends on: #12, #15`) — inside or outside the epic. A dependency is met when its PR is merged; check command in `.claude/rules/gh-recipes.md`. The sub-issue order on the board doesn't imply order of execution.

### Agents MUST

- When creating 3+ related tickets, ask: "is this a parent-child structure?" If yes, create parent first, then children linked via `addSubIssue`.
- When closing a sub-issue, check if all siblings are closed — if yes, post a comment on the parent summarizing the epic's completion.
- The parent's Status follows the transition matrix in `.claude/rules/kanban-workflow.md` like any other ticket; it is not derived from its sub-issues.

## Agent Behavior Rules

### When AI is Active (in an AI column)
1. Post "Starting" status update
2. Read all prior comments on the ticket for context
3. Read relevant codebase files
4. Do the work
5. Post progress updates for long tasks
6. If blocked, post a Question — continue non-blocking work
7. Post Handoff and move ticket to next column

### When AI is Not Active (in a human column)
- Do NOT touch the ticket
- Do NOT generate code or plans
- Exception: Respond to direct questions tagged to an agent

### When Multiple Repos Are Involved
- Post which repos will be affected
- Create separate PRs per repo
- Ticket only moves when ALL repo work is complete

### Cross-repo batch work (same change, N repos)

When a ticket requires the **same logical change** across multiple repos (e.g., add .env.example to every repo, standardize design tokens across repos):

1. **Plan once** — define the change as a template before touching any repo
2. **Apply in parallel** where possible — don't serialize identical work
3. **One branch per repo** with the same naming convention: `feature/<ticket-id>-<description>`
4. **One status update covering all repos** — not N separate updates:

```
### Status: Complete
**Agent**: @agent-name | **Date**: YYYY-MM-DD

Applied across 2 repos:
| Repo | Branch | Commit | Changes |
|------|--------|--------|---------|
| erp-core | feature/104-env-setup | abc123 | .env.example + .gitignore |
| erp-fe | feature/104-env-setup | def456 | .env.example + .gitignore |
```

5. **Ticket moves when ALL repos are done** — partial completion stays in progress

**When to batch vs split**: Same logical change across repos = one ticket, batch apply. Different logical changes per repo = split into separate tickets. The test: "would someone reviewing this expect to see the same diff in each repo?" If yes → batch.

## Conflict Resolution

When Product and Tech disagree:
1. Tech comments disagreement with reasoning
2. Product responds with business justification
3. If unresolved → label `needs-discussion`, schedule sync
4. Decision logged using Decision Log format
5. Domain determines final say:
   - Business logic / scope → Product wins
   - Technical feasibility / architecture → Tech wins
   - Cost / timeline → discussed, Tech advises, Product decides
