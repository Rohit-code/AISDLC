# V3: Event/message schema contracts

## What
Define event schemas for client ↔ orchestrator ↔ Realtime API messages. Published to `<project>-context/contracts/events.yaml`. Replaces REST OpenAPI contracts for voice projects.

## Why
Voice is event-driven, not request/response. Messages like `session.start`, `input_audio_buffer.append`, `response.audio.delta`, `response.function_call.arguments`, `session.end` need typed schemas so client and orchestrator stay in lockstep.

## Steps

1. **Use AsyncAPI** or a simpler custom YAML format. AsyncAPI is standard for event-driven but heavier.

2. **Define message categories**:
   - **Client → Orchestrator**: `session.start`, `audio.chunk`, `user.text`, `session.end`, `control.mute`, `control.interrupt`
   - **Orchestrator → Client**: `session.ready`, `audio.chunk`, `transcript.partial`, `transcript.final`, `tool.result`, `error`, `session.closed`
   - **Orchestrator → Realtime API**: forwarded based on provider SDK
   - **Realtime API → Orchestrator**: handled by provider SDK

3. **Structure** (`events.yaml`):
   ```yaml
   events:
     session.start:
       direction: client-to-orchestrator
       payload:
         user_id: string
         conversation_id: string?
         preferences: object?
       response: session.ready or error
     session.ready:
       direction: orchestrator-to-client
       payload:
         session_id: string
         expires_at: timestamp
     audio.chunk:
       direction: bidirectional
       payload:
         data: bytes  # opus-encoded
         sequence: int
         timestamp_ms: int
     # ... etc
   ```

4. **Versioning** — every event has a schema version; contract breakage needs migration plan

5. **Commit** to context repo

## Idempotent check
```bash
test -f $CONTEXT_DIR/contracts/events.yaml
```

## Acceptance
- `contracts/events.yaml` exists with all core events typed
- Both directions covered (client-to-orch and orch-to-client)
- Versioned
- Client and orchestrator both reference the schema (or generate types from it)
- Committed

## Depends on
- S1 (context repo)
- V2 (Tech Architecture defines what events exist)
