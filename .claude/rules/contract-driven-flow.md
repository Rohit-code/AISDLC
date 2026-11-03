# Contract-Driven Feature Flow

Hard rules for how features flow through the pipeline when they touch both backend and frontend (the default shape for API + FE projects).

These rules exist because three failure patterns kept recurring:

- BE ships an endpoint, FE starts building against it, then discovers the response shape doesn't match what they assumed.
- Planner produces a contract without FE input; FE hits impedance on day 2 of implementation.
- Migrations and data-backfill needs surface late, after the feature is already in AI Development.

---

## Rule 1 — Parent ticket structure (required)

Every feature of non-trivial size has **one parent ticket** on the project board. The parent ticket body must contain these sections (enforced by `@planner` in FRD drafting and `@ticket-manager` in column transitions):

### Required sections

| Section | Purpose |
|---|---|
| **Problem + user story** | What's being solved, in user terms. |
| **Scope** | What's IN this feature. |
| **Out-of-scope** | What's NOT. Prevents scope creep. |
| **Acceptance criteria** | Testable "given / when / then" per `size-audit.md` complexity bounds. |
| **Affected surfaces** | BE endpoints (new/changed), FE screens / flows (new/changed), DB models / migrations, external integrations. |
| **Migration / gap callouts** | Data migrations? Schema expand/contract? Env-vars / secrets additions? Feature flags? Rollout plan? |

If any of the **Migration / gap callouts** dimension is unknown at FRD time, `@planner` asks Product as a **ticket comment** (not a chat interruption) and waits for clarification before producing the execution plan.

### Template

The canonical FRD template in `templates/FRD-TEMPLATE.md` includes all these sections. Use it as-is.

---

## Rule 2 — Three linked sub-issues per feature

Every feature parent ticket that touches both BE and FE spawns **three sub-issues** (via GitHub sub-issue linking, per F32 `agent-communication.md` parent-sub pattern):

| Sub-issue | Title pattern | Assigned to | Purpose |
|---|---|---|---|
| **Contract** | `[Contract] <feature>` | **BOTH** BE dev and FE dev | Validation gate — see Rule 3 |
| **BE** | `[BE] <feature>` | BE dev / `@builder` | Backend implementation |
| **FE** | `[FE] <feature>` | FE dev / `@fe-builder` | Frontend implementation |

The `@planner` creates all three at the end of FRD Tech Plan mode, linking them to the parent.

### When a feature is BE-only or FE-only

Spawn only the relevant sub-issue(s). The Contract sub-issue is optional for internal-only BE changes (no FE consumer). For FE-only UI changes without backend changes, no Contract sub-issue needed.

### When a feature touches more than BE + FE

Add more sub-issues as needed (e.g., `[Infra] <feature>`, `[Ops] <feature>`). The three above are the default minimum for API + FE work; always use real sub-issues, not a flat list.

---

## Rule 3 — Contract validation gate (before any build)

**No code is written until both BE and FE explicitly approve the contract.** This is the single most important rule in this file.

### What the contract is

A YAML file at `<project>-context/contracts/<feature>.yaml` following `templates/API-CONTRACT-TEMPLATE.yaml` (OpenAPI 3.0). Contains:

- Request shapes (per endpoint, per method).
- Response shapes (success + error).
- Error schema (consistent across endpoints).
- Permission matrix (who can call what).
- Field naming conventions (must match FE's expectations).

### The gate

1. `@planner` drafts the contract during FRD Tech Plan mode.
2. `@planner` commits the contract to `<project>-context/contracts/<feature>.yaml`.
3. `@planner` posts a comment on the **Contract sub-issue** summarizing the contract and tagging both BE and FE owners.
4. **BOTH** BE dev and FE dev leave an approval comment on the Contract sub-issue. Approval = "reviewed, request/response shapes work for my side, permission matrix clear, error schema agreed, field naming aligned."
5. Once both have approved, the Contract sub-issue is closed. Only then can the parent ticket move **🔧 Tech Plan Approved → 💻 AI Development**. `@ticket-manager` blocks premature transitions.

### What counts as approval

A comment like: `Approved (BE): response shapes work; no permission questions.` or `Approved (FE): field naming aligned; OK on error schema.`

### If either side raises issues

Don't approve. Leave a comment with specifics:
- `BE concern: the `updated_at` field should be a Unix timestamp, not ISO string — existing endpoints use Unix.`

`@planner` updates the contract, re-pushes, re-requests approval. Rinse and repeat.

### Who approves in solo mode

In solo mode, the human operator approves both sides (or explicitly delegates via chat: *"solo-mode approval: contract looks good"*). The gate still exists; it just collapses to one human reviewing the contract with both BE and FE lenses.

---

## Rule 4 — TDD enforcement on both sides

Once the contract validation gate passes and the parent ticket is in **💻 AI Development**, `@tester` runs **before** any `@builder` or `@fe-builder` writes production code. `@fe-builder` starts only after `@tester` has committed the FE tests.

### BE side

- Backend tests in the stack's test framework (JUnit 5 / Spring Boot Test for erp-core) covering contract happy path, error cases, permissions.
- Tests fail initially (no implementation yet). If they pass without implementation, the test is wrong.

### FE side

- Component tests in the stack's FE test framework (Vitest + Testing Library for erp-fe), with API responses mocked per the contract.
- Integration tests for screens that compose multiple contract endpoints.
- Tests fail initially.

### Enforcement

`@tester` creates the ticket's `feature/<id>-<slug>` branch, commits failing tests to it, and signals handoff; builders continue on that same branch (`.claude/rules/source-control.md`). Handoff message on the ticket: *"Tests written, failing as expected, ready for `@builder` / `@fe-builder`."* If either builder finds missing test coverage for a contract case mid-implementation, they pause and ask `@tester` to extend — they don't silently add tests for the thing they just implemented.

---

## Rule 5 — Migration / gap callouts (required at FRD time, re-validated at build time)

Parent ticket must have a populated **Migration / gap callouts** section by the time it exits 🤖 FRD Tech Plan. `@planner` populates it.

### Re-validation

`@builder` re-reads this section at the start of 💻 AI Development. If gaps surface that weren't in the plan:

- If it's a **known unknown** (one of the existing callouts is fuzzier than expected): continue, post a clarification comment, proceed.
- If it's a **new discovery** (a migration or env-var not in the FRD): trigger `scope-discrepancy escalation` per `size-audit.md`. Pause, post a scope question on the parent ticket, wait for Product / triage.

### Common callout categories

- **Data migrations** — backfills, one-off scripts, idempotent retries.
- **Schema migrations** — expand/contract pattern (add new, migrate, remove old in a later release); in ERP, Flyway numbers per `.claude/rules/erp-guardrails.md`.
- **Env vars / secrets** — what's new? How does staging/prod get them?
- **Feature flags** — is this gated? Who owns flag lifecycle?
- **Rollout plan** — all at once? Gradual? Shadow deploy?
- **Rollback plan** — if this breaks, how do we undo it? (Critical for schema changes.)

---

## Interaction with other rules

- **`kanban-workflow.md`**: sub-issue creation happens at 🤖 FRD Tech Plan transition out. Contract gate blocks 🔧 Tech Plan Approved → 💻 AI Development.
- **`size-audit.md`**: re-validation at build time (Rule 5) triggers size-audit's scope-discrepancy escalation if gaps surface late.
- **`ticket-discipline.md` Rule 1**: parent + 3 sub-issues is "board-first" multiplied by 4 — all exist before any code is touched.
- **`ticket-discipline.md` Rule 3**: every contract approval, gate crossing, and handoff is dual-channel (ticket comment + chat summary).
- **`agent-communication.md`** / **`gh-recipes.md`**: parent/sub-issue linking via real GitHub issues, never draft items (F32).
- **`secrets-management.md`**: migration callouts include env-var additions; secrets audit pattern applies.

---

## Enforcement responsibility

| Agent | Responsibility |
|---|---|
| `@planner` | Drafts FRD with all required sections (Rule 1). Creates parent + 3 sub-issues (Rule 2). Publishes contract, requests approval (Rule 3). Populates migration callouts (Rule 5). |
| `@tester` | TDD enforcement on both sides before any build (Rule 4). |
| `@ticket-manager` | Blocks 🔧 Tech Plan Approved → 💻 AI Development until the contract gate passes (Rule 3). Validates migration callouts present before allowing gate to close (Rule 5). |
| `@builder` / `@fe-builder` | Re-read migration callouts at build start (Rule 5). Trigger scope-discrepancy if gaps surface. |

---

## When to skip this flow

- Pure-doc PRs, CI-only changes, dependency bumps — file a ticket (per `ticket-discipline.md` Rule 1), skip parent-sub structure, skip contract gate.
- Bug fixes with no new contract surface — one ticket is enough. The contract hasn't changed; the fix just makes the existing contract actually hold.
- Hotfix lane (🚨 Hotfix) — urgency trumps ceremony: ticket first (in 🚨 Hotfix), fix, FRD written retroactively after; no contract gate (`.claude/rules/kanban-workflow.md`, Hotfix Flow).

If you're tempted to skip this flow for something that *is* a real feature: don't. The gate exists because skipping it on "small" features is how mid-build rework happens.

---

## Learned from

- Recurring mismatches between BE and FE in API + FE projects.
- Requirement (F39 / F40): both BE and FE validate the contract before development starts.
- BE work often splits cleanly from its FE consumers once the contract is fixed.
