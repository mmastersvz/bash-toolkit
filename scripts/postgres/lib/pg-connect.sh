#!/usr/bin/env bash
set -euo pipefail

pg_connect_env() {

    export PGHOST=${PGHOST:-127.0.0.1}
    export PGPORT=${PGPORT:-15432}

    export PGUSER=$1
    export PGPASSWORD=$2
    export PGDATABASE=$3
}
