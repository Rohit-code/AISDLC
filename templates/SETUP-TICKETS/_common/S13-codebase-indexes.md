# S13: Populate codebase indexes via size audit

## What
Run the size audit per `.claude/rules/size-audit.md` across all code repos. Populate `<project>-context/indexes/Codebase-Index-*.md` with the results.

## Why
Codebase indexes help agents find relevant code fast without rescanning the whole codebase every session. Red-threshold files get auto tech-debt tickets. The index is re-audited on major changes.

## Steps
1. For each repo type (BE, FE, Voice, Mobile), invoke the appropriate agent:
   - `@builder` for BE → `Codebase-Index-BE.md`
   - `@fe-builder` for FE → `Codebase-Index-FE.md`
   - (Stack-specific agents for Voice, Mobile, etc.)
2. Agent measures each file/component:
   - LOC, complexity signals, red/yellow thresholds
   - Key classes/functions, responsibilities
3. Writes entries in the size-audit format (see `.claude/rules/size-audit.md`)
4. For any RED file, file a tech-debt ticket per the auto-ticket rule
5. Commits index to `<project>-context/`

## Idempotent check
```bash
ls $CONTEXT_DIR/indexes/Codebase-Index-*.md 2>/dev/null | head -1 | grep -q .
```

## Acceptance
- `Codebase-Index-BE.md` / `Codebase-Index-FE.md` / etc. exist in context repo
- Every non-trivial file has an entry (LOC, status, responsibilities)
- All RED files have accompanying tech-debt tickets
- Audit summary posted on this ticket
- Committed to context repo
