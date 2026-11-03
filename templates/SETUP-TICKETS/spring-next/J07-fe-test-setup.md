# J07: FE Vitest + Testing Library + `tsc --noEmit` (per FE repo)

## What
Each FE repo gets Vitest with Testing Library (jsdom) for component tests and a type check with `tsc --noEmit`.

## Why
Verification Gate applies to FE too. Vitest runs targeted files fast; the type check catches contract drift the tests miss.

## Steps
For each FE repo:
1. `npm i -D vitest @vitejs/plugin-react jsdom @testing-library/react @testing-library/jest-dom`
2. `vitest.config.ts`:
   ```ts
   import { defineConfig } from 'vitest/config';
   import react from '@vitejs/plugin-react';
   import { fileURLToPath } from 'node:url';

   export default defineConfig({
     plugins: [react()],
     resolve: { alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) } },
     test: {
       environment: 'jsdom',
       globals: true,
       setupFiles: ['./src/test/setup.ts'],
     },
   });
   ```
3. `src/test/setup.ts`: `import '@testing-library/jest-dom/vitest';`
4. `package.json` scripts: `"test": "vitest run"`, `"typecheck": "tsc --noEmit"`
5. One smoke test, e.g. `src/test/smoke.test.tsx` rendering a real component
6. Record the per-ticket commands in the stack file and FE `CLAUDE.md`:
   ```bash
   npx vitest run --maxWorkers=2 <files>
   npx tsc --noEmit
   ```
   Run specific files only, never a wide sweep. Follow the repo's testing conventions (ERP: `fireEvent`, no user-event, no msw).

## Idempotent check
```bash
grep -q "\"vitest\"" "$FE_REPO/package.json" 2>/dev/null && ls "$FE_REPO"/vitest.config.* >/dev/null 2>&1
```

## Acceptance
- `npx vitest run --maxWorkers=2 src/test/smoke.test.tsx` passes
- `npx tsc --noEmit` passes
- Commands recorded in the stack file and `CLAUDE.md`
- Committed
