#!/usr/bin/env bash

set -euo pipefail

echo "Cleaning unused Docker resources..."

echo "containers..."
docker container prune -f

echo "images..."
docker image prune -f

echo "volumes..."
docker volume prune -f

echo "networks..."
docker network prune -f

echo "Docker cleanup completed."
