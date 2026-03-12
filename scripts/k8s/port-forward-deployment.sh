#!/usr/bin/env bash
# Forwards a local port to the first pod of a deployment

set -euo pipefail

if [ $# -lt 3 ]; then
    echo "Usage: $0 <deployment> <local-port> <pod-port> [namespace]"
    exit 1
fi

DEPLOYMENT=$1
LOCAL_PORT=$2
POD_PORT=$3
NAMESPACE=${4:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

pod=$(kubectl get pods -n "$NAMESPACE" \
  -l app="$DEPLOYMENT" \
  -o jsonpath='{.items[0].metadata.name}')

if [ -z "$pod" ]; then
    echo "No pod found for deployment"
    exit 1
fi

echo "Forwarding localhost:$LOCAL_PORT -> $pod:$POD_PORT"

kubectl port-forward "$pod" "$LOCAL_PORT:$POD_PORT" -n "$NAMESPACE"
