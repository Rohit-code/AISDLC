# Secrets Management (hard rule)

Leaked secrets are irreversible — once a key is in git history, it's compromised even after removal. This rule exists because live production keys committed to a repo stay exposed in git history long after they are removed, and inherited codebases often contain them.

## Never commit secrets

These must NEVER appear in a git commit, ticket comment, PR description, or any logged output:

- `.env` files (any variant: `.env`, `.env.local`, `.env.production`, `.env.staging`)
- API keys, secret keys, access tokens, private keys
- Database connection strings with passwords
- OAuth client secrets
- Webhook signing keys
- Any string that looks like `sk-`, `pk_live_`, `sk_live_`, `AKIA` (AWS), or similar provider key patterns

## Pre-work .env audit (mandatory for new repos)

When an agent touches a repo for the first time, **before any other work**:

1. Check `.gitignore` — does it include `.env`, `.env.local`, `.env*.local`?
2. Check if `.env` is tracked: `git ls-files .env`
3. Check for committed secrets in common files: `docker-compose*.yml`, deployment configs, settings files
4. If any secrets are found committed → **stop**, create a P0 ticket, and flag the human immediately

Do NOT silently fix committed secrets. The human needs to know because:
- Keys in git history are already compromised and need rotation
- The fix is multi-step (untrack, rotate, update environments)
- Other repos may have the same problem

## .env.example pattern (required per repo)

Every repo that uses environment variables must have:

```
.env.example          ← committed, safe placeholder values
.env                  ← gitignored, real values (never committed)
.env.local            ← gitignored, local overrides (never committed)
```

The `.env.example` file uses obviously fake values:
```
# ✅ Good .env.example
PAYMENT_GATEWAY_KEY_ID=test_REPLACE_ME
PAYMENT_GATEWAY_KEY_SECRET=your_test_secret_here
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# ❌ Bad .env.example (these look real)
PAYMENT_GATEWAY_KEY_ID=live_abc123xyz
API_KEY=sk-ant-api03-actualKeyHere
```

## Discovery protocol

When an agent discovers committed secrets during any work:

1. **Stop current work** — do not continue building, testing, or shipping
2. **Do NOT paste the secret in a ticket comment** — describe what was found without exposing the value
3. **Create a P0 security ticket** with:
   - Which repo and file(s) contain the leak
   - Which services are affected (e.g., "payment gateway production keys")
   - Whether the keys are in current files or only in git history
4. **Immediate fix**: add `.env` to `.gitignore` + `git rm --cached .env` to untrack (does not delete the file locally)
5. **Flag for key rotation** — the P0 ticket must note that committed keys need rotation even after removal, because they remain in git history
6. **Resume original work** only after the immediate fix (gitignore + untrack) is applied

## Hard stops for agents

Agents must NEVER:
- Echo, print, log, or paste real API keys in any output
- Include secrets in commit messages or PR descriptions
- Include secrets in ticket comments (describe the leak, don't show the key)
- Copy `.env` content between repos without checking if destination has `.gitignore`
- Use `git add .` or `git add -A` in repos that might have `.env` files — always add specific files

## Docker Compose pattern

Docker Compose files must use `env_file` instead of inline environment variables for secrets:

```yaml
# ✅ Good
services:
  web:
    env_file:
      - .env
    environment:
      DEBUG: "1"                    # non-secret config is fine inline
      POSTGRES_HOST: postgres       # service names are fine inline

# ❌ Bad
services:
  web:
    environment:
      PAYMENT_GATEWAY_KEY: live_abc123
      CLAUDE_API_KEY: sk-ant-...
```

## Who this applies to

All agents, at all times. This is not a build-stage rule — it applies during planning (@planner checking deployment configs), building (@builder/@fe-builder), testing (@tester creating fixtures), and shipping (@shipper writing deployment docs).
