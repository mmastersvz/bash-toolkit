#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/pg-session.sh"

INPUT_FILE=$1
DB_NAME=$2

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: input file not found: $INPUT_FILE" >&2
    exit 1
fi
SECRET=$3
NAMESPACE=${4:-default}
TARGET=${5:-statefulset/pgbouncer}
LOCAL_PORT=${6:-15432}
DB_USER_KEY=${7:-postgresql-username}
DB_PASS_KEY=${8:-postgresql-password}

pg_k8s_session "$DB_NAME" "$SECRET" "$NAMESPACE" "$TARGET" "$LOCAL_PORT" "$DB_USER_KEY" "$DB_PASS_KEY"

echo "Restoring $INPUT_FILE into database: $DB_NAME..."

gunzip -c "$INPUT_FILE" | psql "$DB_NAME"

echo "Restore complete."
