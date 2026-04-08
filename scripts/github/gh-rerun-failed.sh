#!/usr/bin/env bash
set -euo pipefail

REPO=${1:-}

if [[ -z "$REPO" ]]; then
    echo "Usage: $0 <owner/repo>" >&2
    exit 1
fi

RUN_ID=$(gh run list \
    --repo "$REPO" \
    --limit 10 \
    --json databaseId,conclusion \
    --jq '.[] | select(.conclusion == "failure") | .databaseId' | head -1)

if [[ -z "$RUN_ID" ]]; then
    echo "No failed run found for $REPO" >&2
    exit 1
fi

echo "Re-running failed jobs for run $RUN_ID in $REPO..."
gh run rerun "$RUN_ID" --repo "$REPO" --failed
