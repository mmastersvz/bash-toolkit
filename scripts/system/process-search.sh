#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <process-name>"
    exit 1
fi

pgrep -a -i "$1"
