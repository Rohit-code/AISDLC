# S12: Generate Tech Architecture docs

## What
Generate tech architecture doc(s) for the project. Per stack — BE and FE for web stacks, Voice for realtime, Mobile for apps, etc.

## Why
Tech Architecture captures design decisions, module boundaries, data flow, and non-obvious integration patterns. Agents reference it when planning. Without it, @planner has to re-derive architecture every session.

## Steps
1. Identify architecture scopes from stack config (typically: BE, FE, Voice, Mobile)
2. For each scope, invoke `@planner` in architecture mode
3. Agent generates from codebase scan + Product Wiki:
   - `<project>-context/docs/TECH-Architecture-BE.md`
   - `<project>-context/docs/TECH-Architecture-FE.md`
   - (Voice/S2S: covered by V2 in voice-s2s variant)
4. Each doc covers:
   - **Overview** — high-level components and relationships
   - **Module layout** — modules/packages and their responsibilities
   - **Data flow** — request lifecycle, queue processing, batch jobs
   - **External integrations** — 3rd-party APIs, auth providers, CDNs
   - **Design decisions** — why this pattern vs alternatives
   - **Conventions** — error handling, logging, testing
5. Commit to the context repo

## Idempotent check
```bash
ls "$CONTEXT_DIR"/docs/TECH-Architecture-*.md >/dev/null 2>&1
```

## Acceptance
- Tech Architecture doc(s) exist in `<project>-context/docs/`
- At least one doc per stack scope (BE, FE, Voice, etc.)
- Committed
- Depth: a new engineer can understand the architecture in 30 minutes
