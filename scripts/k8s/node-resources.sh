#!/usr/bin/env bash

set -euo pipefail

echo "Node Resource Usage"

kubectl top nodes 2>/dev/null || {
    echo "Metrics server not installed"
    exit 1
}
