# Cluster Cleanup Script

This document explains how the `delete-cluster.sh` script works and why it is implemented this way.

The purpose of the script is to safely remove the local Kubernetes cluster.

The cluster can be deleted using a single command:

```bash
./bootstrap/delete-cluster.sh
```

---

# Script Overview

The script performs the following steps:

1. Enables safe Bash execution
2. Defines the cluster name
3. Checks whether the cluster exists
4. Deletes the cluster
5. Reports the result

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

improves portability across Unix-like systems.

---

# Safe Bash Mode

```bash
set -euo pipefail
```

The script enables strict Bash execution.

- `-e` — exit immediately if a command fails.
- `-u` — treat undefined variables as errors.
- `pipefail` — detect failures inside pipelines.

These options improve reliability and make unexpected behavior easier to detect.

---

# Cluster Name

```bash
CLUSTER_NAME="homelab"
```

The cluster name is stored in a variable to avoid duplication and simplify future changes.

---

# Informational Output

```bash
echo "Deleting cluster '${CLUSTER_NAME}'..."
```

A status message informs the user about the current operation.

---

# Checking Whether the Cluster Exists

```bash
if k3d cluster get "${CLUSTER_NAME}" >/dev/null 2>&1; then
```

The script asks k3d directly whether the cluster exists.

Unlike parsing `k3d cluster list`, this approach relies on the command's exit code, making the script more robust and independent of CLI output formatting.

The command output is discarded because only the return status is needed.

---

# Deleting the Cluster

```bash
k3d cluster delete "${CLUSTER_NAME}"
```

If the cluster exists, k3d removes all resources associated with it, including:

- Control Plane node(s)
- Worker node(s)
- Load Balancer container
- Docker network
- Kubernetes resources running inside the cluster

---

# Success Message

```bash
echo "Cluster deleted."
```

Displayed after the cluster has been successfully removed.

---

# Cluster Does Not Exist

```bash
echo "Cluster does not exist."
```

If the cluster is already absent, the script simply reports the current state.

This makes the script **idempotent**.

Running the script multiple times always produces the same desired state without causing failures.

Idempotency is a fundamental principle in DevOps and Infrastructure as Code.

---

# Future Improvements

Possible future enhancements include:

- confirmation prompt before deletion
- optional force mode
- cleanup logging
- support for multiple cluster names

The current implementation intentionally remains small, readable and predictable.