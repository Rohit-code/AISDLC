# S14: Test infrastructure — runnable test command

## What
Every repo must have a working test runner, and its per-ticket test command recorded in the stack file (`test.per_ticket`) and the repo's CLAUDE.md.

## Why
Verification Gate (full text: `.claude/agents/builder.md`, section "Verification Gate"): no ticket moves to 👀 Code Review without pasted test output. If there's no test runner, there's no way to verify. This ticket unblocks all future AI-development tickets.

## Steps
Follow the block for the repo's stack only; the stack variant ticket has the details.

**Java / Spring Boot (spring-next — see J03)**:
1. JUnit 5 + Spring Boot Test via the Maven wrapper (`./mvnw`) or Gradle wrapper (`./gradlew`)
2. Integration tests against real Postgres (Testcontainers, or a local mode such as `REGNUS_TEST_INFRA=local`)
3. Verify: `./mvnw -q test -Dtest=<SmokeTest>` passes

**Python / Django (django-react — see C3, C4)**:
1. pytest + pytest-django + factory-boy, `settings_test.py` on Postgres
2. Verify: `pytest --collect-only` discovers tests

**Next.js / React (spring-next J07, django-react C7)**:
1. Vitest + Testing Library, `src/test/setup.ts`
2. Verify: `npx vitest run --maxWorkers=2 <file>` and `npx tsc --noEmit` pass

**Go**: `go test ./...` passes.

**Voice/Realtime (voice-s2s)**: see V4 (audio fixtures + mock Realtime API).

Run only targeted tests per ticket plus the repo's guard set; the full suite runs at merge/release time, not per ticket.

## Idempotent check
```bash
{ test -f "$MAIN_REPO/pom.xml" || ls "$MAIN_REPO"/build.gradle* >/dev/null 2>&1; } && test -d "$MAIN_REPO/src/test" || cat "$MAIN_REPO/package.json" "$MAIN_REPO/pyproject.toml" "$MAIN_REPO"/requirements*.txt 2>/dev/null | grep -qE "pytest|vitest|jest" || find "$MAIN_REPO" -name "*_test.go" -print 2>/dev/null | grep -q .
```

## Acceptance
- Test runner installed
- The per-ticket command (`./mvnw -q test -Dtest=...`, `pytest <path>`, `npx vitest run --maxWorkers=2 <file>`, `go test ./<pkg>`) works from repo root
- At least one passing test (smoke test) — proves infra works
- Command recorded in the stack file (`test.per_ticket`) and repo CLAUDE.md
- Committed
