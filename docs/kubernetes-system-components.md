# Kubernetes System Components

Before deploying applications, it is important to understand the components that are already running inside a Kubernetes cluster.

These components provide networking, storage and resource monitoring. Without them, many Kubernetes features would not work correctly.

You can view all system Pods using:

```bash
kubectl get pods -n kube-system
```

---

# CoreDNS

## Purpose

CoreDNS provides DNS resolution inside the Kubernetes cluster.

Instead of communicating with other applications using IP addresses, Pods communicate using DNS names.

Example:

```
frontend
    │
    ▼
backend.default.svc.cluster.local
```

CoreDNS resolves the service name into the current ClusterIP address.

Without CoreDNS:

- applications would need to know Pod IP addresses;
- Pod recreation would break communication because IP addresses change.

With CoreDNS:

Applications communicate using stable service names instead of changing IP addresses.

## Example

```bash
kubectl get svc
```

```
NAME       TYPE        CLUSTER-IP
backend    ClusterIP   10.43.18.25
```

Applications connect to:

```
backend.default.svc.cluster.local
```

instead of

```
10.43.18.25
```

```mermaid
flowchart LR

A[Frontend Pod] --> B["backend.default.svc.cluster.local"]

B --> C[CoreDNS]

C --> D[Service ClusterIP]

D --> E[Backend Pod]
```

---

# Metrics Server

## Purpose

Metrics Server collects CPU and memory usage from Kubernetes Nodes and Pods.

It does **not** collect logs.

It provides resource metrics used by Kubernetes and administrators.

Example:

```bash
kubectl top nodes
```

```bash
kubectl top pods
```

Metrics Server is also required by:

- Horizontal Pod Autoscaler (HPA)
- Vertical Pod Autoscaler (when used)
- Kubernetes Dashboard resource graphs

Without Metrics Server:

- `kubectl top` does not work;
- HPA cannot automatically scale applications based on CPU or memory usage.

---

# Local Path Provisioner

## Purpose

Local Path Provisioner automatically creates Persistent Volumes for applications requesting storage.

It is the default Storage Provisioner included with K3s.

Instead of manually creating a PersistentVolume, Kubernetes automatically provisions one when a PersistentVolumeClaim is created.

Typical workflow:

```
Application

        │

PersistentVolumeClaim

        │

StorageClass (local-path)

        │

Local Path Provisioner

        │

PersistentVolume
```

This allows developers to request storage without worrying about where it is physically created.

Example StorageClass:

```bash
kubectl get storageclass
```

```
NAME                   PROVISIONER
local-path (default)   rancher.io/local-path
```

---

# Summary

| Component | Responsibility |
|-----------|----------------|
| CoreDNS | Service discovery and internal DNS resolution |
| Metrics Server | CPU and memory metrics for Nodes and Pods |
| Local Path Provisioner | Automatic creation of Persistent Volumes |

---

# Key Takeaways

- CoreDNS allows applications to communicate using DNS names instead of IP addresses.
- Metrics Server provides resource usage metrics but does not collect logs.
- Local Path Provisioner automatically creates Persistent Volumes for applications that request storage.
- These components are installed automatically in a K3s cluster and form part of the Kubernetes platform itself.