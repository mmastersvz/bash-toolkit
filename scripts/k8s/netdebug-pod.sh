#!/usr/bin/env bash
# Launch a netshoot debug pod with network tools (curl, dig, nslookup, tcpdump, ss, nmap, etc.)
# Optionally target a specific node with --node

set -euo pipefail

NAMESPACE=${NAMESPACE:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}
NODE=""
IMAGE="nicolaka/netshoot"

usage() {
  echo "Usage: $0 [-n namespace] [--node <node-name>]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -n) NAMESPACE=$2; shift 2 ;;
    --node) NODE=$2; shift 2 ;;
    *) usage ;;
  esac
done

OVERRIDES=""
if [ -n "$NODE" ]; then
  OVERRIDES='{"spec":{"nodeName":"'"$NODE"'","tolerations":[{"operator":"Exists"}]}}'
  echo "Targeting node: $NODE"
fi

echo "Launching netdebug pod in namespace: $NAMESPACE"
echo "Image: $IMAGE  (curl, dig, tcpdump, ss, nmap, iperf3, ...)"
echo "(pod will be deleted automatically on exit)"
echo ""

if [ -n "$OVERRIDES" ]; then
  kubectl run netdebug \
    -it --rm \
    --restart=Never \
    --namespace "$NAMESPACE" \
    --image "$IMAGE" \
    --overrides "$OVERRIDES" \
    -- bash
else
  kubectl run netdebug \
    -it --rm \
    --restart=Never \
    --namespace "$NAMESPACE" \
    --image "$IMAGE" \
    -- bash
fi
