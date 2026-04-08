#!/usr/bin/env bash
# List pods that have been OOMKilled, with memory limits and restart counts

set -euo pipefail

kubectl get pods -A -o json \
| jq -r '
.items[] |
.metadata as $meta |
.spec.containers[] as $c |
.status.containerStatuses[]? |
select(.name == $c.name) |
select(
  .lastState.terminated.reason == "OOMKilled" or
  .state.terminated.reason == "OOMKilled"
) |
[
  $meta.namespace,
  $meta.name,
  .name,
  (.restartCount | tostring),
  ($c.resources.limits.memory // "none")
] | @tsv' \
| column -t -s $'\t' -N "NAMESPACE,POD,CONTAINER,RESTARTS,MEM_LIMIT"
