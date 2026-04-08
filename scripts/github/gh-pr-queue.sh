#!/usr/bin/env bash
set -euo pipefail

ORG=${1:-${ORG:-}}

if [[ -z "$ORG" ]]; then
    echo "Usage: $0 <org>  (or set ORG env var)" >&2
    exit 1
fi

printf 'REPO\tPR\tAUTHOR\tCREATED\tREVIEW STATUS\tTITLE\n'

gh repo list "$ORG" --limit 1000 --json name -q '.[].name' | while read -r repo; do
    # $repo inside single quotes is a jq variable passed via --arg, not a shell variable
    # shellcheck disable=SC2016
    gh pr list \
        --repo "$ORG/$repo" \
        --state open \
        --json number,title,author,createdAt,reviewDecision | \
    jq -r --arg repo "$repo" \
        '.[] | [$repo, ("#"+(.number|tostring)), .author.login, .createdAt[:10], (.reviewDecision // "PENDING"), .title] | @tsv'
done | column -t -s $'\t'
