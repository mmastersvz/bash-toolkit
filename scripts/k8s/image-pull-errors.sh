#!/usr/bin/env bash
# Find pods stuck in ErrImagePull or ImagePullBackOff and show the image and reason

set -euo pipefail

kubectl get pods -A -o json \
| jq -r '
.items[] |
.metadata as $meta |
.status.containerStatuses[]? |
select(
  .state.waiting.reason == "ErrImagePull" or
  .state.waiting.reason == "ImagePullBackOff"
) |
[
  $meta.namespace,
  $meta.name,
  .name,
  .image,
  .state.waiting.reason
] | @tsv' \
| column -t -s $'\t' -N "NAMESPACE,POD,CONTAINER,IMAGE,REASON"
