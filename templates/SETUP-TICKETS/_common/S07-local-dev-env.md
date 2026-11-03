# S7: Local dev environment — one-command startup

## What
Every project must have a one-command local dev setup so agents (and humans) can run the app and verify their changes.

## Why
**Hard rule from CLAUDE.md**: agents need to verify their work. Without a runnable local env, verification gate fails and builds accumulate silent bugs. Without it, tickets stall for days on "I can't test this locally."

## Steps
Pick the pattern that matches the stack:

**Docker Compose (BE services, DB, queues)**:
1. Write `docker-compose.yml` with services, networks, env_file references
2. Use `env_file: .env` — never inline secrets
3. Document `docker compose up -d` in CLAUDE.md
4. Verify: `docker compose up -d && curl localhost:<port>/health` returns 200

**Makefile (simpler stacks)**:
1. Write `Makefile` with `make dev`, `make test`, `make lint` targets
2. Document in CLAUDE.md

**npm / pnpm scripts (FE-only)**:
1. Ensure `package.json` has `dev`, `build`, `test`, `lint` scripts
2. Document `npm install && npm run dev` in CLAUDE.md

## Idempotent check
```bash
test -f $MAIN_REPO/docker-compose.yml || test -f $MAIN_REPO/Makefile
```

## Acceptance
- One command starts the whole app locally
- Command works from a fresh clone after `.env` is filled from `.env.example`
- Documented in repo CLAUDE.md
- Verification: engineer can `cd <repo> && <command>` and see it running
