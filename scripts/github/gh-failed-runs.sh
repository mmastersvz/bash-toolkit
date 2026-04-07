#!/usr/bin/env bash
set -euo pipefail

ORG=${1:-${ORG:-}}

if [[ -z "$ORG" ]]; then
    echo "Usage: $0 <org>  (or set ORG env var)" >&2
    exit 1
fi

printf 'REPO\tWORKFLOW\tCONCLUSION\n'

gh repo list "$ORG" --limit 1000 --json name,defaultBranchRef \
    --jq '.[] | [.name, .defaultBranchRef.name] | @tsv' | \
while IFS=$'\t' read -r repo branch; do
    # $repo inside single quotes is a jq variable passed via --arg, not a shell variable
    # shellcheck disable=SC2016
    gh run list \
        --repo "$ORG/$repo" \
        --branch "$branch" \
        --limit 1 \
        --json workflowName,conclusion 2>/dev/null | \
    jq -r --arg repo "$repo" \
        '.[] | select(.conclusion == "failure") | [$repo, .workflowName, .conclusion] | @tsv' || true
done | column -t -s $'\t'
