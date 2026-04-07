#!/usr/bin/env bash
set -euo pipefail

ORG=${1:-${ORG:-}}

if [[ -z "$ORG" ]]; then
    echo "Usage: $0 <org>  (or set ORG env var)" >&2
    exit 1
fi

printf 'REPO\tBRANCH PROTECTION\tCODEOWNERS\tREQUIRED REVIEWS\n'

gh repo list "$ORG" --limit 1000 --json name,defaultBranchRef \
    --jq '.[] | [.name, .defaultBranchRef.name] | @tsv' | \
while IFS=$'\t' read -r repo branch; do
    if gh api "repos/$ORG/$repo/branches/$branch/protection" >/dev/null 2>&1; then
        protection="enabled"
    else
        protection="disabled"
    fi

    codeowners="no"
    for co_path in CODEOWNERS .github/CODEOWNERS docs/CODEOWNERS; do
        if gh api "repos/$ORG/$repo/contents/$co_path" >/dev/null 2>&1; then
            codeowners="yes"
            break
        fi
    done

    required_reviews=$(gh api \
        "repos/$ORG/$repo/branches/$branch/protection/required_pull_request_reviews" \
        --jq '.required_approving_review_count' 2>/dev/null || echo "0")

    printf '%s\t%s\t%s\t%s\n' "$repo" "$protection" "$codeowners" "$required_reviews"
done | column -t -s $'\t'
