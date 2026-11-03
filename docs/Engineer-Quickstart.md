# The Engineer's Guide to AISDLC

**Audience**: engineers on projects that use AISDLC. Read once, shipping by end of day.

This isn't a framework manifesto. It's a deal: **AI does the boring stuff, you write code**. If this document ever tells you to do something that feels like admin ceremony for its own sake, push back — something's wrong with the framework, not with you.

---

## The deal

**AI writes the code. You review it.** That's the core inversion — your job is judgment, not typing.

You do:
- Review code AI writes. Block the bad parts, ship the rest.
- Make architecture decisions and clarify ambiguous asks.
- Approve API contracts before BE and FE split off to build (this is the one gate nobody else owns).
- Push to prod — the scary button stays yours.
- Tell the AI when it's wrong.

AI does:
- Writes the code (BE + FE), under your review.
- Writes failing tests from the contract first (TDD — tests land before code).
- Writes commit messages, PR / MR descriptions, release notes.
- Moves tickets through the board, tags product when something's blocked on them.
- Opens PRs / MRs, runs the Verification Gate, deploys to staging.
- Files tickets when you describe a feature in chat.
- Files framework-gap tickets on the AISDLC board when the rules are silent on a case.

**Your time is expensive. It goes into judgment, taste, and architecture — not typing.** If you're still writing commit messages, moving tickets, drafting PR descriptions, or grinding out boilerplate, the framework is failing. Tell us.

You *can* always take the keyboard. Override is fine — exploratory spikes, sensitive code (auth, payments), or when AI is stuck. But override is the exception. Default is: point AI at a ticket, review what comes back.

---

## Day 0: what to install

Pick **one** of:

- **Cursor** — `https://cursor.sh`. Open the project workspace, it auto-loads rules.
- **Claude Code** — `npm install -g @anthropic-ai/claude-code`. Run inside the workspace.

Plus:

- `gh` — `brew install gh` (or your distro's equivalent). Then `gh auth login`.
- `glab` — `brew install glab`, then `glab auth login --hostname gitlab.com` with a PAT that has `api`, `read_user`, `read_repository`, `write_repository`.
- SSH keys for github.com and gitlab.com (you probably already have these).

That's it. No framework install. The framework is just a git repo you cloned with the project.

Smoke test:

```bash
cd <project>/
gh project item-list <project_number> --owner <owner> --format json | head
```

If that lists tickets, you're ready.

---

## The shape of a project

```
<project>/                    ← workspace folder (not a git repo)
├── aisdlc/                   ← the framework — don't edit, ever
├── <project>-context/        ← contracts, indexes, decisions (internal)
├── <project>-be/             ← backend code (you'll work here)
├── <project>-fe/             ← frontend code
├── <project>-<service>/      ← other services
├── CLAUDE.md / AGENTS.md     ← read this once; it orients the AI
├── .claude/                  ← AI config for Claude Code
└── .cursor/                  ← AI config for Cursor
```

Every code repo has its own `AGENTS.md` pointing at its `CLAUDE.md`. Both contain the same thing — a cheat sheet for the AI.

---

## Your normal flow for a feature

Assume you're picking up a new feature.

### 1. Ticket exists (or you describe it in chat, AI creates it)

Features always live on the project board before any code is touched. If someone describes a feature in Slack or chat, tell the AI:

> *"Create a ticket: we need multi-currency support on checkout. BE needs price recalculation, FE needs currency selector."*

AI drafts a parent ticket using the FRD template, asks clarifying questions as ticket comments (not as chat interruptions), and replies in chat with:

> *Filed as #123 on the project board. https://github.com/…/123*

### 2. Triage promotes it

Triage lead (or in solo mode, AI) moves it from 📥 Backlog → 📝 FRD Draft.

### 3. `@planner` writes the FRD Tech Plan + contract

AI produces:
- Execution plan on the ticket.
- Three sub-issues: `[BE] <feature>`, `[FE] <feature>`, `[Contract] <feature>`.
- API contract at `<project>-context/contracts/<feature>.yaml`.

### 4. You approve the contract (**this is important**)

Before anyone writes code, **both the BE dev and the FE dev approve the `[Contract]` sub-issue**. Comment "approved" on the ticket, or raise issues to fix. This is the validation gate — it saves the day when FE expects `snake_case` and BE ships `camelCase`.

### 5. `@tester` writes failing tests

From the contract. BE gets pytest, FE gets RTL/Vitest. They fail. That's TDD.

### 6. `@builder` / `@fe-builder` makes them pass

Often runs autonomously in solo mode. You review the code — that's the part AI shouldn't own.

### 7. Verification Gate

Tests green, lints clean, build succeeds. Pasted output on the ticket. If anything fails, AI stops and asks.

### 8. `@shipper` opens the PR / MR, merges to release branch

- **GitHub repos** → `gh pr create`.
- **GitLab repos** → `glab mr create`.
- Target is `release/ai-sdlc-v1` (or whatever your project declares). **Never master/main/dev.**

In solo mode, AI merges. In team mode, it waits for your review.

### 9. Staging deploy + release notes

`@shipper` deploys to staging, runs smoke tests, writes release notes.

### 10. You push to prod

You review the release notes, you push. That's your button.

---

## How to talk to the AI

Short, direct, feature-oriented. Examples that work:

- *"Work on #45"* → AI picks it up from whatever column it's in.
- *"This is blocked on the payment gateway webhook secret from client"* → AI files a blocker comment on the active ticket, tags product team, applies `blocker:client-input` label.
- *"Review your work on #45"* → AI summarizes what it shipped, what's pending, and what you should look at.
- *"Split this into two PRs"* → AI honors the `size-audit` rule and does it.
- *"Stop, revert that change"* → AI reverts.

Examples that don't work:
- Vague ("do the auth stuff").
- Chat-only without a ticket ("ship this fix to staging now"). File a ticket first, even a small one.

---

## The few hard rules

These are non-negotiable. AI enforces them. So do you.

1. **Never push to `master` / `main` / `dev`.** Release branches only (`release/ai-sdlc-v1` etc.).
2. **Never commit `.env` or secrets.** Ever. If you spot committed secrets in a repo, file a P0 ticket and don't fix silently — key rotation is a coordinated action.
3. **Every feature via the board.** No "quick hack" path. If it's quick enough to skip a ticket, it's quick enough to write a 30-second ticket.
4. **Blocked? Log it immediately** with the right label and @-tag. Don't hold blockers in your head.
5. **Size audit is a feature.** If AI refuses to touch a 3,000 LOC file and files a tech-debt ticket first, that's the framework working. Pick the narrowed scope.
6. **Done column = merged to master + deployed.** Only humans move tickets to Done.

---

## Blocker tracking (the part clients try to forget)

When you or AI hits something outside the dev team — client input, API keys, 3rd-party, design, data — it goes on the ticket:

```
**Blocked**: credentials — waiting on payment gateway webhook secret from client.
Waiting on: @product-lead. Started <YYYY-MM-DD>.
```

Label: `blocker:credentials`.

The TAT timer pauses until the comment's unblocked. When the keys arrive:

```
**Unblocked** <YYYY-MM-DD>. Duration: 4 days. Resuming.
```

Why this matters: three weeks from now, when someone asks why the feature slipped, the board answers for you. "Dev was slow" never wins an argument; "we waited 4 days on credentials" does.

---

## Two boards, one matters to you

- **Project board** (`<owner>/projects/<N>`) — your day. You live here.
- **Framework board** (the AISDLC project board). AI files its own gap tickets here when it notices the framework is missing something. **You never have to touch it.** It's the framework teaching itself.

If you see AI filing a ticket on the framework board mid-task, that's expected behavior, not a distraction. It's capture-now-plan-later.

---

## Operating modes

Every project declares one in `.claude/stack-*.yml`:

- **Solo mode** → AI runs autonomously. Moves tickets, merges to release, the works. You observe and unblock.
- **Team mode** → AI waits for humans at every column transition. Use this when 2+ humans coordinate (most client engagements).

You don't usually change modes. The triage lead sets it once per project.

---

## Friction — just say it, AI files it

If something about the framework annoys you, is confusing, or doesn't fit your case: **say it in chat**. AI files a framework-gap ticket on the AISDLC board and keeps working. It doesn't ask permission.

Examples that trigger a file:
- *"the rule doesn't cover what to do when X."*
- *"this is annoying — I had to work around the size-audit to do Y."*
- *"should I file this as a framework issue?"* (yes, and AI files it without asking again)

AI biases toward over-capture. Duplicates are cheap; missed friction repeats. See `.claude/rules/framework-observation.md` (F38) for the full rule.

## When AI gets it wrong

It will get things wrong. That's expected.

- **Code is wrong** → leave a PR comment like on any human review. AI reads comments and fixes them.
- **Scope is wrong** → `scope-discrepancy escalation` kicks in automatically at 2× budget. If AI plows ahead silently, that's a framework bug — tell us.
- **Ticket moved to wrong column** → move it back manually, leave a comment saying why.
- **Commit message is wrong** → amend, AI will adopt your style.

Escape hatches first, debate the framework later.

---

## Gotchas you'll hit

1. **Merge conflicts on `.env`.** Upstream sometimes commits a `.env` by mistake. When pulling, you'll hit a conflict. Keep the deletion, `git rm .env`, commit. Don't resurrect it.

2. **Large binary files.** Someone will push a SQL dump or DB backup to a repo. Framework won't catch this until it's merged. If you see one pushed recently, file a ticket to clean history (someone will need to coordinate).

3. **Red-threshold monoliths.** File > 1500 LOC, ViewSet > 25 actions, component > 300 LOC. AI refuses to extend them without a tech-debt ticket. That ticket lives forever until someone cleans it up — don't ignore it.

4. **Context-switch temptation.** You'll be tempted to bypass the board for "just a tiny fix." Don't. AI logs everything on tickets, and 3 months from now the board is the only place state lives.

---

## First 30 minutes on a new project

```bash
# 1. Clone (if you haven't already — usually `aisdlc init` did this for you)
cd <project>/

# 2. Check you can see the board
gh project item-list <project_number> --owner <owner> --format json | head

# 3. Open Cursor or Claude Code. Ask:
#    "Show me tickets in FRD Draft or AI Development that are ready for work."

# 4. Pick one. Say:
#    "Work on #<N>."

# 5. Let AI walk it through. Review the PR when it appears.

# 6. Merge. Tell us what felt wrong.
```

That last step matters. The framework gets better through the F38 loop — your friction becomes a framework ticket.

---

## Where to ask for help

- **Framework questions** → AISDLC repo issues (the AISDLC repo).
- **Project questions** → the project's context repo or the triage lead.
- **AI is stuck / misbehaving** → drop context in chat, AI usually self-corrects. If not, file a framework-gap ticket on AISDLC Backlog.

---

## The short version

AI writes code and ceremony. You review, decide, and push to prod. If you're doing any of the AI-side work by hand, the framework has a bug — and we want to hear about it.

Welcome.
