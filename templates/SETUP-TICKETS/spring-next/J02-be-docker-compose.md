# J02: BE docker-compose dev deps — Postgres 16, Redis, Kafka

## What
`docker-compose.yml` in the BE repo with the backend's dependencies only (the app itself runs with `./mvnw spring-boot:run`). Every service is published on a **non-default host port**.

## Why
One command (`docker compose up -d`) gives a working dev stack. Non-default host ports keep it from colliding with any other Postgres/Redis/Kafka on the machine: never publish 5432, 5433, 6379 or 9092.

## Steps
1. Create `docker-compose.yml`:
   ```yaml
   services:
     postgres:
       image: postgres:16
       env_file: .env
       ports: ["55432:5432"]
       volumes: ["pgdata:/var/lib/postgresql/data"]
       healthcheck:
         test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER}"]
         interval: 5s
         retries: 10

     redis:
       image: redis:7
       ports: ["56379:6379"]

     kafka:
       image: apache/kafka:3.8.0
       ports: ["59092:9092"]
       environment:
         KAFKA_NODE_ID: 1
         KAFKA_PROCESS_ROLES: broker,controller
         KAFKA_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093
         KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:59092
         KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
         KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
         KAFKA_CONTROLLER_QUORUM_VOTERS: 1@localhost:9093
         KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
         KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
         KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1

   volumes:
     pgdata:
   ```
2. **Never inline secrets** — `env_file: .env`. Add to `.env.example`:
   ```
   POSTGRES_DB=<project>_dev
   POSTGRES_USER=<project>
   POSTGRES_PASSWORD=change_me
   SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:55432/<project>_dev
   SPRING_DATA_REDIS_PORT=56379
   SPRING_KAFKA_BOOTSTRAP_SERVERS=localhost:59092
   ```
3. Drop Redis or Kafka if the backend does not use them
4. Verify: `docker compose up -d && docker compose ps` → all healthy; `./mvnw spring-boot:run` starts against them

## Idempotent check
```bash
grep -q "postgres:16" "$BE_REPO/docker-compose.yml" 2>/dev/null && ! grep -qE "[\"[:space:]:-](5432|5433|6379|9092):" "$BE_REPO/docker-compose.yml"
```

## Acceptance
- `docker compose up -d` starts every dependency, healthy
- No host port is 5432, 5433, 6379 or 9092
- The app starts against them with values from `.env`
- No secrets in the compose file
- Committed
