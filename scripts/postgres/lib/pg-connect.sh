#!/usr/bin/env bash
set -euo pipefail

pg_connect_env() {

    local user=$1
    local password=$2
    local database=$3
    local host=${4:-127.0.0.1}
    local port=${5:-15432}

    export PGHOST="$host"
    export PGPORT="$port"
    export PGUSER="$user"
    export PGPASSWORD="$password"
    export PGDATABASE="$database"
}
