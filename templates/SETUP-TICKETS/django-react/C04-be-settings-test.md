# C4: BE settings_test.py with Postgres test DB

## What
Create `<project>/settings_test.py` that overrides production settings for test runs: Postgres test DB, disabled external services, fast password hasher.

## Why
Many Django migrations use Postgres-specific features (DO blocks, PostGIS, JSONB). SQLite in-memory can't run them. Using Postgres for tests matches production and avoids migration-only bugs.

Also disables external services (email, file storage, 3rd-party APIs) so tests are hermetic.

## Steps
1. Create `<project>/settings_test.py`:
   ```python
   """Test settings — Postgres test DB, disabled external services."""
   import os
   os.environ.setdefault('SECRET_KEY', 'test-secret-key-not-for-production')
   os.environ.setdefault('POSTGRES_DB', '<project>')
   os.environ.setdefault('POSTGRES_USER', 'postgres')
   os.environ.setdefault('POSTGRES_PASSWORD', 'postgres')
   os.environ.setdefault('POSTGRES_HOST', 'postgres')
   os.environ.setdefault('POSTGRES_PORT', '5432')
   os.environ.setdefault('CELERY_BROKER_URL', 'memory://')

   from <project>.settings import *  # noqa

   DATABASES['default']['TEST'] = {'NAME': 'test_<project>'}

   PASSWORD_HASHERS = ['django.contrib.auth.hashers.MD5PasswordHasher']
   CELERY_TASK_ALWAYS_EAGER = True
   CELERY_TASK_EAGER_PROPAGATES = True
   DEFAULT_FILE_STORAGE = 'django.core.files.storage.FileSystemStorage'
   EMAIL_BACKEND = 'django.core.mail.backends.locmem.EmailBackend'

   # Stub external APIs to safe no-op values
   # (List all 3rd-party API settings here with test/empty values)
   ```
2. Ensure `pytest.ini` uses `DJANGO_SETTINGS_MODULE = <project>.settings_test`
3. Verify: `pytest` can create `test_<project>` db and run smoke test

## Idempotent check
```bash
test -f $BE_REPO/*/settings_test.py 2>/dev/null
```

## Acceptance
- `settings_test.py` exists
- Uses Postgres (not SQLite)
- All external services stubbed
- `pytest` creates test DB and runs cleanly
- Committed
