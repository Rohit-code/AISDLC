# V6: Session state persistence + reconnection tests

## What
Tests that cover session state persistence and reconnection behavior. Phones drop connections; sessions must resume where they left off.

## Why
Without reconnect handling, a 10-second network blip means the user has to restart the conversation. This is unacceptable for voice UX. V6 codifies that reconnection is not optional.

## Steps

1. **Define session state schema** (references V2 state-management section):
   ```python
   class SessionState:
       session_id: str
       user_id: str
       conversation_history: list[Turn]
       pending_tool_calls: list[ToolCall]
       last_activity_ts: int
       reconnect_token: str
   ```

2. **Persistence layer**:
   - In-memory for dev
   - Redis for prod (low-latency, TTL aligned with `session.max_duration_minutes` from V1)
   - Postgres for audit log only (not hot path)

3. **Reconnection flow**:
   - Client reconnects with `session_id` + `reconnect_token`
   - Orchestrator loads state, establishes new Realtime session with replayed context (last N turns per V1)
   - Client resumes with brief acknowledgment ("I'm back — we were talking about X")

4. **Tests** (`tests/flows/test_reconnect.py`):
   - `test_reconnect_within_grace_period` — drop + reconnect within 30s, conversation resumes
   - `test_reconnect_expired_session` — drop + reconnect after max_duration, session denied, user-friendly error
   - `test_state_survives_orchestrator_restart` — orchestrator restarts mid-session, state in Redis, client reconnects successfully
   - `test_context_replay_limit` — only last N turns per V1 config are replayed (not full history)

5. **Failure mode docs** in V2 TECH-Architecture-Voice updated with exact reconnect behavior

## Idempotent check
```bash
grep -qrE 'test_reconnect|test_session_resume' $MAIN_REPO/tests/ 2>/dev/null
```

## Acceptance
- Session state schema defined
- Persistence layer implemented (at minimum Redis-ready)
- Reconnect endpoint/handler in orchestrator
- At least 4 reconnection tests passing
- Failure modes documented in V2
- Committed

## Depends on
- V4 (test infra exists)
- V1 (session config: max_duration, reconnect_strategy, max_turns_in_context)
