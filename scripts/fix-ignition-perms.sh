#!/usr/bin/env bash
# Helper: fix ownership & permissions for the Ignition bind-mount inside the container.
# Usage: ./scripts/fix-ignition-perms.sh [container-name] [uid] [gid]
# Defaults: container=ignition-gateway, uid=2003, gid=2003
set -euo pipefail
CONTAINER=${1:-ignition-gateway}
TARGET=/usr/local/bin/ignition/data
UID=${2:-2003}
GID=${3:-2003}

if ! docker ps --format '{{.Names}}' | grep -q -w "$CONTAINER"; then
	echo "Container '$CONTAINER' is not running. Start it first (it may exit until perms are fixed)."
fi

echo "Fixing ownership to ${UID}:${GID} on ${TARGET} inside ${CONTAINER}..."
docker exec --user root "$CONTAINER" bash -lc "mkdir -p '${TARGET}' && chown -R ${UID}:${GID} '${TARGET}' && find '${TARGET}' -type d -exec chmod 0755 {} + && find '${TARGET}' -type f -exec chmod 0644 {} +"

echo "Permissions fixed. If the Ignition container exited earlier, restart it: docker compose up -d" 
