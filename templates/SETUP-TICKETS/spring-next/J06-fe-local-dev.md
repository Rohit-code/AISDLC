# J06: FE local dev setup (per FE repo)

## What
Each Next.js repo gets its own `.env.example`, `.gitignore` entries for `.env*`, `CLAUDE.md`, and a working `npm run dev`.

## Why
Each FE repo is independent and needs its own setup. Apply it the same way across all FE repos (cross-repo batch pattern in `.claude/rules/agent-communication.md`).

## Steps
For each FE repo:
1. **`.env.example`** — placeholder values:
   ```
   NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
   NEXT_PUBLIC_APP_NAME=<project>-<variant>
   ```
   Only values safe to ship to the browser get the `NEXT_PUBLIC_` prefix.
2. **`.gitignore`** — `.env`, `.env.local`, `.env.*.local` excluded
3. **`CLAUDE.md`** — stack (Next.js 15 App Router, React 19, TypeScript, Tailwind version), local setup, test commands (J07), default branch, conventions (data fetching helper, list/paging hooks, rem only)
4. **Verify**: `cp .env.example .env.local && npm ci && npm run dev` → app on `localhost:3000`
5. **Commit** on `feature/<ticket-id>-fe-local-dev-setup`, PR to the default branch

## Idempotent check
```bash
test -f "$FE_REPO/.env.example" && test -f "$FE_REPO/CLAUDE.md"
```

## Acceptance
- Every FE repo has `.env.example`, updated `.gitignore`, `CLAUDE.md`
- `npm run dev` works on fresh clone
- Committed per repo on a feature branch
