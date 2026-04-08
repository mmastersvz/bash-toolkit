#!/usr/bin/env bash
# Show PVC status, bound PV details, storage class, and related events

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <pvc> [namespace]"
  exit 1
fi

PVC=$1
NAMESPACE=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")}
NAMESPACE=${NAMESPACE:-default}

echo "=== PVC: $PVC (ns: $NAMESPACE) ==="
echo ""
kubectl get pvc "$PVC" -n "$NAMESPACE" -o wide

echo ""
echo "=== PVC Detail ==="
kubectl get pvc "$PVC" -n "$NAMESPACE" -o json | jq '{
  phase:        .status.phase,
  capacity:     .status.capacity,
  accessModes:  .status.accessModes,
  storageClass: .spec.storageClassName,
  volumeMode:   .spec.volumeMode,
  boundVolume:  .spec.volumeName
}'

PV=$(kubectl get pvc "$PVC" -n "$NAMESPACE" -o jsonpath='{.spec.volumeName}' 2>/dev/null || true)

if [ -n "$PV" ]; then
  echo ""
  echo "=== Bound PV: $PV ==="
  kubectl get pv "$PV" -o json | jq '{
    phase:            .status.phase,
    capacity:         .spec.capacity,
    accessModes:      .spec.accessModes,
    reclaimPolicy:    .spec.persistentVolumeReclaimPolicy,
    storageClass:     .spec.storageClassName,
    volumeHandle:     (.spec.csi.volumeHandle // "n/a"),
    nodeAffinity:     (.spec.nodeAffinity // "none")
  }'
else
  echo ""
  echo "PVC is not bound to a PV."
fi

echo ""
echo "=== Events ==="
kubectl get events -n "$NAMESPACE" \
  --field-selector "involvedObject.name=$PVC" \
  --sort-by=.metadata.creationTimestamp
