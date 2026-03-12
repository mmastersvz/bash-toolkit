#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <secret-name> [namespace]"
    exit 1
fi

SECRET=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

kubectl get secret "$SECRET" -n "$NAMESPACE" -o json \
| jq -r '.data | to_entries[] | "\(.key): \(.value)"' \
| while IFS=": " read -r key value; do
    echo "$key: $(echo "$value" | base64 --decode)"
done
