#!/usr/bin/env python3
"""Check the AISDLC framework for broken wiring.

Run from anywhere:  python3 bin/check-framework.py
Exit code 0 = every check passed, 1 = at least one failure.

Checks:
  agents      every .claude/agents/*.md has frontmatter with name (= file name) and description
  skills      every .claude/skills/*/SKILL.md has frontmatter with name (= folder) and description
  settings    .claude/settings.json is valid JSON with permissions.allow / permissions.deny lists
  yaml        board-config, stack files and setup manifests parse
  board       board-config.yml has every status and priority key with a real ID
  columns     kanban-workflow.md names all 12 columns; no old column names anywhere
  cursor      every Claude rule and agent has a Cursor pointer with valid frontmatter, and no orphan .mdc
  manifests   every setup-ticket template file exists and every depends_on id is defined
  paths       relative links and `.claude/...`-style paths in docs point at real files
  scripts     bin/*.sh pass `bash -n`
  leftovers   no names or patterns from earlier client projects
"""
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

COLUMNS = [
    "📥 Backlog", "📝 FRD Draft", "🤖 FRD Tech Plan", "🔧 Tech Plan Approved",
    "💻 AI Development", "👀 Code Review", "🧪 Staging Ready", "🎭 Staging Review",
    "🔄 Rework", "🚀 Ready for Production", "✅ Done", "🚨 Hotfix",
]
STATUS_KEYS = ["backlog", "frd_draft", "frd_tech_plan", "tech_plan_approved", "ai_development",
               "code_review", "staging_ready", "staging_review", "rework",
               "ready_for_production", "done", "hotfix"]
PRIORITY_KEYS = ["p0", "p1", "p2", "p3"]

# Files created inside a target project, not in this repo; docs may name them.
PROJECT_FILES = re.compile(
    r"^(docs/(Product-Wiki|TECH-Architecture)|docs/db/|docs/plan/|\.claude/stack-voice\.yml|"
    r"\.claude/board-config\.yml$|\.claude/stack-[a-z-]+\.yml$|\.claude/worktrees)")
LEFTOVERS = re.compile(
    r"g[a]myam|\bc[e]nt ?ai\b|r[a]ghav|r[a]zorpay|opt/homebrew|release/ai-sdlc|FRD Tech Plan Review|"
    r"@testing-library/user-event|from \"msw\"|agents/[a-z-]+/agent\.md|claude-code-framework-plan\.txt",
    re.I)

failures = []


def fail(check, msg):
    failures.append(f"[{check}] {msg}")


def tracked_files():
    out = subprocess.run(["git", "ls-files", "--cached", "--others", "--exclude-standard"],
                         capture_output=True, text=True, check=True).stdout
    return [f for f in out.splitlines() if os.path.isfile(f) and not os.path.islink(f)]


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None
    fields = {}
    for line in m.group(1).splitlines():
        km = re.match(r"^([A-Za-z_-]+):\s*(.*)$", line)
        if km:
            fields[km.group(1)] = km.group(2).strip().strip('"\'')
    return fields


def load_yaml(path):
    """Parse YAML with PyYAML or Ruby; return (data, error). data is None if no parser."""
    try:
        import yaml  # type: ignore
        with open(path, encoding="utf-8") as fh:
            return yaml.safe_load(fh), None
    except ImportError:
        pass
    except Exception as exc:  # noqa: BLE001
        return None, str(exc)
    if shutil.which("ruby"):
        r = subprocess.run(["ruby", "-ryaml", "-rjson", "-e",
                            "puts JSON.generate(YAML.load_file(ARGV[0]))", path],
                           capture_output=True, text=True)
        if r.returncode != 0:
            return None, r.stderr.strip().splitlines()[-1] if r.stderr else "parse error"
        return json.loads(r.stdout), None
    return None, None


def check_agents():
    agents = sorted(f for f in os.listdir(".claude/agents") if f.endswith(".md"))
    if not agents:
        fail("agents", "no agent files in .claude/agents/")
    for f in agents:
        fm = frontmatter(read(f".claude/agents/{f}"))
        name = f[:-3]
        if fm is None:
            fail("agents", f"{f}: missing --- frontmatter")
            continue
        if fm.get("name") != name:
            fail("agents", f"{f}: name is {fm.get('name')!r}, expected {name!r}")
        if len(fm.get("description", "")) < 20:
            fail("agents", f"{f}: description missing or too short")
    for d in os.listdir(".claude/agents"):
        if os.path.isdir(f".claude/agents/{d}"):
            fail("agents", f".claude/agents/{d}/ is a folder; agents must be flat .md files")
    return [a[:-3] for a in agents]


def check_skills():
    base = ".claude/skills"
    if not os.path.isdir(base):
        return
    for d in sorted(os.listdir(base)):
        path = f"{base}/{d}/SKILL.md"
        if not os.path.isfile(path):
            fail("skills", f"{base}/{d}/ has no SKILL.md")
            continue
        fm = frontmatter(read(path))
        if fm is None or fm.get("name") != d or len(fm.get("description", "")) < 20:
            fail("skills", f"{path}: frontmatter needs name: {d} and a description")


def check_settings():
    try:
        data = json.loads(read(".claude/settings.json"))
    except Exception as exc:  # noqa: BLE001
        fail("settings", f"settings.json is not valid JSON: {exc}")
        return
    perms = data.get("permissions", {})
    for key in ("allow", "deny"):
        if not isinstance(perms.get(key), list):
            fail("settings", f"permissions.{key} must be a list")
    deny = " ".join(perms.get("deny", []))
    for must in ("--force", "git push *+*", "--delete", "gh pr merge", "mergePullRequest", "gh repo delete",
                 "gh issue delete", "gh project delete", "reset --hard", "cat *.env", "pkill"):
        if must not in deny:
            fail("settings", f"deny list does not block {must!r}")
    for bad in ("Bash(gh *)", "Bash(git *)", "Bash(python3 *)"):
        if bad in perms.get("allow", []):
            fail("settings", f"allow list still has blanket {bad}")


def check_yaml_and_board():
    paths = [".claude/board-config.yml"] + sorted(
        f".claude/{f}" for f in os.listdir(".claude") if re.match(r"stack-.*\.yml$", f))
    paths += sorted(f"templates/SETUP-TICKETS/{d}/manifest.yml"
                    for d in os.listdir("templates/SETUP-TICKETS")
                    if os.path.isfile(f"templates/SETUP-TICKETS/{d}/manifest.yml"))
    parsed = {}
    no_parser = False
    for p in paths:
        data, err = load_yaml(p)
        if err:
            fail("yaml", f"{p}: {err}")
        elif data is None and err is None and not os.path.getsize(p) == 0:
            no_parser = True
        parsed[p] = data
    if no_parser:
        print("note: no YAML parser (PyYAML or ruby) found; YAML syntax not checked")
    for s in ("stack-be.yml", "stack-fe.yml"):
        if not os.path.isfile(f".claude/{s}"):
            fail("yaml", f".claude/{s} is missing (agents read it)")

    text = read(".claude/board-config.yml")
    for key in STATUS_KEYS + PRIORITY_KEYS:
        m = re.search(rf"^\s+{key}:\s*([0-9a-f]{{8}})\b", text, re.M)
        if not m:
            fail("board", f"board-config.yml: {key} has no 8-hex option ID")
    for key in ("project_id", "status_field_id", "priority_field_id"):
        if not re.search(rf"^\s+{key}:\s*PVT\w+", text, re.M):
            fail("board", f"board-config.yml: {key} has no project/field ID")
    if "<" in re.sub(r"#.*", "", text):
        fail("board", "board-config.yml still has a <placeholder> outside comments")
    return parsed


def check_columns(files):
    kanban = read(".claude/rules/kanban-workflow.md")
    for c in COLUMNS:
        if c not in kanban:
            fail("columns", f"kanban-workflow.md does not name column {c!r}")


def check_cursor(agents):
    mdc = {f[:-4] for f in os.listdir(".cursor/rules") if f.endswith(".mdc")}
    rules = {f[:-3] for f in os.listdir(".claude/rules") if f.endswith(".md")}
    for r in sorted(rules - mdc):
        fail("cursor", f".claude/rules/{r}.md has no .cursor/rules/{r}.mdc")
    for a in agents:
        if f"persona-{a}" not in mdc:
            fail("cursor", f"agent {a} has no .cursor/rules/persona-{a}.mdc")
    allowed = rules | {f"persona-{a}" for a in agents} | {"framework-agents"}
    for m in sorted(mdc - allowed):
        fail("cursor", f".cursor/rules/{m}.mdc has no Claude source")
    for m in sorted(mdc):
        text = read(f".cursor/rules/{m}.mdc")
        fm = frontmatter(text)
        if fm is None or not fm.get("description"):
            fail("cursor", f"{m}.mdc: frontmatter needs a description")
            continue
        if "alwaysApply" not in fm:
            fail("cursor", f"{m}.mdc: frontmatter needs alwaysApply: true|false")
        src = f".claude/agents/{m[8:]}.md" if m.startswith("persona-") else f".claude/rules/{m}.md"
        if m != "framework-agents" and src not in text:
            fail("cursor", f"{m}.mdc does not point at its source {src}")


def check_manifests(parsed):
    ids = {}
    entries = []
    for p, data in parsed.items():
        if not p.endswith("manifest.yml") or not isinstance(data, dict):
            continue
        folder = os.path.dirname(p)
        for t in data.get("tickets", []) or []:
            if not isinstance(t, dict):
                continue
            tid = t.get("id")
            if tid in ids:
                fail("manifests", f"id {tid} defined in both {ids[tid]} and {p}")
            ids[tid] = p
            entries.append((p, folder, t))
    for p, folder, t in entries:
        tmpl = t.get("template")
        if tmpl and not (os.path.isfile(os.path.join(folder, tmpl)) or os.path.isfile(tmpl)):
            fail("manifests", f"{p}: {t.get('id')} template {tmpl} not found")
        for dep in t.get("depends_on", []) or []:
            if dep not in ids:
                fail("manifests", f"{p}: {t.get('id')} depends on unknown id {dep}")


def check_paths(files):
    for f in files:
        if f.startswith("archive/") or not f.endswith((".md", ".mdc", ".yml", ".yaml")):
            continue
        text = read(f)
        for m in re.finditer(r"\]\(([^)#\s|]+)\)", text):
            target = m.group(1)
            if re.match(r"(https?:|mailto:|<)", target):
                continue
            if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(f), target))):
                fail("paths", f"{f}: link to missing {target}")
        for m in re.finditer(r"`((?:\.claude|\.cursor|templates|docs|bin)/[^`\s*<>{}$]+)`", text):
            target = m.group(1).rstrip(".,:;)")
            if PROJECT_FILES.match(target) and not target.startswith(".claude/board-config"):
                continue
            if not os.path.exists(target):
                fail("paths", f"{f}: names missing path {target}")


def check_scripts():
    for f in sorted(os.listdir("bin")):
        if f.endswith(".sh"):
            r = subprocess.run(["bash", "-n", f"bin/{f}"], capture_output=True, text=True)
            if r.returncode != 0:
                fail("scripts", f"bin/{f}: {r.stderr.strip()}")


def check_leftovers(files):
    for f in files:
        if f.startswith("archive/") or f == "bin/check-framework.py":
            continue
        try:
            text = read(f)
        except UnicodeDecodeError:
            continue
        for n, line in enumerate(text.splitlines(), 1):
            if LEFTOVERS.search(line):
                fail("leftovers", f"{f}:{n}: {line.strip()[:100]}")


def main():
    files = tracked_files()
    agents = check_agents()
    check_skills()
    check_settings()
    parsed = check_yaml_and_board()
    check_columns(files)
    check_cursor(agents)
    check_manifests(parsed)
    check_paths(files)
    check_scripts()
    check_leftovers(files)
    if failures:
        print("\n".join(failures))
        print(f"\n{len(failures)} problem(s) found.")
        return 1
    print("All framework checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
