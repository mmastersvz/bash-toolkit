#!/usr/bin/env bash
set -euo pipefail

ORG=${1:-${ORG:-}}

if [[ -z "$ORG" ]]; then
    echo "Usage: $0 <org>  (or set ORG env var)" >&2
    exit 1
fi

echo "=== Org-level secrets ==="
gh api "orgs/$ORG/actions/secrets" --paginate --jq '.secrets[].name' | sort

echo ""
echo "=== Repo-level secrets ==="
gh repo list "$ORG" --limit 1000 --json name -q '.[].name' | while read -r repo; do
    gh api "repos/$ORG/$repo/actions/secrets" --paginate --jq '.secrets[].name' 2>/dev/null | \
    while read -r secret; do
        printf '%s\t%s\n' "$repo" "$secret"
    done
done | sort | column -t -s $'\t'
