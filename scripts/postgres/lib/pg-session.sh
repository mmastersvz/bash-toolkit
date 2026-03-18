#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/pg-k8s.sh"
source "$SCRIPT_DIR/pg-connect.sh"

pg_k8s_session() {

    if [[ -z "${1:-}" || -z "${2:-}" ]]; then
        echo "Usage: ${FUNCNAME[0]} <db_name> <secret> [namespace] [target] [local_port] [db_user_key] [db_pass_key]" >&2
        return 1
    fi

    local db_name=$1
    local secret=$2
    local namespace=${3:-default}
    local target=${4:-statefulset/pgbouncer}
    local local_port=${5:-15432}
    local db_user_key=${6:-postgresql-username}
    local db_pass_key=${7:-postgresql-password}

    echo "Starting Postgres session"
    echo "DB         : $db_name"
    echo "Namespace  : $namespace"
    echo "Target     : $target"
    echo "Local Port : $local_port"
    echo "DB User Key: $db_user_key"
    echo "DB Pass Key: $db_pass_key"
    echo

    local db_user=$(pg_k8s_get_secret "$namespace" "$secret" "$db_user_key")
    local db_pass=$(pg_k8s_get_secret "$namespace" "$secret" "$db_pass_key")

    pg_connect_env "$db_user" "$db_pass" "$db_name" "127.0.0.1" "$local_port"

    pg_k8s_port_forward "$namespace" "$target" "$local_port"

    trap pg_k8s_stop_forward EXIT
}
