#!/usr/bin/env bash
# Spin up a throwaway busybox pod for cluster-side debugging

set -euo pipefail

NAMESPACE=${1:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

echo "Launching debug pod in namespace: $NAMESPACE"
echo "(pod will be deleted automatically on exit)"
echo ""

kubectl run debug-pod \
  -it --rm \
  --restart=Never \
  --namespace "$NAMESPACE" \
  --image=busybox \
  -- sh
