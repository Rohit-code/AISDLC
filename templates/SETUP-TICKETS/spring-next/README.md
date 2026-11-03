# spring-next setup variant

Spring Boot backend + 1 or more Next.js frontends. The ERP project (erp-core + erp-fe) is the reference.

## When to use this variant

Your project has:
- **Backend**: Java 21 / Spring Boot 3.5, Maven wrapper, PostgreSQL 16 with Flyway, optionally Redis and Kafka
- **Frontend**: Next.js 15 (App Router), React 19, TypeScript, Tailwind
- **Local dev**: Docker Compose for BE dependencies, `npm run dev` per FE
- **Tests**: JUnit 5 + Spring Boot Test against real Postgres (Testcontainers or a local mode); Vitest + Testing Library + `tsc --noEmit` for FE

## What this variant adds on top of `_common/`

S14 (generic test infra) is **replaced by** J03 + J07.

| # | Ticket | Why it's spring-next specific |
|---|--------|-------------------------------|
| J01 | BE Dockerfile — Maven wrapper multi-stage | `./mvnw` build stage, JRE-only runtime |
| J02 | BE docker-compose — Postgres 16, Redis, Kafka | Dev deps on non-default host ports (never 5432/5433/6379/9092) |
| J03 | BE test infra — real Postgres | Flyway migrations use Postgres-only features; H2 hides bugs |
| J04 | Flyway + migration number register | Parallel branches must not claim the same `V<n>` |
| J05 | OpenAPI via springdoc | BE publishes its live spec at `/v3/api-docs` |
| J06 | FE local dev (per FE repo) | Each FE repo gets `.env.example` + `CLAUDE.md` |
| J07 | FE Vitest + `tsc --noEmit` (per FE repo) | Targeted runs with `--maxWorkers=2` |
| J08 | FE rem-based tokens + no-px test (per FE repo) | Root font-size scales the UI; px freezes elements out of it |
| J09 | FE API types via openapi-typescript | FE types come from the approved contract, not hand-written |

## Invoked by

```bash
/aisdlc-init erp --stack=spring-next --repos=erp-core:be,erp-fe:fe
```

`--repos` format: see `../README.md` (Variables).

## Sibling stack variants

- `django-react/` — Django BE + React/Next FEs
- `voice-s2s/` — streaming voice (OpenAI Realtime)
