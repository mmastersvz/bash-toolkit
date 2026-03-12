#!/usr/bin/env bash
# Identifies pods without resources

set -euo pipefail

kubectl get pods -A -o json \
| jq -r '
.items[] |
{
  ns: .metadata.namespace,
  pod: .metadata.name,
  containers: .spec.containers[]
} |
[
  .ns,
  .pod,
  .containers.name,
  (.containers.resources.requests.cpu // "none"),
  (.containers.resources.requests.memory // "none"),
  (.containers.resources.limits.cpu // "none"),
  (.containers.resources.limits.memory // "none")
] | @tsv'
