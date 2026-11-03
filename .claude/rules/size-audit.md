# Size Audit & Tech-debt Auto-ticketing

When an AI agent is about to plan or build against code it hasn't touched before, it **must first measure** the target files. Size is the earliest signal of hidden scope, and catching it up-front beats discovering it mid-build. This rule is invoked by `@planner` (before execution planning) and `@builder` / `@tester` (before coding).

## Thresholds — Backend

| Artifact | Yellow (note) | Red (auto tech-debt ticket) |
|----------|---------------|------------------------------|
| Single file | > 800 LOC | > 1500 LOC |
| Single class | > 300 LOC | > 600 LOC |
| Single method / endpoint handler | > 60 LOC | > 150 LOC |
| Endpoints on one controller | > 15 | > 25 |
| Fields on one entity | > 20 | > 40 |
| Side effects in one save / service method | > 3 | > 6 |
| Cyclomatic-ish: nested ifs in one function | > 4 | > 6 |

## Thresholds — Frontend

| Artifact | Yellow (note) | Red (auto tech-debt ticket) |
|----------|---------------|------------------------------|
| Single component file | > 200 LOC | > 300 LOC |
| Single screen/page file | > 500 LOC | > 800 LOC |
| Single hook file | > 100 LOC | > 200 LOC |
| API wrapper file (per domain) | > 200 LOC | > 400 LOC |
| State / store file | > 300 LOC | > 600 LOC |
| Inline styles / hardcoded colors | > 3 instances | > 10 instances (should use tokens) |
| Props on one component | > 10 | > 15 (split or compose) |
| useEffect hooks in one component | > 3 | > 5 (extract to custom hook) |

FE thresholds are lower than BE because components should be small and composable. A 300-LOC component is doing too many things — extract sub-components or custom hooks. A 800-LOC screen is a "god screen" with modals, filters, and data fetching all in one file (a dashboard page that holds everything is the usual example).

## Adapting thresholds to other stacks

These thresholds are starting points, not stack-specific truths. When using AISDLC on a new project:
- Read the stack file (`.claude/stack-be.yml` / `.claude/stack-fe.yml`) to know the tech stack
- Use the closest threshold table above as a starting point
- Adjust based on the stack's idioms (e.g., Java service classes in Spring Boot tend to run longer than Next.js components; a Next.js `page.tsx` that also holds data fetching and modals is a screen, not a component)
- Document any project-specific overrides in the project's `CLAUDE.md`

These are floors, not ceilings — the agent uses judgement. A 900-line file that's a pure data table is fine; a 400-line method with 6 unrelated side effects is not.

## The Audit Step (mandatory)

Before planning or building, the agent runs a **one-minute survey** of the files in scope and posts a comment on the ticket:

```
### Size audit
**Agent**: @agent-name | **Date**: YYYY-MM-DD

| File | LOC | Notable |
|------|-----|---------|
| billing/InvoiceController.java | 2400 | 45 endpoints on one controller |
| billing/InvoiceService.java | 1600 | save path writes 7 side tables |
| billing/InvoiceHelpers.java | 1900 | 40+ static methods |

**Verdict**: 🔴 RED — scope is 3–5x what the ticket implies.
**Action**: Pausing ticket work. Posting scope question + creating tech-debt ticket(s).
```

The audit comment is short and purely factual — numbers, not opinions.

## Auto-ticket Rule (hard)

When the audit hits **any red threshold**, the agent MUST:

1. **Pause the current ticket** — do not proceed past the audit until a scope decision is made.
2. **Post a scope question** on the current ticket naming the gap between ticket assumption and reality.
3. **Create a tech-debt ticket** with label `tech-debt` — in 📥 Backlog in team mode, 📝 FRD Draft allowed in solo mode — using the Tech-debt Observation format from `agent-communication.md`. One ticket per distinct debt — do not bundle ("split `InvoiceController`" and "extract the save-path side effects" are two tickets, not one).
4. **Link** the tech-debt ticket back to the current ticket (`Discovered during #N`).
5. **Propose a narrowed scope** for the current ticket that stays inside a single-session budget (see Complexity Budget below) and wait for Product to confirm.

The current ticket is NOT blocked on the tech-debt work landing — it's blocked on the scope decision. Once Product confirms the narrowed scope, the agent resumes.

Yellow thresholds do NOT auto-create a ticket — they get a one-line note in the audit comment ("⚠️ `billing/InvoiceService.java` is 900 LOC, watch for growth" or "⚠️ `app/invoices/page.tsx` is 550 LOC, watch for growth") and the agent continues.

## Scope-discrepancy escalation (hard rule)

Size audit is the pre-work check. **Scope discrepancy** is the mid-work check. If an agent is already building and discovers the actual work is materially larger than the ticket implied, it must stop and escalate — not silently absorb the extra scope.

**Trigger**: any of the following mid-build:
- Files/LOC touched is trending toward > 2× the complexity budget (so >1000 LOC or >16 files)
- A new monolith is discovered that wasn't in the planner's audit
- Dependent refactors appear (e.g., "I can't add this test without first extracting helper X")
- The ticket's acceptance criteria can only be met by touching code outside the ticket's stated scope

**Required action**: post a "Scope discrepancy" question on the ticket using the format in `agent-communication.md`, pause, and wait for Product. Propose 2–3 options (narrow the ticket, split into N tickets, absorb the scope). Do not keep building past the discrepancy.

This is distinct from the up-front size audit: the audit catches obvious monoliths before work starts; discrepancy escalation catches the cases where the audit looked clean but the complexity hid one layer deeper.

## Size-audit artifact lives in the codebase index

The first audit of any file gets mirrored into `<project>-context/indexes/Codebase-Index-BE.md` (or `-FE.md`) so future agents read it there instead of re-auditing. Entry format:

```
### billing/InvoiceController.java
- **LOC**: 2400  **Status**: 🔴 RED
- **Key classes**: InvoiceController (45 endpoints)
- **Responsibility**: Invoice lifecycle, credit notes, export
- **Tech-debt tickets**: #<N> (split controller)
- **Last audit**: YYYY-MM-DD by @builder during #<N>
```

Agents consult the index before touching a file. If the index says 🔴 RED and there's no open tech-debt ticket, create one before proceeding. If the file has changed materially since the last audit, re-audit and update the entry.

## Complexity Budget (per ticket)

A single ticket's work should stay inside roughly:
- **≤ 500 LOC** changed (added + modified), excluding generated code and fixtures
- **≤ 8 files** touched
- **≤ 1 session** to build + verify

If the audit says we can't fit — split the ticket. Example: a ticket asking for test coverage of a 45-endpoint controller is far beyond budget; the audit step should force the split into follow-ups, not a failing test run later.

## Don't test a monolith, split-adjacent — flag it

Adding tests to a red-threshold file without a planned refactor **locks the monolith in**: the tests become a cost on any future split. When the audit flags a red file as the test target, the agent must either:

- (a) Get explicit Product approval to "test as-is, accept the lock-in", logged as a decision, OR
- (b) Propose a thin test surface (service-level + a few endpoints) alongside a tech-debt ticket to split the file, so the tests migrate with the split.

This is not about perfection — it's about not shipping tests that make future cleanup harder without saying so out loud.

## Who this applies to

- `@planner` runs the audit before generating an execution plan. Planner's audit is the strongest gate — this is where scope should be right-sized.
- `@builder` / `@tester` / `@fe-builder` re-run the audit before coding. If the builder's audit disagrees with the planner's, that's a signal the plan is stale — pause and comment.
- `@shipper` does not run this audit (it's deploy-stage).
