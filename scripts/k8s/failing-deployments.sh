#!/usr/bin/env bash
# Identifies deployments with fewer ready replicas than desired

set -euo pipefail

echo "Checking deployments..."

kubectl get deployments -A -o json \
| jq -r '
.items[] |
select(.status.readyReplicas != .status.replicas) |
"\(.metadata.namespace) \(.metadata.name) ready:\(.status.readyReplicas // 0)/\(.status.replicas)"
'
