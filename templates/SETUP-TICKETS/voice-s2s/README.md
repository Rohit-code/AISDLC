# voice-s2s setup variant

Voice chatbot / conversational AI built on OpenAI Realtime API (speech-to-speech). Streaming, stateful, latency-critical.

## When to use this variant

Your project has:
- **Streaming voice**: user speaks, AI responds in near real-time (<500ms ideally)
- **OpenAI Realtime API** or equivalent S2S model (Gemini Live, etc.)
- **WebRTC or WebSocket** transport between client and orchestrator
- **Stateful sessions**: conversation continuity, context carryover, interruption handling
- **No classic REST BE+FE split** — it's a streaming pipeline with a client

Use this for: voice assistants, conversational chatbots, live translation, interview bots, voice-first support tools.

## How it differs from django-react

| Dimension | django-react | voice-s2s |
|-----------|-------------|-----------|
| Transport | HTTP request/response | WebSocket / WebRTC streams |
| Contracts | REST OpenAPI | Event schemas (client ↔ orchestrator ↔ model) |
| Testing | pytest of endpoints, vitest of components | Conversation flow tests + audio fixtures + mock Realtime |
| Critical metric | Correctness | Latency (mic→ASR→LLM→TTS→speaker) |
| State | Stateless per request | Stateful sessions with reconnect handling |
| Deployment | Load-balanced web servers | Long-lived connections, sticky sessions |

## What this variant adds on top of `_common/`

V-tickets fill the gaps where universal S-tickets don't fit:
- S12 (Tech Architecture BE/FE) is **replaced by** V2 (TECH-Architecture-Voice)
- S15 (API contracts) is **replaced by** V3 (event schemas)
- S14 (test infrastructure) is **extended by** V4 (voice-specific test infra)

| # | Ticket | Why voice-s2s specific |
|---|--------|------------------------|
| V1 | `.claude/stack-voice.yml` — Realtime API config, codecs, latency budgets | Stack declaration with voice-specific fields |
| V2 | TECH-Architecture-Voice.md — streaming flow, state, reconnection | Replaces BE/FE architecture docs |
| V3 | Event/message schema contracts | Replaces REST OpenAPI |
| V4 | Voice test infra — mock Realtime API, audio fixtures, flow tests | REST testing patterns don't fit |
| V5 | Latency instrumentation — per-hop timing | Voice UX lives or dies on latency |
| V6 | Session state persistence + reconnect tests | Conversation continuity matters |

## Invoked by

```bash
/aisdlc-init <project> --stack=voice-s2s --repos=<project>-orchestrator:voice,<project>-client:voice
```

## Known traps

- **Don't test with REST patterns.** A Realtime session is not a request/response. Test fixtures are WAV files + event sequences.
- **Latency budget must be explicit.** Write the budget (e.g., 500ms total) into V2 and reference from every feature FRD.
- **Client reconnection is not optional.** Phones drop connections. V6 is not a nice-to-have.
