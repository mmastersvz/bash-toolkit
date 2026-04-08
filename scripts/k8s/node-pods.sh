#!/usr/bin/env bash
# List all pods scheduled on a specific node

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <node>"
  exit 1
fi

NODE=$1

kubectl get pods -A \
  --field-selector "spec.nodeName=$NODE" \
  -o wide
