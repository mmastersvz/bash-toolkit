#!/usr/bin/env bash

set -euo pipefail

HOST=${1:-localhost}
START_PORT=${2:-1}
END_PORT=${3:-1024}

echo "Scanning $HOST ports $START_PORT-$END_PORT"

for ((port=START_PORT; port<=END_PORT; port++)); do
    timeout 1 bash -c "echo >/dev/tcp/$HOST/$port" 2>/dev/null \
        && echo "Port $port OPEN"
done
