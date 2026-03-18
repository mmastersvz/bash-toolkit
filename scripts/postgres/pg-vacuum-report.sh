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
  relname,
  n_dead_tup,
  last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;
"
