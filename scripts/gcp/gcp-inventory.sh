#!/usr/bin/env bash
# gcp-inventory.sh - List (almost) everything in a GCP project
# Usage:
#   ./gcp-inventory.sh [PROJECT_ID] [--table|--csv]
#   ./gcp-inventory.sh --csv my-project-123
#   ./gcp-inventory.sh                   # defaults to current gcloud project + table view

set -euo pipefail

# ──── Parse arguments ───────────────────────────────────────────────────────────

OUTPUT_MODE="table"           # default
PROJECT_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --csv)
      OUTPUT_MODE="csv"
      shift
      ;;
    --table)
      OUTPUT_MODE="table"
      shift
      ;;
    *)
      if [[ -z "$PROJECT_ID" ]]; then
        PROJECT_ID="$1"
      else
        echo "Error: Unexpected argument '$1'"
        echo "Usage: $0 [PROJECT_ID] [--table|--csv]"
        exit 1
      fi
      shift
      ;;
  esac
done

# If no project given on command line, use current gcloud config
PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || echo '')}"

if [[ -z "$PROJECT_ID" ]]; then
  echo "Error: No project ID provided and none set in gcloud config."
  echo "Usage: $0 [PROJECT_ID] [--table|--csv]"
  exit 1
fi

# ──── Header ────────────────────────────────────────────────────────────────────

echo "┌────────────────────────────────────────────────────────────┐"
echo "│  GCP Inventory"
echo "│  Project: $PROJECT_ID"
echo "│  Date   : $(date --utc '+%Y-%m-%d %H:%M UTC')"
echo "│  Mode   : $OUTPUT_MODE"
echo "└────────────────────────────────────────────────────────────┘"
echo

# ──── Common count (works for both modes) ───────────────────────────────────────

echo "Counting total resources (this may take a few seconds)..."
TOTAL_RESOURCES=$(gcloud asset search-all-resources \
  --scope="projects/$PROJECT_ID" \
  --format='value(name)' --quiet | wc -l | tr -d '[:space:]')

echo "Total resources found: $TOTAL_RESOURCES"
echo

# ──── Main output ───────────────────────────────────────────────────────────────

case "$OUTPUT_MODE" in
  table)
    echo "=== Resources (sorted by type) ==="
    echo "(showing assetType, short name, location, display name)"
    echo

    gcloud asset search-all-resources \
      --scope="projects/$PROJECT_ID" \
      --format="table(assetType, name.basename(), location, displayName)" \
      --sort-by=assetType \
      || { echo "Warning: command failed or output truncated — try piping to less"; exit 1; }
    ;;

  csv)
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    OUTPUT_FILE="${PROJECT_ID}-inventory-${TIMESTAMP}.csv"

    echo "=== Exporting CSV ==="
    echo "Writing to: $OUTPUT_FILE"
    echo

    gcloud asset search-all-resources \
      --scope="projects/$PROJECT_ID" \
      --format="csv(assetType, name, project, location, displayName, createTime, updateTime, state)" \
      > "$OUTPUT_FILE" \
      || { echo "Error: export failed"; exit 1; }

    echo "Export complete."
    echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    echo "First few lines:"
    head -n 5 "$OUTPUT_FILE"
    ;;

  *)
    echo "Internal error: unknown output mode '$OUTPUT_MODE'"
    exit 2
    ;;
esac

echo
echo "Done."
