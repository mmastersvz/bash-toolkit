#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <process-name>"
    exit 1
fi

ps aux | grep -i "$1" | grep -v grep
