#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <port>"
    exit 1
fi

PORT=$1

echo "Checking port $PORT..."

if lsof -i :"$PORT" > /dev/null 2>&1; then
    echo "Port $PORT is in use:"
    lsof -i :"$PORT"
else
    echo "Port $PORT is free"
fi
