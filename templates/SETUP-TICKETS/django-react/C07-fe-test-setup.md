# C7: FE vitest or jest setup (per FE repo)

## What
Each FE repo gets a working test runner — vitest (Vite-based) or jest (Next.js/CRA). Component testing with testing-library.

## Why
Verification gate applies to FE too. Without a test runner, every FE ticket goes unverified.

## Steps
For each FE repo:

**Vite-based (vitest)**:
1. `npm i -D vitest @testing-library/react @testing-library/jest-dom jsdom`
2. Add to `vite.config.ts`:
   ```ts
   test: {
     environment: 'jsdom',
     globals: true,
     setupFiles: ['./src/test/setup.ts'],
   }
   ```
3. Create `src/test/setup.ts` with `import '@testing-library/jest-dom'`
4. Add `"test": "vitest"` to `package.json` scripts

**Next.js (jest)**:
1. `npm i -D jest jest-environment-jsdom @testing-library/react @testing-library/jest-dom`
2. `npx create-jest` or hand-write `jest.config.js`
3. Add `"test": "jest"` to package.json

**Both**:
4. Write one smoke test in `src/test/App.test.tsx`
5. Verify: `npm test` passes
6. Document in FE CLAUDE.md

## Idempotent check
```bash
grep -qE 'vitest|jest' $FE_REPO/package.json
```

## Acceptance
- Test runner installed per FE
- `npm test` runs and shows at least 1 passing test
- Config committed
- Documented in CLAUDE.md
