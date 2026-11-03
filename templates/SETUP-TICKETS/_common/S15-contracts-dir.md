# S15: Create API/event contracts directory in context repo

## What
Create `<project>-context/contracts/` directory. Agents populate it as API contracts (OpenAPI 3.0) or event schemas (for realtime/voice) are published during planning.

## Why
Contracts are the single source of truth for BE/FE (or client/server) interfaces. Having a known location means agents don't invent new locations per feature.

## Steps
1. `mkdir <project>-context/contracts`
2. Add `.gitkeep` so the directory is tracked
3. Add `README.md` describing what goes here:
   - OpenAPI 3.0 YAML files for REST APIs
   - AsyncAPI or custom event schemas for realtime/voice
   - One file per feature or per domain (not per endpoint)
4. Update context repo CLAUDE.md to point to the contracts directory
5. Commit and push

## Idempotent check
```bash
test -d "$CONTEXT_DIR/contracts"
```

## Acceptance
- `<project>-context/contracts/` exists
- README.md present explaining conventions
- Committed
