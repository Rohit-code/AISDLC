# Client-Facing Boundary Rules

The AISDLC framework is **the team's internal moat**. AI is commodity; the discipline around it is not. This rule defines exactly what crosses the boundary into client-visible artifacts and what stays inside the team.

## Why this matters

Clients know we use AI. We tell them. That's not the secret. The secret is **how** — the framework, the agents, the rules, the verification gates, the size audits, the dogfooding loop. If a client could read `.claude/rules/`, they could replicate the entire methodology and stop paying for our expertise.

So the rule is simple: **the framework never appears in any client-visible artifact, ever.**

## What "client-visible" means

A client-visible artifact is anything the client can read, screenshot, search, or be shown:

- Commits in their repos (commit messages, file changes, author info)
- Pull request titles and bodies in their repos
- Issues filed in their tracker (Jira, YouTrack, Linear, etc.)
- Release notes, changelogs, deployment documentation shipped to them
- Slack / email / call transcripts where we talk to the client
- Loom videos demoing the work
- Any file delivered to the client as part of project handoff
- Screenshots in client meetings or proposals

The framework board is NOT client-visible — it's an internal board. Same for `<project>-context/` repos and the AISDLC repo itself.

## The blacklist — never appears in client-visible artifacts

These strings, names, or concepts must be **stripped** from any artifact before it crosses the boundary:

### Agent names
- `@builder`, `@planner`, `@tester`, `@fe-builder`, `@shipper`, `@project-wiki`, `@ticket-manager`
- Any future agent name added to `.claude/agents/`

### Pipeline terminology
- "12-column pipeline", "11-column pipeline", "Kanban pipeline"
- Column names with their emoji: "📥 Backlog", "📝 FRD Draft", "🤖 FRD Tech Plan", "🔧 Tech Plan Approved", "💻 AI Development", "👀 Code Review", "🧪 Staging Ready", "🎭 Staging Review", "🔄 Rework", "🚀 Ready for Production", "✅ Done", "🚨 Hotfix"
- "ownership chain", "AI-active column", "ticket movement = permission"

### Framework concepts (exact phrases)
- "Verification Gate"
- "Size Audit", "size audit", "complexity budget", "auto tech-debt ticketing"
- "Scope discrepancy escalation"
- "Autonomous mode" (in the framework sense)
- "FRD" / "Feature Request Document" / "Execution Plan" / "Tech DO's/DON'T's"
- "Solo mode" / "Team mode" (operating mode rule)
- "Codebase Index", "tech-debt autopilot"
- "Dogfooding" (when used to describe the framework's self-loop)

### File paths and structures
- `.claude/` (the entire directory and any file under it)
- `.claude/rules/`, `.claude/agents/`, `.claude/stack-*.yml`
- `<project>-context/` (any reference to the per-project meta repo)
- `templates/FRD-TEMPLATE.md`, `templates/EXECUTION-PLAN-TEMPLATE.md`, etc.
- `docs/Framework-Wiki.md`, `docs/framework-board-reference.md`
- `feature/f<N>-<desc>` branch naming convention (when describing the framework)

### Identifiers
- "AISDLC", "AI SDLC Pipeline" (the framework name), "framework board" (and its project number)
- "F1", "F2", ..., "F<N>" (framework ticket IDs)
- The phrase "AI-driven SDLC framework" or "AI-driven software development lifecycle"

## The whitelist — what you CAN say to clients

These are explicitly fine. Use them confidently:

- ✅ "We use AI heavily for code generation, testing, and review."
- ✅ "All AI-generated code goes through human code review before merging."
- ✅ "We have an internal AI-assisted development process with verification at every step."
- ✅ "Our engineers work with AI as a collaborator — they own the design and review, AI does the heavy lifting on implementation."
- ✅ "Yes, we use Claude / GPT / similar models." (naming the underlying AI is fine)
- ✅ Standard `Co-Authored-By: Claude <noreply@anthropic.com>` in commits (this is industry-standard and expected)
- ✅ The actual code, PRs, commits, and tests in the client's repos
- ✅ Engineering decisions framed in plain technical language ("we extracted the helpers into a separate module", "we added integration tests for the cancel flow")

## Sanitization pass — required for `@shipper`

Before any artifact crosses the boundary into a client-visible space, `@shipper` runs a **sanitization pass**:

1. **Scan the artifact** (commit message, PR body, release note, doc) for any string in the blacklist above
2. **If a match is found**: rewrite the offending text in plain engineering language. Do NOT just remove the word — replace it with what it actually means in normal terms:

   | Framework term | Plain rewrite |
   |---|---|
   | "verified via Verification Gate" | "tested locally with passing test output" |
   | "discovered during Size Audit" | "discovered while reviewing the file structure" |
   | "executed in autonomous mode" | "completed in this work session" |
   | "@builder produced…" | "the implementation produced…" or just "produced…" |
   | "moved through 💻 AI Development → 👀 Code Review" | "completed implementation, ready for code review" |
   | "FRD ticket #N" | "issue #N" or "ticket #N" |

3. **If a match cannot be cleanly rewritten** (e.g., the entire commit message is about a framework rule): **block the push** and escalate to the human in chat. Do not push.

4. **Posts a sanitization summary** as a comment on the framework-side ticket (NOT on the client ticket): "Sanitization pass: 3 rewrites applied (Verification Gate → test output, @builder → produced, FRD #N → issue #N). Pushed to client repo cleanly."

## What `@shipper` does NOT sanitize

- **Internal artifacts**: framework board comments, AISDLC commits, `<project>-context/` docs, internal Slack — these are inside the boundary, the framework can be named freely.
- **The codebase itself**: variable names, function names, comments inside the code — sanitization is only for *artifacts about the work*, not the work itself. Code can use whatever names make sense.

## Hard stops (sanitization can never override)

The sanitization pass cannot:
- Add false claims about our process to make it sound less AI-heavy
- Hide that AI was used (clients know — be honest)
- Misattribute AI work to a human engineer
- Strip the standard `Co-Authored-By: Claude` line (industry-standard, do not remove)

The boundary protects the *methodology*, not the *fact of AI use*.

## Escalation

If an engineer is unsure whether something is OK to share with a client:
1. Default to NOT sharing
2. Ask the project's tech lead
3. The tech lead is the only person who can grant a one-time exception, logged on the framework board

If a client asks to see "how we use AI", "your AI process", "your prompts", "your agents":
1. Say: "We have an internal AI-assisted development process. Happy to walk you through how it shows up in the code and the PRs you see."
2. Show them code, PRs, test results, code review notes, deployment process
3. Do NOT show them the framework

## What lives where (quick reference)

| Artifact | Boundary side | Sanitization needed? |
|---|---|---|
| AISDLC repo | Internal | No |
| `erp-core/`, `erp-fe/`, etc. (product code repos) | **Client-visible** | YES on commits/PRs |
| `erp-context/` (per-project meta repo) | Internal — but assess per-client | Default to internal |
| Framework board | Internal | No |
| Client tracker (Jira/YouTrack/etc.) | **Client-visible** | YES on issue bodies and comments |
| Client Slack / email | **Client-visible** | YES on talking points |
| Internal Slack | Internal | No |
| Loom videos for clients | **Client-visible** | YES — review screen content before recording |

## Why this rule lives in the framework

This isn't a personal preference — it's a business rule that protects the team's IP. It must travel with the framework so that every engineer who clones AISDLC and starts working on a project automatically inherits the discipline. There is no "I forgot to sanitize" excuse: `@shipper` runs the pass automatically.
