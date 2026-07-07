# Cluster Bootstrap Script

This document explains how the `create-cluster.sh` script works and why it is implemented this way.

The purpose of the script is to create a local Kubernetes cluster in a predictable, reproducible and safe manner.

The cluster can be created using a single command:

```bash
./bootstrap/create-cluster.sh
```

---

# Script Overview

The script performs the following steps:

1. Enables safe Bash execution
2. Determines its own location
3. Defines cluster configuration
4. Creates the local storage directory
5. Checks whether the cluster already exists
6. Creates the cluster
7. Waits until Kubernetes becomes ready
8. Displays the cluster status

---

# Shebang

```bash
#!/usr/bin/env bash
```

This line tells the operating system to execute the script using the Bash interpreter.

Using

```bash
/usr/bin/env bash
```

instead of

```bash
/bin/bash
```

improves portability because Bash is located automatically using the user's environment.

---

# Safe Bash Mode

```bash
set -euo pipefail
```

This enables safer script execution.

## -e

Exit immediately if any command fails.

## -u

Treat undefined variables as errors.

## pipefail

Detect failures inside pipelines instead of checking only the last command.

These options help prevent silent failures and make automation more reliable.

---

# Determining the Script Directory

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

The script determines its own location so it can reliably locate project files regardless of the current working directory.

For example:

```
Developer/
└── homelab/
    └── bootstrap/
        ├── create-cluster.sh
        └── cluster-config.yaml
```

Even if the script is started from another directory, `SCRIPT_DIR` will always point to the `bootstrap` directory.

---

# Cluster Configuration

```bash
CLUSTER_NAME="homelab"
CONFIG_FILE="${SCRIPT_DIR}/cluster-config.yaml"
```

Important values are stored in variables instead of being repeated throughout the script.

Benefits:

- easier maintenance
- cleaner code
- easier future modifications

---

# Preparing Local Storage

```bash
mkdir -p "${HOME}/.k3d-storage"
```

The script creates the local storage directory if it does not already exist.

This directory is mounted into the Kubernetes control plane and will later be used for persistent storage by Stateful workloads.

Using `mkdir -p` makes the operation idempotent.

If the directory already exists, nothing happens.

---

# Checking Whether the Cluster Already Exists

```bash
if k3d cluster get "${CLUSTER_NAME}" >/dev/null 2>&1; then
```

Instead of parsing the output of `k3d cluster list`, the script directly asks k3d whether the cluster exists.

This approach is more reliable because it uses the command's exit status rather than relying on text formatting.

Output is redirected to:

```bash
>/dev/null 2>&1
```

because only the success or failure of the command matters.

If the cluster already exists:

```bash
echo "Cluster already exists."
exit 0
```

The script exits successfully without performing unnecessary work.

---

# Creating the Cluster

```bash
k3d cluster create --config "${CONFIG_FILE}"
```

The cluster is created using the YAML configuration file.

Keeping the configuration in a separate file makes the infrastructure easier to maintain, review and version in Git.

---

# Waiting Until Kubernetes Is Ready

```bash
kubectl wait \
    --for=condition=Ready nodes \
    --all \
    --timeout=120s
```

Cluster creation is asynchronous.

Instead of waiting for a fixed amount of time, the script waits until every node reports the `Ready` condition.

This approach is faster and significantly more reliable than using a fixed `sleep` delay.

---

# Displaying Cluster Status

```bash
kubectl get nodes
```

The script displays the cluster nodes after Kubernetes becomes ready.

This provides immediate confirmation that the cluster was created successfully.

---

# Completion Message

```bash
echo "Cluster is ready."
```

The final message indicates that the bootstrap process completed successfully.

The Kubernetes cluster is now ready for deploying additional platform components.

---

# Future Improvements

Possible future enhancements include:

- prerequisite checks (`docker`, `kubectl`, `k3d`, `helm`)
- colored output
- logging
- configurable cluster name
- configurable Kubernetes version
- automatic namespace creation
- automatic Helm bootstrap

The current implementation intentionally remains simple while following good scripting practices.