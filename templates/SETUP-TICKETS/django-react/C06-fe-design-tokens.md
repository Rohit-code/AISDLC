# C6: FE Tailwind config + design tokens alignment

## What
Canonical design tokens (colors, spacing, typography) live in the main consumer FE. All other FE repos align to those tokens. Support both Tailwind v3 (JS config) and v4 (CSS `@theme`) per repo.

## Why
Multiple FE repos drifting on colors/spacing is a common problem (document it in TECH-Architecture-FE.md). Canonical palette in main FE, other FEs import or mirror.

## Steps

1. **Identify the canonical source** — typically the main consumer FE. Its `theme.js` or `tailwind.config.js` or `src/index.css` has the real design tokens.

2. **For each non-canonical FE repo**:

   **If Tailwind v3** (JS config):
   - Open `tailwind.config.js`
   - Align `theme.extend.colors` with canonical values
   - Ensure same font family, border radius, spacing scale

   **If Tailwind v4** (CSS `@theme`):
   - Open `src/index.css`
   - Add / align `@theme { --color-primary: ...; }` block to match canonical

3. **Verify visually** — run dev server, compare a common element (button, heading) against main FE

4. **Document** the canonical location in each FE's CLAUDE.md: "design tokens come from <main-fe>. Do not diverge."

5. **Commit** per repo

## Idempotent check
```bash
grep -q '@theme\|theme.extend' $FE_REPO/tailwind.config.* $FE_REPO/src/index.css 2>/dev/null
```

## Acceptance
- Canonical palette identified and documented
- Each non-canonical FE aligned (colors at minimum)
- CLAUDE.md in each FE notes where canonical lives
- Committed
