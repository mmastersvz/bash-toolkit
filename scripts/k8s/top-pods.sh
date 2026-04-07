#!/usr/bin/env bash
# List top pods by CPU or memory across all namespaces
# Usage: top-pods.sh [cpu|mem] [limit]   (defaults: cpu, 20)

set -euo pipefail

SORT=${1:-cpu}
LIMIT=${2:-20}

if ! kubectl top pods -A &>/dev/null; then
  echo "Error: metrics-server is not available in this cluster"
  exit 1
fi

raw=$(kubectl top pods -A --no-headers 2>/dev/null)

case "$SORT" in
  mem|memory)
    echo "Top $LIMIT pods by MEMORY"
    echo ""
    # strip 'Mi'/'Ki' and sort numerically on column 4
    printf "%-40s %-20s %10s %10s\n" "POD" "NAMESPACE" "CPU(cores)" "MEMORY"
    echo "$raw" \
      | awk '{mem=$4; gsub(/[A-Za-z]/,"",mem); print mem, $0}' \
      | sort -rn \
      | head -n "$LIMIT" \
      | awk '{printf "%-40s %-20s %10s %10s\n", $3, $2, $4, $5}'
    ;;
  cpu|*)
    echo "Top $LIMIT pods by CPU"
    echo ""
    printf "%-40s %-20s %10s %10s\n" "POD" "NAMESPACE" "CPU(cores)" "MEMORY"
    echo "$raw" \
      | awk '{cpu=$3; gsub(/[A-Za-z]/,"",cpu); print cpu, $0}' \
      | sort -rn \
      | head -n "$LIMIT" \
      | awk '{printf "%-40s %-20s %10s %10s\n", $3, $2, $4, $5}'
    ;;
esac
