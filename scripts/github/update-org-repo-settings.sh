#!/usr/bin/env bash

# Update ORG
# ORG=org-name

if [ -z "${ORG:-}" ]; then
    echo "Error: ORG environment variable is not set" >&2
    echo "Example usage:" >&2
    echo "  export ORG=mycompany" >&2
    echo "  $0" >&2
    exit 1
fi

echo "Updating repositories in organization: $ORG"

gh repo list "$ORG" --limit 1000 --json name -q '.[].name' |
while read -r repo; do
  echo "Updating $repo"
  gh api \
    --method PATCH \
    /repos/"$ORG"/"$repo" \
    -f delete_branch_on_merge=true >/dev/null
done