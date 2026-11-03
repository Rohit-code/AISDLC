#!/usr/bin/env bash
# aisdlc-observe — file a one-line framework-gap ticket on the framework board (AISDLC Backlog)
#
# Usage:
#   aisdlc-observe --type <rule|pattern|drift|agent> \
#                  --project <project-slug> \
#                  --ticket <N> \
#                  --summary "<one-line>" \
#                  [--context "<1-3 lines>"] \
#                  [--dry-run]
#
# Examples:
#   aisdlc-observe --type rule --project erp --ticket 45 \
#     --summary "size-audit silent on background-job modules" \
#     --context "jobs/InvoiceScheduler.java is 2100 LOC; no threshold defined for background-job files"
#
#   aisdlc-observe --type agent --project erp --ticket 52 \
#     --summary "@fe-builder missing a11y guidance" \
#     --context "building new Invoice Edit screen; spec has nothing on ARIA / keyboard nav"
#
# Board settings come from .claude/board-config.yml (next to this script's repo).
# Env vars override them: AISDLC_PROJECT_ID, AISDLC_STATUS_FIELD_ID,
# AISDLC_BACKLOG_OPTION_ID, AISDLC_REPO, AISDLC_OWNER, AISDLC_PROJECT_NUMBER.
#
# --dry-run prints what would be created and calls nothing.
#
# Non-negotiables (per .claude/rules/framework-observation.md):
# - Zero ceremony. No gate. No pause of the current project work.
# - Framework board only. Project-specific issues go on project board.
# - One ticket per gap. Never bundle.
# - Backlog only (never FRD Draft — triage promotes).

set -euo pipefail

HEADER_LAST_LINE=31

usage() {
  sed -n "2,${HEADER_LAST_LINE}s/^# \{0,1\}//p" "$0"
}

GAP_TYPE=""
PROJECT=""
TICKET=""
SUMMARY=""
CONTEXT=""
DRY_RUN=0

need_value() {
  # $1 = flag, $2 = number of remaining args (including the flag)
  if [[ "$2" -lt 2 ]]; then
    echo "Missing value for $1." >&2
    usage >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)    need_value "$1" "$#"; GAP_TYPE="$2"; shift 2 ;;
    --project) need_value "$1" "$#"; PROJECT="$2"; shift 2 ;;
    --ticket)  need_value "$1" "$#"; TICKET="$2";  shift 2 ;;
    --summary) need_value "$1" "$#"; SUMMARY="$2"; shift 2 ;;
    --context) need_value "$1" "$#"; CONTEXT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      usage
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$GAP_TYPE" || -z "$PROJECT" || -z "$TICKET" || -z "$SUMMARY" ]]; then
  echo "Missing required arg. Need --type, --project, --ticket, --summary." >&2
  echo "Run with --help for usage." >&2
  exit 1
fi

# Map type to label (per Board-Labels.md framework-board-only section)
case "$GAP_TYPE" in
  rule)    LABEL="gap:rule" ;;
  pattern) LABEL="gap:pattern" ;;
  drift)   LABEL="gap:drift" ;;
  agent)   LABEL="gap:agent" ;;
  *)
    echo "Invalid --type. Must be one of: rule, pattern, drift, agent." >&2
    exit 1 ;;
esac

# --- Board settings: env var -> .claude/board-config.yml -> error ------------
BOARD_CONFIG="$(cd "$(dirname "$0")/.." && pwd)/.claude/board-config.yml"

# First value of a "key: value" line (comments and quotes stripped).
cfg() {
  [[ -f "$BOARD_CONFIG" ]] || return 0
  grep -E "^[[:space:]]*$1:" "$BOARD_CONFIG" | head -n 1 \
    | sed -E "s/^[[:space:]]*$1:[[:space:]]*//; s/[[:space:]]+#.*$//; s/^\"//; s/\"$//"
}

CFG_URL="$(cfg url)"
# url is https://github.com/users/<login>/projects/<N> or https://github.com/orgs/<org>/projects/<N>
CFG_OWNER="$(printf '%s' "$CFG_URL" | sed -n -E 's#^https://github.com/(users|orgs)/([^/]+)/projects/.*#\2#p')"

PROJECT_ID="${AISDLC_PROJECT_ID:-$(cfg project_id)}"
STATUS_FIELD_ID="${AISDLC_STATUS_FIELD_ID:-$(cfg status_field_id)}"
BACKLOG_OPTION_ID="${AISDLC_BACKLOG_OPTION_ID:-$(cfg backlog)}"
REPO="${AISDLC_REPO:-$(cfg repo)}"
OWNER="${AISDLC_OWNER:-$CFG_OWNER}"
PROJECT_NUMBER="${AISDLC_PROJECT_NUMBER:-$(cfg project_number)}"

MISSING=""
[[ -n "$PROJECT_ID" ]]        || MISSING="$MISSING project_id(AISDLC_PROJECT_ID)"
[[ -n "$STATUS_FIELD_ID" ]]   || MISSING="$MISSING status_field_id(AISDLC_STATUS_FIELD_ID)"
[[ -n "$BACKLOG_OPTION_ID" ]] || MISSING="$MISSING status_options.backlog(AISDLC_BACKLOG_OPTION_ID)"
[[ -n "$REPO" ]]              || MISSING="$MISSING repo(AISDLC_REPO)"
[[ -n "$OWNER" ]]             || MISSING="$MISSING url-owner(AISDLC_OWNER)"
[[ -n "$PROJECT_NUMBER" ]]    || MISSING="$MISSING project_number(AISDLC_PROJECT_NUMBER)"
if [[ -n "$MISSING" ]]; then
  echo "Board settings missing:$MISSING" >&2
  echo "Set them in $BOARD_CONFIG or via the env vars shown." >&2
  exit 1
fi

TITLE="Framework gap: $SUMMARY"
BODY="## Hit while working

${PROJECT}#${TICKET}

## Gap type

${GAP_TYPE}

## Context

${CONTEXT:-(no context provided)}

## Proposed next

triage"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "DRY RUN — nothing created."
  echo "repo:           $REPO"
  echo "title:          $TITLE"
  echo "label:          $LABEL"
  echo "board:          project $PROJECT_NUMBER owned by $OWNER ($PROJECT_ID)"
  echo "status:         field $STATUS_FIELD_ID -> option $BACKLOG_OPTION_ID (Backlog)"
  echo "body:"
  printf '%s\n' "$BODY" | sed 's/^/  /'
  exit 0
fi

ERRFILE="$(mktemp "${TMPDIR:-/tmp}/aisdlc-observe.XXXXXX")"
trap 'rm -f "$ERRFILE"' EXIT

echo "Filing framework-gap ticket..." >&2
URL=$(gh issue create --repo "$REPO" \
  --title "$TITLE" \
  --body "$BODY" \
  --label "$LABEL" 2>"$ERRFILE" | tail -n 1) || URL=""

if [[ -z "$URL" ]]; then
  FIRST_ERR="$(cat "$ERRFILE")"
  # Retry without label (label may not exist yet in repo)
  URL=$(gh issue create --repo "$REPO" \
    --title "$TITLE" \
    --body "$BODY" 2>"$ERRFILE" | tail -n 1) || URL=""
  if [[ -z "$URL" ]]; then
    echo "Could not create the issue in $REPO." >&2
    echo "With label '$LABEL': $FIRST_ERR" >&2
    echo "Without label: $(cat "$ERRFILE")" >&2
    exit 1
  fi
  echo "Warning: label '$LABEL' not applied ($FIRST_ERR)." >&2
fi

# The issue exists from here on: print it at once so it is never lost.
echo "Issue created: $URL" >&2

if ! ITEM_ID=$(gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$URL" \
      --format json --jq .id 2>"$ERRFILE") || [[ -z "$ITEM_ID" ]]; then
  echo "Issue $URL was created but could not be added to board $OWNER/$PROJECT_NUMBER: $(cat "$ERRFILE")" >&2
  echo "Add it by hand: gh project item-add $PROJECT_NUMBER --owner $OWNER --url $URL" >&2
  exit 2
fi

if ! gh project item-edit \
  --project-id "$PROJECT_ID" \
  --id "$ITEM_ID" \
  --field-id "$STATUS_FIELD_ID" \
  --single-select-option-id "$BACKLOG_OPTION_ID" >/dev/null 2>"$ERRFILE"; then
  echo "Issue $URL is on the board but its Status was not set to Backlog: $(cat "$ERRFILE")" >&2
  echo "Set it by hand: gh project item-edit --project-id $PROJECT_ID --id $ITEM_ID --field-id $STATUS_FIELD_ID --single-select-option-id $BACKLOG_OPTION_ID" >&2
  exit 3
fi

echo "$URL"
