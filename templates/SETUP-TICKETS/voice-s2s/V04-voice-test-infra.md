# V4: Voice test infrastructure — mock Realtime, audio fixtures, flow tests

## What
Test infra specifically for voice: mock Realtime API (so tests don't hit OpenAI), audio fixtures (WAV files for known inputs), and conversation flow tests.

## Why
You can't unit-test a streaming pipeline with REST patterns. Tests need to simulate:
- User sends audio → pipeline processes → expected response comes out
- User interrupts mid-response → pipeline handles
- Tool call fires → returns result → next audio turn plays correct response
- Connection drops → reconnects → context resumes

## Steps

1. **Mock Realtime API** (`tests/mocks/realtime.py` or similar):
   - Accepts audio chunks, returns scripted responses
   - Supports injecting specific events (function_call, error, transcript)
   - Recordable — can capture live sessions and replay for regression tests

2. **Audio fixtures** (`tests/fixtures/audio/`):
   - WAV files of known utterances: `hello.wav`, `interrupt.wav`, `long_pause.wav`, `silence_10s.wav`
   - Short (< 5s), small files, committed

3. **Flow test harness** (`tests/helpers/flow.py`):
   - `async def simulate_turn(audio_fixture, expected_events)` helper
   - Asserts event sequences, latency windows, state transitions

4. **Example tests** (`tests/flows/`):
   - `test_greeting_flow.py` — user says hi, AI responds
   - `test_interruption.py` — user interrupts, AI stops, user continues
   - `test_tool_call.py` — user asks "what's the weather", tool fires, AI relays result
   - `test_silence_handling.py` — user silent for N seconds, AI prompts

5. **Run tests**: `pytest tests/flows/` — must pass without hitting external APIs

## Idempotent check
```bash
test -d "$MAIN_REPO/tests/fixtures/audio" && test -f "$MAIN_REPO/tests/mocks/realtime.py"
```

## Acceptance
- Mock Realtime API in place
- At least 5 audio fixtures committed
- Flow test harness usable
- At least 4 example flow tests passing
- Tests run without external API calls
- Documented in CLAUDE.md

## Depends on
- S14 (base test infra — pytest installed)
- V3 (event contracts — tests assert against them)
