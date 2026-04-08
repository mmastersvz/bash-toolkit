#!/usr/bin/env bash
set -euo pipefail

ORG=${1:-${ORG:-}}
DAYS=${2:-14}

if [[ -z "$ORG" ]]; then
    echo "Usage: $0 <org> [days]" >&2
    exit 1
fi

CUTOFF=$(date -d "$DAYS days ago" +%Y-%m-%d)

printf 'REPO\tPR\tLAST UPDATED\tAUTHOR\tTITLE\n'

gh repo list "$ORG" --limit 1000 --json name -q '.[].name' | while read -r repo; do
    # $repo and $cutoff inside single quotes are jq variables passed via --arg, not shell variables
    # shellcheck disable=SC2016
    gh pr list \
        --repo "$ORG/$repo" \
        --state open \
        --json number,title,author,updatedAt | \
    jq -r --arg repo "$repo" --arg cutoff "$CUTOFF" \
        '.[] | select(.updatedAt[:10] <= $cutoff) | [$repo, ("#"+(.number|tostring)), .updatedAt[:10], .author.login, .title] | @tsv'
done | column -t -s $'\t'
