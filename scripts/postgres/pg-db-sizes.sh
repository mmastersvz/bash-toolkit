#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/pg-session.sh"

DB_NAME=$1
SECRET=$2
NAMESPACE=${3:-default}
TARGET=${4:-statefulset/pgbouncer}
LOCAL_PORT=${5:-15432}
DB_USER_KEY=${6:-postgresql-username}
DB_PASS_KEY=${7:-postgresql-password}

pg_k8s_session "$DB_NAME" "$SECRET" "$NAMESPACE" "$TARGET" "$LOCAL_PORT" "$DB_USER_KEY" "$DB_PASS_KEY"

psql -c "
SELECT
  datname AS database,
  pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY pg_database_size(datname) DESC;
"
