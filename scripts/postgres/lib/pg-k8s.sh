#!/usr/bin/env bash
set -euo pipefail

pg_k8s_port_forward() {

    local namespace=$1
    local target=$2
    local local_port=${3:-15432}
    local remote_port=${4:-5432}

    echo "Starting port-forward: ${namespace} ${target} ${local_port}:${remote_port}"

    kubectl -n "$namespace" port-forward "$target" "${local_port}:${remote_port}" >/dev/null 2>&1 &
    PG_FORWARD_PID=$!

    echo "Waiting for port-forward..."

    for i in {1..10}; do
        if nc -z 127.0.0.1 "$local_port"; then
            echo "Port-forward ready"
            return 0
        fi
        sleep 1
    done

    echo "Port-forward failed"
    exit 1
}

pg_k8s_stop_forward() {
    if [[ -n "${PG_FORWARD_PID:-}" ]]; then
        kill "$PG_FORWARD_PID" || true
    fi
}

pg_k8s_get_secret() {

    local namespace=$1
    local secret=$2
    local key=$3

    kubectl -n "$namespace" get secret "$secret" \
        -o "jsonpath={.data.$key}" | base64 -d
}
