# S9: Declare stack + operating mode in `.claude/stack-*.yml`

## What
Create a stack config file declaring the project's tech stack, operating mode (solo/team), and framework preferences.

## Why
Agents read `stack-*.yml` to know what to generate. Same process works for Django or Express — but the generated scaffolding differs. Mode (solo vs team) determines whether AI moves tickets autonomously.

## Steps
1. Create `.claude/stack-<project-slug>.yml`:
   ```yaml
   project: <project-slug>
   framework:
     mode: solo   # solo | team
   stack:
     backend: <e.g. python-django, node-express, go-chi>
     frontend: <e.g. react-next, react-vite, vue-nuxt, flutter>
     database: <postgres | mysql | mongodb>
     queue: <celery | bullmq | sqs | none>
     deploy: <aws | vercel | railway>
   conventions:
     package_manager: <npm | pnpm | yarn | poetry | pip>
     test_runner: <pytest | vitest | jest>
     linter: <ruff | eslint | biome>
   repos:
     - name: <repo-name>
       path: ../<repo-name>
       remote: <remote-url>
       type: <backend | frontend | infra | voice>
   ```
2. Commit to AISDLC repo

## Idempotent check
```bash
ls .claude/stack-*.yml 2>/dev/null | head -1 | grep -q .
```

## Acceptance
- `.claude/stack-<project>.yml` exists
- `framework.mode` declared (solo or team)
- Stack and conventions filled in
- Repos list complete
