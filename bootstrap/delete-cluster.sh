#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="homelab"

echo "Deleting cluster '${CLUSTER_NAME}'..."

if k3d cluster get "${CLUSTER_NAME}" >/dev/null 2>&1; then
    k3d cluster delete "${CLUSTER_NAME}"
    echo "Cluster deleted."
else
    echo "Cluster does not exist."
fi