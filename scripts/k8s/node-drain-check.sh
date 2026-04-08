#!/usr/bin/env bash
# Preview what would happen when draining a node: pods to evict, PDB blockers, DaemonSets

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <node>"
  exit 1
fi

NODE=$1

echo "=== Drain preview for node: $NODE ==="
echo ""

echo "--- Pods on this node ---"
kubectl get pods -A \
  --field-selector "spec.nodeName=$NODE" \
  -o wide

echo ""
echo "--- DaemonSet pods (will not be evicted) ---"
kubectl get pods -A \
  --field-selector "spec.nodeName=$NODE" \
  -o json \
| jq -r '
.items[] |
select(.metadata.ownerReferences[]? | .kind == "DaemonSet") |
"\(.metadata.namespace)  \(.metadata.name)  owner:\(.metadata.ownerReferences[].name)"'

echo ""
echo "--- PodDisruptionBudgets in cluster (may block eviction) ---"
kubectl get pdb -A -o json | jq -r '
.items[] |
select(.status.disruptionsAllowed == 0) |
"\(.metadata.namespace)  \(.metadata.name)  disruptionsAllowed:\(.status.disruptionsAllowed)  minAvailable:\(.spec.minAvailable // "n/a")  maxUnavailable:\(.spec.maxUnavailable // "n/a")"' \
| column -t -s "  " || echo "None found with disruptionsAllowed=0"

echo ""
echo "--- Drain dry-run ---"
kubectl drain "$NODE" \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --dry-run=client 2>&1 || true
