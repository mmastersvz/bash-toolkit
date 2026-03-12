#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <deployment> [namespace]"
    exit 1
fi

DEPLOYMENT=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

pods=$(kubectl get pods -n "$NAMESPACE" \
  -l app="$DEPLOYMENT" \
  -o jsonpath='{.items[*].metadata.name}')

if [ -z "$pods" ]; then
    echo "No pods found for deployment $DEPLOYMENT in namespace $NAMESPACE"
    exit 1
fi

for pod in $pods; do
    echo ""
    echo "========== $pod =========="
    kubectl logs "$pod" -n "$NAMESPACE" --tail=100
done
