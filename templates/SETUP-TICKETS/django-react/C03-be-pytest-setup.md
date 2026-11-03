# C3: BE pytest-django + factory-boy setup

## What
Install pytest-django and factory-boy. Create `tests/` with `conftest.py`, `factories.py`, and a smoke test.

## Why
Standard Python/Django test stack. factory-boy gives clean fixture creation. conftest.py provides shared fixtures. Without these, every test re-invents setup.

## Steps
1. Add to `requirements-dev.txt`:
   ```
   pytest>=8.0
   pytest-django>=4.8
   factory-boy>=3.3
   faker>=25.0
   ```
2. Create `pytest.ini` or `pyproject.toml` config:
   ```ini
   [tool.pytest.ini_options]
   DJANGO_SETTINGS_MODULE = "<project>.settings_test"
   python_files = ["test_*.py", "tests.py"]
   ```
3. Create `tests/conftest.py`:
   ```python
   import pytest

   @pytest.fixture
   def api_client():
       from rest_framework.test import APIClient
       return APIClient()

   @pytest.fixture
   def authenticated_user(db):
       from tests.factories import UserFactory
       return UserFactory()
   ```
4. Create `tests/factories.py` with UserFactory + domain factories (e.g. OrderFactory)
5. Create `tests/test_smoke.py` with `def test_smoke(): assert True`
6. Verify: `pytest tests/test_smoke.py` passes

## Idempotent check
```bash
test -f $BE_REPO/tests/conftest.py && test -f $BE_REPO/tests/factories.py
```

## Acceptance
- Test requirements installed
- `tests/conftest.py` + `tests/factories.py` exist
- Smoke test passes
- `pytest` command documented in BE CLAUDE.md
- Committed
