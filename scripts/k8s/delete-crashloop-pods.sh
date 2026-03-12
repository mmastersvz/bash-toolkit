#!/usr/bin/env bash

set -euo pipefail

kubectl get pods -A \
  | grep CrashLoopBackOff \
  | awk '{print $1,$2}' \
  | while read -r ns pod; do
        echo "Deleting $pod in $ns"
        kubectl delete pod "$pod" -n "$ns"
    done
