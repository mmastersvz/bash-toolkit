#!/usr/bin/env bash
# Launch a privileged debug pod on a node, mounting the host filesystem
# Uses `kubectl debug node/` — requires kubectl 1.23+ and cluster permissions

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <node>"
  echo ""
  echo "Opens a privileged shell on the node with the host filesystem mounted at /host."
  echo "Useful for: crictl, journalctl, inspecting /var/log, checking kubelet config, etc."
  exit 1
fi

NODE=$1
IMAGE="ubuntu"

echo "Launching privileged debug pod on node: $NODE"
echo "Host filesystem will be available at /host"
echo "(pod will be deleted automatically on exit)"
echo ""

kubectl debug "node/$NODE" \
  -it --image="$IMAGE" \
  -- bash
