#!/usr/bin/env bash
# Test DNS resolution and HTTP reachability from inside the cluster
# Execs into a running pod to run the checks

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <hostname-or-service> [namespace]"
  echo "Example: $0 my-service.staging.svc.cluster.local"
  exit 1
fi

TARGET=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

# Find any running pod in the namespace to exec into
POD=$(kubectl get pods -n "$NAMESPACE" \
  --field-selector=status.phase=Running \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [ -z "$POD" ]; then
  echo "No running pods found in namespace $NAMESPACE to exec into."
  exit 1
fi

echo "Using pod: $POD (ns: $NAMESPACE)"
echo ""

echo "=== DNS lookup: $TARGET ==="
kubectl exec "$POD" -n "$NAMESPACE" -- \
  sh -c "nslookup $TARGET 2>/dev/null || dig +short $TARGET 2>/dev/null || getent hosts $TARGET" || \
  echo "DNS lookup failed"

echo ""
echo "=== HTTP check: $TARGET ==="
kubectl exec "$POD" -n "$NAMESPACE" -- \
  sh -c "curl -sI --max-time 5 http://$TARGET 2>/dev/null | head -5 || wget -qS --spider --timeout=5 http://$TARGET 2>&1 | head -5" || \
  echo "HTTP check failed (curl/wget may not be available in this pod)"
