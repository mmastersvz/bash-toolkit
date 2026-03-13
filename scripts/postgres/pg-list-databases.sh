#!/usr/bin/env bash
set -euo pipefail

HOST=${PGHOST:-localhost}
PORT=${PGPORT:-15432}
USER=${PGUSER:-postgres}
DB=${PGDATABASE:-postgres}

psql \
  -h "$HOST" \
  -p "$PORT" \
  -U "$USER" \
  -d "$DB" \
  -At \
  -c "
SELECT datname
FROM pg_database
WHERE datistemplate = false
ORDER BY datname;
"
