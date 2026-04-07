#!/usr/bin/env bash
# All-in-one pod debugger: describe, logs (all containers), and related events

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <pod> [namespace]"
  exit 1
fi

POD=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

divider() { echo ""; echo "══════════════════════════════════════════════"; echo "  $1"; echo "══════════════════════════════════════════════"; }

divider "DESCRIBE: $POD"
kubectl describe pod "$POD" -n "$NAMESPACE"

divider "LOGS"
containers=$(kubectl get pod "$POD" -n "$NAMESPACE" \
  -o jsonpath='{.spec.containers[*].name}')
init_containers=$(kubectl get pod "$POD" -n "$NAMESPACE" \
  -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null || true)

for c in $init_containers; do
  echo ""
  echo "--- init container: $c (previous) ---"
  kubectl logs "$POD" -n "$NAMESPACE" -c "$c" --previous 2>/dev/null || true
  echo "--- init container: $c (current) ---"
  kubectl logs "$POD" -n "$NAMESPACE" -c "$c" --tail=100 2>/dev/null || true
done

for c in $containers; do
  echo ""
  echo "--- container: $c (previous) ---"
  kubectl logs "$POD" -n "$NAMESPACE" -c "$c" --previous 2>/dev/null || true
  echo "--- container: $c (current, last 100 lines) ---"
  kubectl logs "$POD" -n "$NAMESPACE" -c "$c" --tail=100
done

divider "EVENTS"
kubectl get events -n "$NAMESPACE" \
  --field-selector "involvedObject.name=$POD" \
  --sort-by=.metadata.creationTimestamp
