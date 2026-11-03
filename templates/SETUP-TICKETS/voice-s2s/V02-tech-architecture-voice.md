# V2: Generate TECH-Architecture-Voice.md

## What
Create `<project>-context/docs/TECH-Architecture-Voice.md` covering the streaming pipeline, session state, reconnection, and failure handling.

## Why
BE/FE architecture templates don't fit voice-s2s. The pipeline is the product. Without this doc, every feature FRD has to re-derive how audio flows through the system.

## Steps
Agent generates from codebase scan + Product Wiki + V1 (stack-voice.yml):

1. **Overview diagram** — ascii / mermaid of:
   ```
   [User mic] → [Client] → [Orchestrator] → [Realtime API]
                                          ↓
   [User speaker] ← [Client] ← [Orchestrator] ← [tokens]
   ```

2. **Components**:
   - Client (what it does: mic capture, audio send, audio receive, speaker playback, UI state)
   - Orchestrator (auth, session creation, tool call routing, logging, rate limiting)
   - Realtime API (what we rely on it for vs handle ourselves)
   - Sidecar services (RAG, tool execution, database, telemetry)

3. **Session lifecycle**:
   - How a session starts (auth → session token → WebRTC/WS handshake)
   - How audio flows during the session
   - How the session ends (timeout, user hangup, error)

4. **State management**:
   - Per-session state (conversation history, user context, tool results)
   - Where state lives (in-memory? Redis? Postgres? All three?)
   - How state is restored after reconnect

5. **Latency budget** (copy from V1, elaborate):
   - Per-hop targets
   - Where we have slack, where we don't
   - What happens if a hop exceeds budget

6. **Failure modes**:
   - Network blip (client reconnects, state resumes)
   - Realtime API outage (fallback model? graceful message?)
   - Tool call failure (retry? error to user?)
   - Session timeout (explicit user message)

7. **Tool calling** (if applicable):
   - Which tools are available
   - Tool call schema
   - Security boundary (which tools can be called without extra auth)

8. **Security & compliance**:
   - Audio storage (retained? for how long?)
   - Transcript retention
   - PII handling
   - Regional compliance (GDPR, DPDP, sector rules if relevant)

## Idempotent check
```bash
test -f "$CONTEXT_DIR/docs/TECH-Architecture-Voice.md"
```

## Acceptance
- Doc exists and covers all 8 sections
- Latency budget is specific (numbers, not vibes)
- Reconnection strategy is explicit
- A new engineer can understand the voice pipeline in 30 minutes
- Committed
