# J03: BE test infra — JUnit 5 + real Postgres

## What
JUnit 5 + Spring Boot Test, with integration tests running against a real PostgreSQL 16 (and Redis/Kafka where used). Two accepted ways:
- **Testcontainers** (needs Docker): `PostgreSQLContainer<>("postgres:16")` with `@ServiceConnection`
- **Local mode** (no Docker): an env switch makes the test JVM start a private Postgres/Redis/embedded Kafka on free ports (ERP: `REGNUS_TEST_INFRA=local`). Classes that truly need Docker carry a marker and skip in local mode.

## Why
Flyway migrations use Postgres-only features; H2 or a mocked repository hides them. Tests must also never touch a shared dev or demo database: each test JVM owns its database.

## Steps
1. Add test dependencies to `pom.xml`: `spring-boot-starter-test`, and `org.testcontainers:postgresql` + `org.testcontainers:junit-jupiter` (and/or the local-mode support classes)
2. Create one shared base for integration tests (e.g. `src/test/java/<pkg>/support/IntegrationTestBase.java`) that starts the database once per JVM
3. Write a smoke test that boots the context and runs the Flyway migrations
4. Record the per-ticket command in the stack file (`test.per_ticket`) and BE `CLAUDE.md`:
   ```bash
   ./mvnw -q test -Dtest=<TouchedTestClasses>                         # Testcontainers
   REGNUS_TEST_INFRA=local ./mvnw -q test -Dtest=<TouchedTestClasses> # ERP local mode
   ```
5. Define the guard set (`test.guard_set`): the few classes that run with every ticket. The full suite runs only at merge/release time (ERP: cloud shards), never per ticket
6. Verify: the smoke test passes

## Idempotent check
```bash
test -x "$BE_REPO/mvnw" && { cat "$BE_REPO/pom.xml" 2>/dev/null | grep -q testcontainers || grep -rqs "TEST_INFRA" "$BE_REPO/src/test"; }
```

## Acceptance
- `./mvnw -q test -Dtest=<SmokeTest>` passes on a fresh clone
- Tests use their own database, never the dev/demo one
- Per-ticket command and guard set recorded in the stack file and `CLAUDE.md`
- Committed
