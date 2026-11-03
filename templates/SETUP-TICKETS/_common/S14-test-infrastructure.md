# S14: Test infrastructure — runnable test command

## What
Every repo must have a working test runner — pytest for Python, vitest/jest for JS, go test for Go, etc. Test command documented in CLAUDE.md.

## Why
Verification gate (hard rule): no ticket moves to Code Review without pasted test output. If there's no test runner, there's no way to verify. This ticket unblocks all future AI-development tickets.

## Steps
Per stack:

**Python/Django (django-react)**:
1. Install pytest, pytest-django, factory-boy
2. Add `pyproject.toml` or `pytest.ini` config
3. Create `tests/` directory with `conftest.py` + `factories.py`
4. Add `settings_test.py` (follow the repo's existing test settings pattern)
5. Verify: `pytest --collect-only` discovers tests

**React/Next (django-react)**:
1. Install vitest or jest + testing-library
2. Add test config to `vite.config.ts` or `jest.config.js`
3. Create `src/test/setup.ts`
4. Verify: `npm test` runs

**Voice/Realtime (voice-s2s)**:
1. See V4 — voice test infra is different (audio fixtures + mock Realtime API)

## Idempotent check
```bash
grep -qE 'pytest|vitest|jest|go test' $MAIN_REPO/package.json $MAIN_REPO/pyproject.toml $MAIN_REPO/requirements*.txt 2>/dev/null
```

## Acceptance
- Test runner installed
- `make test` or `npm test` or `pytest` works from repo root
- At least one passing test (smoke test) — proves infra works
- Command documented in repo CLAUDE.md
- Committed
