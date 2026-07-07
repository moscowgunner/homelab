# Cluster Configuration

This document explains the design decisions behind the `cluster-config.yaml` file used to create the local Kubernetes cluster.

The goal of this configuration is **not** to create the biggest cluster possible, but to build a small, reproducible environment that resembles a real production Kubernetes platform.

---

# Why k3d?

This homelab uses **k3d**, which runs **k3s** inside Docker containers.

Architecture:

MacOS
↓
OrbStack / Docker
↓
k3d
↓
k3s
↓
Kubernetes

### Why k3d?

- Extremely fast cluster creation
- Lightweight compared to Minikube
- Easy to destroy and recreate
- Uses standard Kubernetes APIs
- Perfect for local development and learning

---

# Cluster Name

```yaml
metadata:
  name: homelab
```

The cluster name is used in several places:

- k3d cluster name
- Kubernetes context
- Docker container names

For example:

```
k3d-homelab-server-0
k3d-homelab-agent-0
k3d-homelab-agent-1
```

Using a meaningful cluster name makes it easier to work with multiple Kubernetes environments.

---

# Control Plane and Worker Nodes

```yaml
servers: 1
agents: 2
```

## Why one server?

The server node hosts the Kubernetes control plane:

- kube-apiserver
- etcd
- kube-scheduler
- kube-controller-manager

A single control plane is enough for a local learning environment.

Running three control plane nodes would consume significantly more resources while providing little practical benefit for this stage of the project.

---

## Why two worker nodes?

Having two worker nodes allows experimenting with real Kubernetes scheduling features such as:

- Pod scheduling
- Node selectors
- Affinity and anti-affinity
- Cordon / Drain
- Rolling updates

This provides a much more realistic environment than running everything on a single node.

---

# Kubernetes Version

```yaml
image: rancher/k3s:v1.33.1-k3s1
```

The Kubernetes version is pinned intentionally.

Using a fixed version makes the environment reproducible and avoids unexpected behavior after upgrading k3d.

Using `latest` is generally discouraged because cluster behavior may change after new releases.

---

# Port Mapping

```yaml
ports:
  - port: "80:80"
  - port: "443:443"
```

Docker containers run in an isolated network.

Without port mapping, applications running inside Kubernetes would not be reachable from the host machine.

Port mapping creates the following path:

```
Browser
    │
localhost:80
    │
Docker Port Mapping
    │
k3d LoadBalancer
    │
Ingress Controller
    │
Kubernetes Service
    │
Pod
```

## Why port 80?

HTTP traffic.

Example:

```
http://localhost
```

---

## Why port 443?

HTTPS traffic.

Example:

```
https://localhost
```

These two ports are the standard entry points for web applications.

---

# Why LoadBalancer?

```yaml
nodeFilters:
  - loadbalancer
```

The load balancer is the entry point for external traffic.

Instead of exposing ports directly on the Kubernetes server node, k3d routes all incoming traffic through a dedicated load balancer container.

This closely resembles how cloud Kubernetes clusters work.

For example:

AWS

Internet

↓

Elastic Load Balancer

↓

Kubernetes Cluster

k3d follows the same idea locally:

Mac

↓

k3d LoadBalancer

↓

Kubernetes Cluster

---

# kubeconfig Options

```yaml
updateDefaultKubeconfig: true
switchCurrentContext: true
```

These options improve the local developer experience.

When the cluster is created:

- `~/.kube/config` is updated automatically
- kubectl immediately switches to the new cluster

Without these options, both actions would need to be performed manually.

---

# Waiting for the Cluster

```yaml
wait: true
timeout: 120s
```

Cluster creation is asynchronous.

Instead of returning immediately, k3d waits until Kubernetes becomes ready.

This makes automation scripts much more reliable.

---

# Why Disable Traefik?

```yaml
--disable=traefik
```

k3s installs Traefik automatically.

For this homelab the built-in installation is intentionally disabled.

Reasons:

- Learn Helm deployment
- Control every installed component
- Keep infrastructure fully declarative
- Better simulate production environments

Traefik will later be installed manually using Helm.

---

# Persistent Storage

```yaml
volumes:
  - volume: "${HOME}/.k3d-storage:/var/lib/rancher/k3s/storage"
```

Docker containers are ephemeral.

Deleting the cluster removes every container.

Without mounted storage:

```
Create PostgreSQL

↓

Insert data

↓

Delete cluster

↓

Everything is lost
```

With a mounted host directory:

```
Mac

~/.k3d-storage

↓

Docker Container

↓

Kubernetes Storage
```

The storage directory exists outside the container and survives cluster recreation.

This prepares the platform for future Stateful applications such as:

- PostgreSQL
- Kafka
- Redis

---

# Future Improvements

Later versions of this homelab will introduce:

- Traefik via Helm
- ArgoCD
- Prometheus
- Grafana
- PostgreSQL
- Apache Kafka
- AWS
- Terraform

The cluster configuration will evolve together with the platform.