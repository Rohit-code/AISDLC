# V5: Latency instrumentation — per-hop timing

## What
Instrument every hop in the voice pipeline with timing spans: mic → ingress → ASR → LLM first-token → TTS first-byte → egress → speaker. Exported to traces (OpenTelemetry or similar).

## Why
Voice UX lives or dies on end-to-end latency. Without per-hop timing, you can't diagnose slowness. "Response felt slow" is useless; "TTS first-byte was 280ms, 3.5x target" is actionable.

## Steps

1. **Choose a tracing library** — OpenTelemetry (standard), or a lightweight custom decorator for small projects

2. **Define span names** (must match V1 `latency_budget.allocation` keys):
   - `voice.mic_to_ingress`
   - `voice.asr`
   - `voice.llm_first_token`
   - `voice.tts_first_byte`
   - `voice.egress_to_speaker`

3. **Instrument orchestrator**:
   ```python
   from opentelemetry import trace
   tracer = trace.get_tracer(__name__)

   async def handle_audio_chunk(chunk):
       with tracer.start_as_current_span("voice.mic_to_ingress"):
           validated = validate(chunk)
       with tracer.start_as_current_span("voice.asr"):
           transcript = await asr.transcribe(validated)
       # ... etc
   ```

4. **Export traces** — start with console exporter; graduate to Jaeger / Honeycomb / Datadog later

5. **Dashboard or CLI tool** showing:
   - p50 / p95 / p99 per span
   - End-to-end latency distribution
   - Flag sessions that exceeded budget

6. **Budget check in tests** — V4 flow tests assert spans stayed within V1 budget allocations

## Idempotent check
```bash
grep -qrE 'latency_hop|trace_span.*voice' $MAIN_REPO/ 2>/dev/null
```

## Acceptance
- OTel (or equivalent) instrumentation in orchestrator
- All 5 hops emit spans
- Traces visible in console / Jaeger / chosen backend
- Latency budget from V1 referenced in dashboards
- V4 flow tests assert budget is met
- Committed

## Depends on
- V2 (Tech Architecture defines the hops and budget)
