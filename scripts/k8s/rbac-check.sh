#!/usr/bin/env bash
# Show effective permissions for a service account using kubectl auth can-i --list

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <serviceaccount> [namespace]"
  exit 1
fi

SA=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

echo "=== RBAC permissions for serviceaccount: $SA (ns: $NAMESPACE) ==="
echo ""

kubectl auth can-i --list \
  --as "system:serviceaccount:$NAMESPACE:$SA" \
  -n "$NAMESPACE"

echo ""
echo "=== RoleBindings ==="
kubectl get rolebindings -n "$NAMESPACE" -o json | jq -r \
  --arg sa "$SA" \
  --arg ns "$NAMESPACE" '
.items[] |
select(.subjects[]? | .kind == "ServiceAccount" and .name == $sa and (.namespace // $ns) == $ns) |
"  \(.metadata.name) -> role: \(.roleRef.name) (\(.roleRef.kind))"'

echo ""
echo "=== ClusterRoleBindings ==="
kubectl get clusterrolebindings -o json | jq -r \
  --arg sa "$SA" \
  --arg ns "$NAMESPACE" '
.items[] |
select(.subjects[]? | .kind == "ServiceAccount" and .name == $sa and .namespace == $ns) |
"  \(.metadata.name) -> clusterrole: \(.roleRef.name)"'
