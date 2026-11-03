# SETUP-TICKETS

Idempotent foundation tickets for initializing a new AISDLC project.

## Structure

```
SETUP-TICKETS/
├── README.md              ← You are here
├── _common/               ← Universal S-tickets (apply to any project)
│   ├── manifest.yml       ← Ordered list + idempotent checks
│   └── S*.md              ← One file per ticket template
├── django-react/           ← Django BE + React/Next FEs
│   ├── README.md          ← When to use this variant
│   ├── manifest.yml
│   └── C*.md
└── voice-s2s/             ← OpenAI Realtime / streaming voice
    ├── README.md
    ├── manifest.yml
    └── V*.md
```

## How init uses this

When `/aisdlc-init <project> --stack=<type>` runs:

1. **Read `_common/manifest.yml`** — universal tickets
2. **Read `<stack>/manifest.yml`** — stack-specific additions
3. **For each ticket**, run the `idempotent_check` bash command
   - If check succeeds (exit 0) → ticket is already done, skip
   - If check fails → create ticket on the board with the template body
4. **Report summary** — what was created, what was skipped

## Idempotency contract

Every ticket template must declare:

- `title` — ticket title (becomes the board card name)
- `priority` — P0/P1/P2/P3
- `owner` — Product / Tech / AI (who moves it next)
- `idempotent_check` — single bash command that returns 0 if already done
- `acceptance` — concrete pass condition

The `idempotent_check` is what makes init safe to re-run. Running init on a fully-set-up project creates zero tickets. Running it on a half-set-up project creates only the missing ones.

## Adding a new stack variant

1. Create `SETUP-TICKETS/<stack>/` directory
2. Add `README.md` describing when to use this variant
3. Add `manifest.yml` listing stack-specific tickets
4. Write ticket templates as markdown files
5. Reference from the init command with `--stack=<name>`

Examples of future variants: `mobile-rn`, `data-pipeline`, `ml-inference`, `iot-edge`.
