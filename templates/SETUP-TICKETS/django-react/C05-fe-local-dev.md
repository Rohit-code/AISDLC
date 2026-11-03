# C5: FE local dev setup (per FE repo)

## What
Each FE repo gets its own `.env.example`, `.gitignore` updates for `.env`, CLAUDE.md, and runnable `npm run dev`.

## Why
Projects of this type often have multiple FE repos (e.g. customer app, admin panel, internal tools). Each is independent and needs its own setup. Using the cross-repo-batch pattern from `.claude/rules/agent-communication.md`.

## Steps
For each FE repo:

1. **`.env.example`** — placeholder values:
   ```
   VITE_API_BASE_URL=http://localhost:8000
   VITE_PUBLIC_APP_NAME=<project>-<variant>
   ```

2. **`.gitignore`** — ensure `.env`, `.env.local` excluded

3. **`CLAUDE.md`** — stack (React/Next version, Tailwind version, state mgmt), local setup, test command, conventions

4. **Verify `npm run dev`**:
   - `cp .env.example .env && npm install && npm run dev`
   - Should launch on `localhost:5173` (Vite) or `localhost:3000` (Next)

5. **Commit** — one branch per repo, per `feature/<ticket-id>-fe-local-dev-setup`

## Idempotent check
```bash
test -f $FE_REPO/.env.example && test -f $FE_REPO/CLAUDE.md
```

## Acceptance
- Every FE repo has `.env.example`, updated `.gitignore`, `CLAUDE.md`
- `npm run dev` works on fresh clone
- Committed per repo on feature branch

## Cross-repo batch pattern
Apply this identically across all FE repos per `.claude/rules/agent-communication.md` cross-repo batch work section. One status update summarizing all repos.
