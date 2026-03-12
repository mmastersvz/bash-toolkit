#!/usr/bin/env bash

set -euo pipefail

echo "Cluster Info"
kubectl cluster-info

echo ""
echo "Node Status"
kubectl get nodes

echo ""
echo "Pods Not Running"
kubectl get pods --all-namespaces \
    | grep -v Running \
    | grep -v Completed || true

echo ""
echo "Top CPU Usage"
kubectl top nodes 2>/dev/null || echo "Metrics server not installed"

echo ""
echo "Recent Warning Events"
kubectl get events --all-namespaces \
    --sort-by=.metadata.creationTimestamp \
    | grep Warning \
    | tail -10
