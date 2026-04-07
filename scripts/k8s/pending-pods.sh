#!/usr/bin/env bash
# Show pending pods and the events explaining why they are stuck

set -euo pipefail

NAMESPACE=${1:-""}
NS_FLAG=${NAMESPACE:+-n "$NAMESPACE"}
NS_FLAG=${NS_FLAG:---all-namespaces}

pending=$(kubectl get pods $NS_FLAG -o json \
  | jq -r '.items[] | select(.status.phase == "Pending") | "\(.metadata.namespace)/\(.metadata.name)"')

if [ -z "$pending" ]; then
  echo "No pending pods found."
  exit 0
fi

while IFS='/' read -r ns pod; do
  echo "=========================================="
  echo "POD: $pod  NAMESPACE: $ns"
  echo "=========================================="

  echo ""
  echo "--- Conditions ---"
  kubectl get pod "$pod" -n "$ns" -o json \
    | jq -r '.status.conditions[]? | "\(.type): \(.status)  \(.reason // "")  \(.message // "")"'

  echo ""
  echo "--- Events ---"
  kubectl get events -n "$ns" \
    --field-selector "involvedObject.name=$pod" \
    --sort-by=.metadata.creationTimestamp \
    | tail -10

  echo ""
done <<< "$pending"
