# J09: FE API types from OpenAPI (openapi-typescript)

## What
Generate TypeScript types for each FE from the approved contracts in `<project>-context/contracts/` with `openapi-typescript`. The FE's own fetch helper uses these types; no generated client.

## Why
Hand-written response types drift from the contract. Generated types turn a contract change into a `tsc --noEmit` error. The BE's live spec (J05) lets anyone check the implementation still matches the contract.

## Steps
For each FE repo:
1. `npm i -D openapi-typescript`
2. `package.json` scripts:
   ```json
   "gen:api": "openapi-typescript ../<project>-context/contracts/<feature>.yaml -o src/lib/api/<feature>.d.ts"
   ```
   (one entry per contract file, or a small script looping over `contracts/*.yaml`)
3. Commit the generated `.d.ts` files so builds don't need the context repo
4. Drift check against the running BE (dev only):
   ```bash
   npx openapi-typescript http://localhost:8080/v3/api-docs -o "${TMPDIR:-/tmp}/live-api.d.ts"
   ```
   then compare the types the feature uses
5. Document `npm run gen:api` in FE `CLAUDE.md`

## Idempotent check
```bash
grep -q "openapi-typescript" "$FE_REPO/package.json" 2>/dev/null
```

## Acceptance
- `npm run gen:api` produces valid TypeScript from at least one contract
- Generated types used in real code (the API wrapper), not sitting unused
- `npx tsc --noEmit` passes
- Committed

## Depends on
- S15 (contracts directory exists)
- J05 (BE serves its spec)
- J06 (FE local dev setup)
