#!/usr/bin/env bash

set -euo pipefail

TARGET=${1:-.}

echo "Top disk usage in $TARGET"

du -h "$TARGET" \
    | sort -hr \
    | head -20
