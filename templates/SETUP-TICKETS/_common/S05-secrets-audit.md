# S5: Pre-work secrets audit

## What
Run the secrets audit per `.claude/rules/secrets-management.md` against every cloned repo. Flag any committed secrets. Fix `.gitignore` if missing `.env` entries.

## Why
**P0 safety**. Committed production keys are common in inherited repos, and one leaked key can cost more than the whole engagement. This audit has to run before any other work touches the repos.

## Steps

For each repo:

1. Check `.gitignore` contains `.env`, `.env.local`, `.env.*.local`
2. Check `.env` is not tracked: `git ls-files .env` → must be empty
3. Scan committed files for key patterns:
   - `sk-`, `pk_live_`, `sk_live_`, `AKIA`, `ghp_`, `sk-ant-api03-`
   - Common files: `docker-compose*.yml`, `application*.yml`, `application*.properties`, `settings*.py`, `config*.js`, `next.config.*`, `.env*`
4. If secrets found:
   - **STOP** — do not paste keys in ticket comments
   - Create separate P0 ticket naming affected files and services (not the keys)
   - Flag the human for immediate key rotation
5. If `.env` is tracked: untrack with `git rm --cached .env` (file stays locally)
6. Commit `.gitignore` fixes

## Idempotent check
```bash
grep -qxF .env "$MAIN_REPO/.gitignore" 2>/dev/null && ! git -C "$MAIN_REPO" ls-files --error-unmatch .env >/dev/null 2>&1
```

## Acceptance
- `.env` in `.gitignore`
- `.env` not tracked in git
- No live secrets found in committed files (or P0 ticket created)
- Audit result logged on ticket
