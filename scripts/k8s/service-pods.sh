#!/usr/bin/env bash
# Finds pods matching a service selector

set -euo pipefail

SERVICE=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

selector=$(kubectl get svc "$SERVICE" -n "$NAMESPACE" -o jsonpath='{.spec.selector}')

if [ -z "$selector" ]; then
    echo "Service has no selector"
    exit 1
fi

echo "Service selector: $selector"

key=$(echo "$selector" | jq -r 'keys[0]')
value=$(echo "$selector" | jq -r '.[]')

echo ""
echo "Matching pods:"

kubectl get pods -n "$NAMESPACE" -l "$key=$value"
