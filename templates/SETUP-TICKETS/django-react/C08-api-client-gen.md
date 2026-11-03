# C8: Cross-repo API client generation from OpenAPI contracts

## What
Auto-generate typed API clients for each FE from the OpenAPI contracts in `<project>-context/contracts/`. Regenerate on contract change.

## Why
Hand-written API clients drift from the contract. Generated clients stay in lockstep. BE changes the contract → FE codegen picks up → type errors surface immediately.

## Steps

1. **Choose generator** (by FE stack):
   - TypeScript: `openapi-typescript` (lightest, emits types only) or `openapi-ts` (full clients)
   - Universal: `openapi-generator-cli` (heavy, many targets)

2. **For each FE repo**:
   - Install: `npm i -D openapi-typescript`
   - Add script to `package.json`:
     ```json
     "scripts": {
       "gen:api": "openapi-typescript ../<project>-context/contracts/openapi.yaml -o src/api/generated.ts"
     }
     ```
   - Add to `.gitignore` or commit per your preference (usually commit for reproducibility)
   - Document in FE CLAUDE.md

3. **Optional**: add to `package.json` postinstall or a pre-commit hook

4. **Verify**: `npm run gen:api` produces valid TypeScript

## Idempotent check
```bash
grep -qE "openapi-typescript|openapi-generator" "$FE_REPO/package.json" 2>/dev/null
```

## Acceptance
- Codegen script works on at least one contract file
- Generated client types used in actual code (not just sitting unused)
- Documented in FE CLAUDE.md
- Committed

## Depends on
- S15 (contracts directory exists)
- C5 (FE local dev setup)
