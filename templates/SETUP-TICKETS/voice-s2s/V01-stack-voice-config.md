# V1: Create `.claude/stack-voice.yml`

## What
Stack config for voice-s2s projects. Declares Realtime API provider, audio codecs, latency budgets, and conversation conventions.

## Why
Universal `stack-*.yml` fields (backend/frontend/database) don't cover voice. Agents need voice-specific knobs — which model, target latency, codec, max session duration.

## Steps
Create `.claude/stack-voice.yml`:

```yaml
project: <project-slug>
framework:
  mode: solo  # solo | team

stack:
  type: voice-s2s
  realtime_provider: openai-realtime   # or gemini-live, deepgram-nova, etc.
  model: gpt-realtime                  # or project-specific
  asr: integrated                      # integrated | external (whisper, deepgram)
  tts: integrated                      # integrated | external (elevenlabs, cartesia)
  transport: webrtc                    # webrtc | websocket
  orchestrator_runtime: python-fastapi # or node-fastify, go-fiber
  client: web                          # web | mobile-rn | mobile-flutter | telephony

audio:
  codec: opus                          # opus | pcm16 | g711
  sample_rate: 24000
  channels: 1

latency_budget:
  target_ms: 500                       # end-to-end: mic → speaker
  allocation:
    mic_to_ingress_ms: 50
    asr_ms: 120
    llm_first_token_ms: 150
    tts_first_byte_ms: 80
    egress_to_speaker_ms: 100

session:
  max_duration_minutes: 30
  idle_timeout_seconds: 60
  reconnect_strategy: resume-with-context
  max_turns_in_context: 20

conventions:
  package_manager: poetry
  test_runner: pytest
  linter: ruff
  conversation_language_default: en

repos:
  - name: <project>-orchestrator
    path: ../<project>-orchestrator
    remote: <url>
    type: voice-orchestrator
  - name: <project>-client
    path: ../<project>-client
    remote: <url>
    type: voice-client
```

## Idempotent check
```bash
test -f .claude/stack-voice.yml
```

## Acceptance
- `.claude/stack-voice.yml` exists
- `latency_budget.target_ms` declared (critical — all future perf work references this)
- `session.reconnect_strategy` declared
- Repos listed
- Committed to AISDLC repo
