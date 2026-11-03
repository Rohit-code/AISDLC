# C2: BE docker-compose with postgres + redis + celery

## What
`docker-compose.yml` in BE repo with the standard Django stack: web, postgres, redis, celery worker.

## Why
Replicate prod topology locally. One command (`docker compose up -d`) gets the whole BE running with dependencies. Essential for the verification gate.

## Steps
1. Create `docker-compose.yml`:
   ```yaml
   services:
     web:
       build: .
       env_file: .env
       depends_on: [postgres, redis]
       ports: ["8000:8000"]
       volumes: ["./:/app"]
       command: python manage.py runserver 0.0.0.0:8000

     postgres:
       image: postgres:16
       env_file: .env
       volumes: ["pgdata:/var/lib/postgresql/data"]
       ports: ["5432:5432"]

     redis:
       image: redis:7
       ports: ["6379:6379"]

     celery:
       build: .
       env_file: .env
       depends_on: [redis, postgres]
       command: celery -A <project> worker -l info
       volumes: ["./:/app"]

   volumes:
     pgdata:
   ```

2. **Never inline secrets** — always `env_file: .env`. Non-secret config (DEBUG, POSTGRES_HOST) can be inline.

3. Update `.env.example` with all required vars

4. Verify: `docker compose up -d && docker compose ps` → all healthy

## Idempotent check
```bash
grep -qE 'postgres|redis' $BE_REPO/docker-compose.yml 2>/dev/null
```

## Acceptance
- `docker compose up -d` starts all 4 services
- Django reachable at `localhost:8000`
- Celery processes tasks
- No secrets in the compose file
- Committed
