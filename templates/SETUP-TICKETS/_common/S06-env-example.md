# S6: Add `.env.example` with safe placeholders

## What
Every repo that uses environment variables must have a committed `.env.example` with obviously-fake placeholder values.

## Why
Engineers need a starting point for their local `.env`. Without `.env.example`, setup becomes tribal knowledge. With real-looking values in `.env.example`, people commit them thinking they're fake. So placeholders must be obviously fake.

## Steps
1. For each repo that loads env vars, derive the list of required vars (grep for `os.environ`, `process.env`, `import.meta.env`)
2. Write `.env.example` with entries like:
   ```
   # ✅ Good placeholders — obviously fake
   DATABASE_URL=postgresql://user:password@localhost:5432/dbname
   API_KEY=your_api_key_here
   PAYMENT_GATEWAY_KEY_ID=test_REPLACE_ME

   # ❌ Bad — looks real
   # API_KEY=sk-ant-api03-actualKeyHere
   ```
3. Commit `.env.example`
4. Update repo CLAUDE.md to point new engineers at it

## Idempotent check
```bash
test -f $MAIN_REPO/.env.example
```

## Acceptance
- `.env.example` exists in every repo that needs env vars
- All real env var names are covered
- All values are obviously-fake placeholders
- Committed to repo
