#!/usr/bin/env bash
# aisdlc-observe — file a one-line framework-gap ticket on the framework board (AISDLC Backlog)
#
# Usage:
#   aisdlc-observe --type <rule|pattern|drift|agent> \
#                  --project <project-slug> \
#                  --ticket <N> \
#                  --summary "<one-line>" \
#                  [--context "<1-3 lines>"]
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
# Non-negotiables (per .claude/rules/framework-observation.md):
# - Zero ceremony. No gate. No pause of the current project work.
# - Framework board only. Project-specific issues go on project board.
# - One ticket per gap. Never bundle.
# - Backlog only (never FRD Draft — triage promotes).

set -euo pipefail

GAP_TYPE=""
PROJECT=""
TICKET=""
SUMMARY=""
CONTEXT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)    GAP_TYPE="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --ticket)  TICKET="$2";  shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    --context) CONTEXT="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \?//'
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

PROJECT_ID="${AISDLC_PROJECT_ID:-PVT_kwHOAy3qVs4BqCgb}"
STATUS_FIELD_ID="${AISDLC_STATUS_FIELD_ID:-PVTSSF_lAHOAy3qVs4BqCgbzhobWqk}"
BACKLOG_OPTION_ID="${AISDLC_BACKLOG_OPTION_ID:-24c75ca4}"
REPO="${AISDLC_REPO:-Rohit-code/AISDLC}"

BODY="## Hit while working

${PROJECT}#${TICKET}

## Gap type

${GAP_TYPE}

## Context

${CONTEXT:-(no context provided)}

## Proposed next

triage"

echo "Filing framework-gap ticket..." >&2
URL=$(gh issue create --repo "$REPO" \
  --title "Framework gap: $SUMMARY" \
  --body "$BODY" \
  --label "$LABEL" 2>/dev/null | tail -n 1)

if [[ -z "$URL" ]]; then
  # Retry without label (label may not exist yet in repo)
  URL=$(gh issue create --repo "$REPO" \
    --title "Framework gap: $SUMMARY" \
    --body "$BODY" | tail -n 1)
  echo "Warning: label '$LABEL' not applied (may not exist in repo yet)." >&2
fi

ITEM_ID=$(gh project item-add "${AISDLC_PROJECT_NUMBER:-2}" --owner "${AISDLC_OWNER:-Rohit-code}" --url "$URL" --format json | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

gh project item-edit \
  --project-id "$PROJECT_ID" \
  --id "$ITEM_ID" \
  --field-id "$STATUS_FIELD_ID" \
  --single-select-option-id "$BACKLOG_OPTION_ID" > /dev/null

echo "$URL"
