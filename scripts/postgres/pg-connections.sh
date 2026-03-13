#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/pg-k8s.sh"
source "$SCRIPT_DIR/lib/pg-connect.sh"

DB_NAME=$1
SECRET=$2
NAMESPACE=${3:-default}
TARGET=${4:-statefulset/pgbouncer}
DB_USER_KEY=${5:-postgresql-username}
DB_PASS_KEY=${6:-postgresql-password}

DB_USER=$(pg_k8s_get_secret "$NAMESPACE" "$SECRET" "$DB_USER_KEY")
DB_PASS=$(pg_k8s_get_secret "$NAMESPACE" "$SECRET" "$DB_PASS_KEY")

pg_connect_env "$DB_USER" "$DB_PASS" "$DB_NAME"

pg_k8s_port_forward "$NAMESPACE" "$TARGET"

trap pg_k8s_stop_forward EXIT

psql -c "
SELECT
  datname,
  usename,
  client_addr,
  state,
  count(*)
FROM pg_stat_activity
GROUP BY datname, usename, client_addr, state
ORDER BY count DESC;
"
