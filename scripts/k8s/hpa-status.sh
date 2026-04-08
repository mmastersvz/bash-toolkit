#!/usr/bin/env bash
# Show all HPAs with current vs target metrics and recent scaling events

set -euo pipefail

NAMESPACE=${1:-""}
NS_FLAG=${NAMESPACE:+-n "$NAMESPACE"}
NS_FLAG=${NS_FLAG:---all-namespaces}

echo "=== HPA Status ==="
echo ""
kubectl get hpa "$NS_FLAG"

echo ""
echo "=== HPA Detail ==="
echo ""

kubectl get hpa "$NS_FLAG" -o json | jq -r '
.items[] |
"--- \(.metadata.namespace)/\(.metadata.name) ---",
"  Target:   \(.spec.scaleTargetRef.kind)/\(.spec.scaleTargetRef.name)",
"  Replicas: \(.status.currentReplicas) current / \(.spec.minReplicas)-\(.spec.maxReplicas) min-max",
"  Metrics:",
(.status.currentMetrics[]? |
  if .type == "Resource" then
    "    \(.resource.name): current=\(.resource.current.averageUtilization // .resource.current.averageValue // "n/a")  target=\(.resource.target.averageUtilization // .resource.target.averageValue // "n/a")"
  elif .type == "External" then
    "    external/\(.external.metric.name): current=\(.external.current.averageValue // .external.current.value // "n/a")"
  else
    "    \(.type)"
  end
),
""'

echo "=== Recent Scaling Events ==="
echo ""

kubectl get events "$NS_FLAG" \
  --field-selector reason=SuccessfulRescale \
  --sort-by=.metadata.creationTimestamp \
  | tail -20
