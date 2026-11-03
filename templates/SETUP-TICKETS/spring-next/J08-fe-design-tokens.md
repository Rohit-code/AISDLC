# J08: FE rem-based design tokens + no-px test (per FE repo)

## What
Design tokens (colors, spacing, type scale, radius) in Tailwind config / CSS variables, every size in `rem`. A Vitest test fails when a source file hard-codes `px`.

## Why
The root font-size is the single scale knob (often a fluid `clamp()`). A `px` value freezes that element out of it, so screens drift from the design at other widths. A test catches it on every ticket instead of in visual review.

## Steps
1. Tokens from the project's design boards into `tailwind.config.ts` (`theme.extend`) and/or CSS variables in `src/app/globals.css` — all in `rem`
2. Set the root font-size once in `globals.css` (`html { font-size: ... }`)
3. Create `src/test/no-px.test.ts`:
   ```ts
   import { readFileSync, readdirSync, statSync } from 'node:fs';
   import { join, relative } from 'node:path';
   import { describe, expect, it } from 'vitest';

   const SRC = join(__dirname, '..');
   // Files allowed to keep px, each with a reason. Keep it empty if you can.
   const ALLOW = new Set<string>([]);

   function sourceFiles(dir: string): string[] {
     return readdirSync(dir).flatMap((name) => {
       const path = join(dir, name);
       if (statSync(path).isDirectory()) return sourceFiles(path);
       return /\.(tsx?|css)$/.test(name) && !/\.test\.tsx?$/.test(name) ? [path] : [];
     });
   }

   describe('design tokens', () => {
     it('uses rem, never hard-coded px', () => {
       const offenders = sourceFiles(SRC)
         .filter((file) => !ALLOW.has(relative(SRC, file)))
         .flatMap((file) =>
           readFileSync(file, 'utf8')
             .split('\n')
             .map((line, i) => ({ file: relative(SRC, file), line: i + 1, text: line }))
             .filter(({ text }) => /(^|[^\w-])\d*\.?\d+px\b/.test(text)),
         )
         .map(({ file, line }) => `${file}:${line}`);
       expect(offenders).toEqual([]);
     });
   });
   ```
4. Mutation-prove it: add `padding: 4px` to a component, see the test go red, remove it
5. Note "rem only; tokens from the design boards" in FE `CLAUDE.md`

## Idempotent check
```bash
test -f "$FE_REPO/src/test/no-px.test.ts"
```

## Acceptance
- Tokens in `rem`, sourced from the design boards
- `npx vitest run --maxWorkers=2 src/test/no-px.test.ts` passes, and fails when a `px` value is added
- Committed
