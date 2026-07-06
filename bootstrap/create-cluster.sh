#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLUSTER_NAME="homelab"
CONFIG_FILE="${SCRIPT_DIR}/cluster-config.yaml"

mkdir -p "${HOME}/.k3d-storage"

echo "Creating cluster '${CLUSTER_NAME}'..."

if k3d cluster get "${CLUSTER_NAME}" >/dev/null 2>&1; then
    echo "Cluster already exists."
    exit 0
fi

k3d cluster create --config "${CONFIG_FILE}"

echo
echo "Waiting for nodes..."

kubectl wait \
    --for=condition=Ready nodes \
    --all \
    --timeout=120s

echo
kubectl get nodes

echo
echo "Cluster is ready."