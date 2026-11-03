# C1: BE Dockerfile with multi-stage build

## What
Multi-stage Dockerfile for the Django backend: builder stage installs deps, runtime stage copies only what's needed.

## Why
Multi-stage keeps images lean. Deps installed once, copied to minimal runtime. Standard for Python/Django production.

## Steps
1. Create `Dockerfile` in BE repo root:
   ```dockerfile
   # ── Builder
   FROM python:3.11-slim AS builder
   WORKDIR /build
   COPY requirements*.txt ./
   RUN pip install --user --no-cache-dir -r requirements.txt

   # ── Runtime
   FROM python:3.11-slim
   WORKDIR /app
   COPY --from=builder /root/.local /root/.local
   ENV PATH=/root/.local/bin:$PATH
   COPY . .
   EXPOSE 8000
   CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "<project>.wsgi"]
   ```
2. Add `.dockerignore`:
   ```
   .git
   .env
   __pycache__
   *.pyc
   node_modules
   .venv
   ```
3. Build test: `docker build -t <project>-be .`
4. Commit

## Idempotent check
```bash
test -f $BE_REPO/Dockerfile
```

## Acceptance
- Multi-stage Dockerfile at BE repo root
- Builds cleanly on fresh clone
- `.dockerignore` prevents leaking `.env`
- Image size < 300MB
- Committed
