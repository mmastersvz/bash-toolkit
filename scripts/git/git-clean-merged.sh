#!/usr/bin/env bash

set -euo pipefail

git fetch -p

echo "Removing merged branches..."

git branch --merged \
    | grep -v "\*" \
    | grep -v "main" \
    | grep -v "master" \
    | xargs -r git branch -d

echo "Done."
