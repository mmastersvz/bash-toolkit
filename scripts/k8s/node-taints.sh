#!/usr/bin/env bash
# Show all node taints and which pods/deployments have matching tolerations

set -euo pipefail

echo "=== Node Taints ==="
echo ""

kubectl get nodes -o json | jq -r '
.items[] |
.metadata.name as $node |
if (.spec.taints | length) > 0 then
  .spec.taints[] |
  [$node, .key, (.value // ""), .effect] | @tsv
else
  [$node, "(none)", "", ""] | @tsv
end' \
| column -t -s $'\t' -N "NODE,KEY,VALUE,EFFECT"

echo ""
echo "=== Pods with Tolerations ==="
echo ""

kubectl get pods -A -o json | jq -r '
.items[] |
select((.spec.tolerations | length) > 0) |
.metadata as $meta |
.spec.tolerations[] |
select(.key != null and .key != "node.kubernetes.io/not-ready" and .key != "node.kubernetes.io/unreachable") |
[$meta.namespace, $meta.name, .key, (.value // "*"), (.effect // "*")] | @tsv' \
| sort -u \
| column -t -s $'\t' -N "NAMESPACE,POD,TOLERATION_KEY,VALUE,EFFECT"
