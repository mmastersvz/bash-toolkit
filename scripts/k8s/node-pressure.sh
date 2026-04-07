#!/usr/bin/env bash
# Show nodes with MemoryPressure, DiskPressure, or PIDPressure set to True

set -euo pipefail

echo "Checking node pressure conditions..."
echo ""

kubectl get nodes -o json | jq -r '
.items[] |
.metadata.name as $node |
.status.conditions[] |
select(.type | test("Pressure")) |
select(.status == "True") |
[$node, .type, .status, .message] | @tsv' \
| column -t -s $'\t' -N "NODE,CONDITION,STATUS,MESSAGE"

# Also print a summary of all nodes with all condition statuses
echo ""
echo "All node conditions:"
echo ""
kubectl get nodes -o json | jq -r '
["NODE", "READY", "MEM_PRESSURE", "DISK_PRESSURE", "PID_PRESSURE", "UNSCHEDULABLE"],
(.items[] |
  .metadata.name as $node |
  (.status.conditions | map({(.type): .status}) | add) as $conds |
  [
    $node,
    ($conds.Ready // "Unknown"),
    ($conds.MemoryPressure // "Unknown"),
    ($conds.DiskPressure // "Unknown"),
    ($conds.PIDPressure // "Unknown"),
    (if .spec.unschedulable then "True" else "False" end)
  ]
) | @tsv' \
| column -t -s $'\t'
