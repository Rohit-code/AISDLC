# django-react setup variant

Django backend + 1 or more React/Next.js frontends.

## When to use this variant

Your project has:
- **Backend**: Python/Django (possibly with Celery, Redis, Postgres)
- **Frontend**: React (Vite or Next.js), potentially multiple FE apps (e.g. customer app + admin panel + internal tools)
- **Local dev**: Docker Compose for BE services, `npm run dev` per FE
- **Tests**: pytest for BE, vitest/jest for FE

Use this for most SaaS / marketplace / internal tool projects with a classic BE + FE split.

## What this variant adds on top of `_common/`

These C-tickets layer on top of the universal S-tickets. They fill in django-react-specific gaps that S-tickets intentionally leave abstract.

| # | Ticket | Why it's django-react specific |
|---|--------|--------------------------------|
| C1 | BE Dockerfile + multi-stage build | Django apps have specific layering (pip install, collectstatic, gunicorn) |
| C2 | BE docker-compose with postgres + redis + celery | Standard Django stack services |
| C3 | BE pytest-django + factory-boy setup | Standard Python test stack with DB fixtures |
| C4 | BE settings_test.py + Postgres test DB | Needed because migrations use Postgres-only features |
| C5 | FE local dev setup (per FE repo) | Each FE repo gets its own `.env.example`, scripts, CLAUDE.md |
| C6 | FE Tailwind config + design tokens alignment | Multiple FEs must share design tokens (canonical palette from main FE) |
| C7 | FE vitest/jest setup (per FE repo) | Component-level testing |
| C8 | Cross-repo API client generation from OpenAPI | Keep FE's HTTP layer auto-generated from BE contracts |

## Invoked by

```bash
/aisdlc-init <project> --stack=django-react --repos=<project>-be:be,<project>-web:fe,<project>-admin:fe
```

`--repos` lists the workspace repo directories with their type (format: `../README.md`). Init creates the C-tickets that apply to the declared repo types; per-FE tickets run once per FE repo.

## Sibling stack variants

- `spring-next/` — Spring Boot + Next.js
- `voice-s2s/` — streaming voice (OpenAI Realtime)

Future variants keep the same shape: `express-next/`, `fastapi-react/`, `rails-vue/`, `go-react/`.
