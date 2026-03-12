#!/usr/bin/env bash
# Search for environment variables in Kubernetes pods

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <env-variable>"
    exit 1
fi

VAR=$1

kubectl get pods -A -o json \
| jq -r --arg VAR "$VAR" '
.items[] |
{
  ns: .metadata.namespace,
  pod: .metadata.name,
  containers: .spec.containers[]
} |
select(.containers.env[]?.name == $VAR) |
"\(.ns) \(.pod) \(.containers.name)"
'
