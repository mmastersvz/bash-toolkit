#!/usr/bin/env bash
# Test TCP connectivity from a pod to a target host:port

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <pod> <host:port> [namespace]"
  echo "Example: $0 my-pod my-service:5432 staging"
  exit 1
fi

POD=$1
TARGET=$2
NAMESPACE=${3:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

HOST=${TARGET%%:*}
PORT=${TARGET##*:}

echo "Testing connectivity from pod/$POD -> $TARGET (ns: $NAMESPACE)"
echo ""

echo "=== DNS resolution for $HOST ==="
kubectl exec "$POD" -n "$NAMESPACE" -- \
  sh -c "nslookup $HOST 2>/dev/null || getent hosts $HOST 2>/dev/null || echo 'nslookup/getent not available'" || true

echo ""
echo "=== TCP connectivity to $HOST:$PORT ==="
kubectl exec "$POD" -n "$NAMESPACE" -- \
  sh -c "
    if command -v nc >/dev/null 2>&1; then
      nc -zv -w5 $HOST $PORT && echo 'Connection succeeded' || echo 'Connection failed'
    elif command -v curl >/dev/null 2>&1; then
      curl -sv --connect-timeout 5 telnet://$HOST:$PORT 2>&1 | grep -E 'Connected|connect|refused|timeout' | head -5
    else
      echo 'nc and curl not available in this container'
    fi
  " || true

echo ""
echo "=== Endpoint check for service $HOST ==="
kubectl get endpoints "$HOST" -n "$NAMESPACE" 2>/dev/null || echo "No service named $HOST in namespace $NAMESPACE"
