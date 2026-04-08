#!/usr/bin/env bash
set -euo pipefail

REPO=${1:-}
FROM_TAG=${2:-}
TO_TAG=${3:-HEAD}

if [[ -z "$REPO" || -z "$FROM_TAG" ]]; then
    echo "Usage: $0 <owner/repo> <from-tag> [to-tag]" >&2
    exit 1
fi

echo "## Release notes: $FROM_TAG -> $TO_TAG"
echo ""

gh api "repos/$REPO/compare/${FROM_TAG}...${TO_TAG}" --jq '
  .commits[] |
  select(.commit.message | startswith("Merge pull request")) |
  {
    pr: (.commit.message | capture("Merge pull request #(?P<n>[0-9]+)") | .n),
    title: (.commit.message | split("\n\n")[1] // ""),
    author: .author.login
  } |
  "- #\(.pr) \(.title) (@\(.author))"
'
