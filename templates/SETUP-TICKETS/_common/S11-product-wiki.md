# S11: Generate Product Wiki

## What
Run `@project-wiki` to generate the initial Product Wiki at `<project>-context/docs/Product-Wiki.md`.

## Why
The Product Wiki is the living source of truth for what the product IS today. Every FRD updates it. Without a v1, there's no ground truth for agents or new engineers.

## Steps
1. Ensure the context repo exists (S1), code repos are cloned (S4) and CLAUDE.md exists (S8)
2. Invoke `@project-wiki` agent
3. Agent scans all repos (BE models, FE routes, API endpoints, existing docs, README files)
4. Agent generates v1 using `templates/PRODUCT-WIKI-TEMPLATE.md`
5. Publishes to `<project>-context/docs/Product-Wiki.md` (all project docs live in the context repo, not in code repos)
6. Commits to the context repo

## Idempotent check
```bash
test -f "$CONTEXT_DIR/docs/Product-Wiki.md"
```

## Acceptance
- `<project>-context/docs/Product-Wiki.md` exists
- Covers: what the product does, user types, core flows, current features by domain
- Committed to the context repo
- Summary posted on the ticket
