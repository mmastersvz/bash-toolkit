#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

LOGFILE=$1

if [ ! -f "$LOGFILE" ]; then
    echo "Log file not found"
    exit 1
fi

echo "Top ERROR messages:"
grep -i "error" "$LOGFILE" \
    | sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}.*/ERROR/' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -10

echo ""
echo "Top WARN messages:"
grep -i "warn" "$LOGFILE" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -10
