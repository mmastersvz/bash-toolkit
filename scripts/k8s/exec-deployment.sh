#!/usr/bin/env bash
# Run a command across all pods in a deployment and show output per pod

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <deployment> <command> [namespace]"
  echo "Example: $0 my-app 'printenv APP_ENV' staging"
  exit 1
fi

DEPLOYMENT=$1
CMD=$2
NAMESPACE=${3:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

pods=$(kubectl get pods -n "$NAMESPACE" \
  -l "app=$DEPLOYMENT" \
  --field-selector=status.phase=Running \
  -o jsonpath='{.items[*].metadata.name}')

if [ -z "$pods" ]; then
  # fall back to deployment label selector from the deployment spec
  selector=$(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" \
    -o jsonpath='{.spec.selector.matchLabels}' \
    | jq -r 'to_entries | map("\(.key)=\(.value)") | join(",")')
  pods=$(kubectl get pods -n "$NAMESPACE" \
    -l "$selector" \
    --field-selector=status.phase=Running \
    -o jsonpath='{.items[*].metadata.name}')
fi

if [ -z "$pods" ]; then
  echo "No running pods found for deployment $DEPLOYMENT in namespace $NAMESPACE"
  exit 1
fi

for pod in $pods; do
  echo ""
  echo "========== $pod =========="
  kubectl exec "$pod" -n "$NAMESPACE" -- sh -c "$CMD" 2>&1 || true
done
