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
- Writes commit messages, PR descriptions, release notes.
- Moves tickets through the board, tags product when something's blocked on them.
- Opens PRs, runs the Verification Gate, deploys to staging (when the project has one).
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
- SSH key for github.com (you probably already have one).
- GitLab-hosted clients: use the `glab` equivalents of the `gh` commands in this guide.

That's it. No framework install. The framework is just a git repo you cloned with the project.

Smoke test (framework board, then your project board; `<owner>` is a user login or an org):

```bash
gh project item-list 2 --owner Rohit-code --format json | head
gh project item-list <project_number> --owner <owner> --format json | head
```

If that lists tickets, you're ready.

---

## The shape of a project

```
AISDLC/                       ← the workspace IS the framework clone — don't edit the framework files
├── CLAUDE.md / AGENTS.md     ← read this once; it orients the AI
├── .claude/                  ← agents, rules, stack files (project facts), framework board config
├── .cursor/                  ← generated Cursor rules
├── <project>-context/        ← contracts, indexes, docs, project board-config.yml (own git, gitignored)
├── <project>-be/             ← backend code, you'll work here (own git, gitignored; ERP: erp-core/)
└── <project>-fe/             ← frontend code (own git, gitignored; ERP: erp-fe/)
```

Every code repo has its own `AGENTS.md` pointing at its `CLAUDE.md`. Both contain the same thing — a cheat sheet for the AI.

---

## Your normal flow for a feature

Assume you're picking up a new feature.

### 1. Ticket exists (or you describe it in chat, AI creates it)

Features always live on the project board before any code is touched. If someone describes a feature in Slack or chat, tell the AI:

> *"Create a ticket: we need multi-currency support on invoices. BE needs amount recalculation, FE needs a currency selector."*

AI drafts a parent ticket using the FRD template, asks clarifying questions as ticket comments (not as chat interruptions), and replies in chat with:

> *Filed as #123 on the project board. https://github.com/…/123*

### 2. Triage promotes it

Triage lead (or in solo mode, AI) moves it from 📥 Backlog → 📝 FRD Draft. Who may move what, per mode: `.claude/rules/kanban-workflow.md`.

### 3. `@planner` writes the tech plan + contract (🤖 FRD Tech Plan)

AI produces:
- Execution plan on the ticket.
- Three sub-issues: `[BE] <feature>`, `[FE] <feature>`, `[Contract] <feature>`.
- API contract at `<project>-context/contracts/<feature>.yaml`.

### 4. You approve the contract (**this is important**)

Before anyone writes code, **both the BE dev and the FE dev approve the `[Contract]` sub-issue** (approve, then close it). The parent cannot move 🔧 Tech Plan Approved → 💻 AI Development until that sub-issue is closed. This is the validation gate — it saves the day when FE expects `snake_case` and BE ships `camelCase`.

### 5. `@tester` writes failing tests

From the contract, on the ticket's branch `feature/<id>-<slug>`. BE gets the stack's test runner (ERP: JUnit via `./mvnw`), FE gets Vitest + Testing Library. They fail. That's TDD.

### 6. `@builder` / `@fe-builder` makes them pass

On the same branch @tester created (never a second one). Often runs autonomously in solo mode. You review the code — that's the part AI shouldn't own.

### 7. Verification Gate

Tests green, lints clean, build succeeds. Pasted output on the ticket. If anything fails, AI stops and asks.

### 8. The PR goes to the default branch

- `gh pr create --base <default branch>` (erp-core `master`, erp-fe `main`).
- AI never commits or pushes to the default branch, never force-pushes, never merges. A human merges.

Full branch / PR / commit rules: `.claude/rules/source-control.md`.

### 9. Staging deploy + release notes

If the stack file defines staging, `@shipper` deploys to staging, runs smoke tests, writes release notes. If it says `staging: none` (ERP), a human moves 👀 Code Review → 🚀 Ready for Production directly.

### 10. You push to prod

You review the release notes, you push. That's your button.

---

## How to talk to the AI

Short, direct, feature-oriented. Examples that work:

- *"Work on #45"* → AI works on it only if the column allows it: in team mode the ticket must already be in an AI-active column (a human moved it there); otherwise AI says which human move is needed (`.claude/rules/kanban-workflow.md`).
- *"This is blocked on the bank's virtual-account API credentials from the client"* → AI files a blocker comment on the active ticket, tags product team, applies `blocker:client-input` label.
- *"Review your work on #45"* → AI summarizes what it shipped, what's pending, and what you should look at.
- *"Split this into two PRs"* → AI honors the `size-audit` rule and does it.
- *"Stop, revert that change"* → AI reverts.

Examples that don't work:
- Vague ("do the auth stuff").
- Chat-only without a ticket ("ship this fix to staging now"). File a ticket first, even a small one.

---

## The few hard rules

These are non-negotiable. AI enforces them. So do you.

1. **Never push to the default branch** (`master` / `main` or any `protected_branches` in the stack file). Work on `feature/<id>-<slug>`, PR into `pr_base` from the stack file (the default branch, or the ticket's stream branch such as ERP `plan/<stream>`), a human squash-merges.
2. **Never commit `.env` or secrets.** Ever. If you spot committed secrets in a repo, file a P0 ticket and don't fix silently — key rotation is a coordinated action.
3. **Every feature via the board.** No "quick hack" path. If it's quick enough to skip a ticket, it's quick enough to write a 30-second ticket.
4. **Blocked? Log it immediately** with the right label and @-tag. Don't hold blockers in your head.
5. **Size audit is a feature.** If AI refuses to touch a 3,000 LOC file and files a tech-debt ticket first, that's the framework working. Pick the narrowed scope.
6. **Done column = merged to the default branch + deployed** (or merged, when there is no deploy step). Only humans move tickets to 🚀 Ready for Production or ✅ Done.

---

## Blocker tracking (the part clients try to forget)

When you or AI hits something outside the dev team — client input, API keys, 3rd-party, design, data — it goes on the ticket:

```
**Blocked**: credentials — waiting on the bank's virtual-account API credentials from the client.
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

Every project declares one in `framework.mode` in `.claude/stack-*.yml` (missing = team):

- **Solo mode** → AI runs autonomously and may move tickets into AI-active columns. It still never merges, never moves to 🚀 Ready for Production / ✅ Done. You observe and unblock.
- **Team mode** → only humans move a ticket into an AI-active column. Use this when 2+ humans coordinate (the ERP project is team mode).

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

3. **Red-threshold monoliths.** Oversized files, controllers and components (thresholds in `.claude/rules/size-audit.md`). AI refuses to extend them without a tech-debt ticket. That ticket lives forever until someone cleans it up — don't ignore it.

4. **Context-switch temptation.** You'll be tempted to bypass the board for "just a tiny fix." Don't. AI logs everything on tickets, and 3 months from now the board is the only place state lives.

---

## First 30 minutes on a new project

```bash
# 1. Clone the workspace and the project repos (`/aisdlc-init` does not clone —
#    it files setup tickets; the clone step is setup ticket S4). ERP:
git clone git@github.com:Rohit-code/AISDLC.git AISDLC && cd AISDLC
git clone -o github git@github-regnus-tech:RegnusTech/erp-core.git erp-core   # others: git@github.com:RegnusTech/erp-core.git
git clone -o github git@github-regnus-tech:RegnusTech/erp-fe.git erp-fe

# 2. Check you can see the board
gh project item-list <project_number> --owner <owner> --format json | head

# 3. Open Cursor or Claude Code. Ask:
#    "Show me tickets in FRD Draft or AI Development that are ready for work."

# 4. Pick one. Say:
#    "Work on #<N>."

# 5. Let AI walk it through. Review the PR when it appears.

# 6. Merge it yourself (AI never merges). Tell us what felt wrong.
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
