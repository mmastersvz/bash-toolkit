#!/usr/bin/env bash
set -euo pipefail

REPO=${1:-}
DAYS=${2:-30}

if [[ -z "$REPO" ]]; then
    echo "Usage: $0 <owner/repo> [days]" >&2
    exit 1
fi

cutoff_epoch=$(date -d "$DAYS days ago" +%s)

printf 'BRANCH\tLAST COMMIT\n'

gh api "repos/$REPO/branches" --paginate --jq '.[].name' | while read -r branch; do
    date_str=$(gh api "repos/$REPO/branches/$branch" --jq '.commit.commit.committer.date')
    branch_epoch=$(date -d "$date_str" +%s)
    if [[ "$branch_epoch" -lt "$cutoff_epoch" ]]; then
        printf '%s\t%s\n' "$branch" "${date_str%T*}"
    fi
done | sort -t $'\t' -k2 | column -t -s $'\t'
