#!/usr/bin/env bash
# Show an ingress, its backend services, endpoints, and TLS status

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <ingress> [namespace]"
  exit 1
fi

INGRESS=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

echo "=== Ingress: $INGRESS (ns: $NAMESPACE) ==="
kubectl get ingress "$INGRESS" -n "$NAMESPACE"

echo ""
echo "=== Rules ==="
kubectl get ingress "$INGRESS" -n "$NAMESPACE" -o json | jq -r '
.spec.rules[]? |
.host as $host |
.http.paths[]? |
"\($host)  \(.path // "/")  -> \(.backend.service.name):\(.backend.service.port.number // .backend.service.port.name)"'

echo ""
echo "=== TLS ==="
kubectl get ingress "$INGRESS" -n "$NAMESPACE" -o json | jq -r '
.spec.tls[]? |
"secret: \(.secretName // "none")  hosts: \(.hosts // [] | join(", "))"' \
  || echo "No TLS configured"

echo ""
echo "=== Backend Services & Endpoints ==="
services=$(kubectl get ingress "$INGRESS" -n "$NAMESPACE" -o json \
  | jq -r '.spec.rules[]?.http.paths[]?.backend.service.name' | sort -u)

for svc in $services; do
  echo "--- Service: $svc ---"
  kubectl get svc "$svc" -n "$NAMESPACE" 2>/dev/null || echo "Service not found: $svc"
  echo "Endpoints:"
  kubectl get endpoints "$svc" -n "$NAMESPACE" 2>/dev/null || echo "No endpoints found"
  echo ""
done
