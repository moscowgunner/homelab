# Kubernetes Architecture

## What you will learn

After reading this page you should be able to explain:

- What a Kubernetes Cluster consists of.
- Which components belong to the Control Plane.
- Which components run on Worker Nodes.
- How a request flows through Kubernetes.
- How Kubernetes creates and manages Pods.

---

# High-Level Architecture

```mermaid
flowchart TB

    User[kubectl / API Client]

    subgraph Cluster["Kubernetes Cluster"]

        subgraph CP["Control Plane"]

            APIServer[kube-apiserver]

            Scheduler[kube-scheduler]

            Controller[kube-controller-manager]

            ETCD[(etcd)]

        end

        subgraph Worker["Worker Node"]

            Kubelet[kubelet]

            CRI[containerd]

            Pods[Pods]

        end

    end

    User --> APIServer

    APIServer --> ETCD

    APIServer --> Scheduler

    APIServer --> Controller

    Scheduler --> Kubelet

    Kubelet --> CRI

    CRI --> Pods
```


## Control Plane

- kube-apiserver
- etcd
- kube-scheduler
- kube-controller-manager

## Worker Node

- kubelet
- containerd

## Platform Services

K3s installs several platform services automatically.

Read more:

- [Kubernetes System Components](./kubernetes-system-components.md)