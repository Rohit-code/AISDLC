# J04: BE Flyway migrations + migration number register

## What
Flyway owns the schema (`spring.jpa.hibernate.ddl-auto: validate`). A register file in the BE repo, `docs/db/flyway-number-register.md`, records who claimed which `V<n>`.

## Why
Several branches add migrations at once. Two branches that pick the same `V<n>` collide on merge. Claiming the number in the register, in the same commit as the migration, makes the clash visible in review instead of at deploy.

## Steps
1. `application.yml`:
   ```yaml
   spring:
     jpa:
       hibernate:
         ddl-auto: validate
     flyway:
       enabled: true
       locations: classpath:db/migration
   ```
2. Migrations in `src/main/resources/db/migration/V<n>__<snake_case_description>.sql`
3. Create `docs/db/flyway-number-register.md`:
   ```markdown
   # Flyway number register

   Claim a number here in the SAME commit as the migration. Each work stream owns a block.

   | Block | Owner / stream |
   |-------|----------------|
   | V1–V99 | baseline |
   | V100–V199 | <stream> |

   | Number | Ticket | Description | Branch |
   |--------|--------|-------------|--------|
   | V1 | <id> | baseline schema | <branch> |
   ```
4. If the project pins function bodies by hash (e.g. an `afterMigrate.sql` check), a changed function body updates its pin in the same commit
5. Note both rules in BE `CLAUDE.md`
6. Verify: the J03 smoke test runs all migrations from empty

## Idempotent check
```bash
test -f "$BE_REPO/docs/db/flyway-number-register.md" && ls "$BE_REPO"/src/main/resources/db/migration/V*.sql >/dev/null 2>&1
```

## Acceptance
- `ddl-auto: validate`; Flyway runs on start-up and in tests
- Register exists with stream blocks and every existing `V<n>` listed
- Rule "claim in the same commit" in BE `CLAUDE.md`
- Committed
