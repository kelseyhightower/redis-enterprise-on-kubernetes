# Redis Enterprise on Kubernetes

This tutorial will walk you through provisioning 3 node [Redis Enterprise](https://redislabs.com/redis-enterprise-documentation/overview) cluster with support for the [Redis Flash](https://redislabs.com/redis-enterprise-documentation/concepts-architecture/concepts/redis-e-flash) feature, which allows you to create databases that span both RAM and flash memory (SSD) for larger datasets.

## Prerequisites

This tutorial requires a working Kubernetes cluster with a dedicated set of nodes for Redis Enterprise. In this section you will create a six node cluster using [Google's Container Engine](https://cloud.google.com/container-engine).

Create the initial cluster:

```
gcloud beta container clusters create k0 \
  --cluster-version 1.6.4 \
  --num-nodes 3 \
  --machine-type n1-standard-2
```

Add a dedicated set of worker nodes for the Redis Enterprise cluster: 

```
gcloud beta container node-pools create redis-enterprise-pool \
  --cluster k0 \
  --local-ssd-count 1 \
  --machine-type n1-standard-2 \
  --num-nodes 3 \
  --node-labels dedicated=redis-enterprise
```

Each dedicated worker has an attached [local SSD](https://cloud.google.com/compute/docs/disks/local-ssd) and will include the [node label](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#step-one-attach-label-to-the-node) `dedicated=redis-enterprise`. 

## Taint the Kubernetes Nodes

Ensure only the redis-enterprise instances run on the `redis-enterprise-pool` node pool.

```
DEDICATED_NODES=$(kubectl get nodes -l dedicated=redis-enterprise -o jsonpath={.items[*].metadata.name})
```

[Taint](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#taints-and-tolerations-beta-feature) the nodes to ensure only pods from the `redis-enterprise` statefulset are scheduled on them:

```
kubectl taint nodes ${DEDICATED_NODES} dedicated=redis-enterprise:NoSchedule
```

## Deploy Redis Enterprise

In this section you will deploy the `redislabs/redis:4.5.0-22` container image using a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset). 

Create a secret to hold the Redis Enterprise license key and authentication credentials:

```
export REDIS_CLUSTER_PASSWORD="redislabs123"
```

```
kubectl create secret generic redis-enterprise \
  --from-literal "password=${REDIS_CLUSTER_PASSWORD}" \
  --from-literal "username=kelsey.hightower@gmail.com" \
  --from-file "license.key=${HOME}/license.key"
```

Create a configmap to hold the Redis Enterprise configuration file and cluster name:

```
kubectl create configmap redis-enterprise \
  --from-literal "name=cluster.local" \
  --from-file configs/ccs-redis.conf
```

Create the `redis-enterprise` headless service to expose each StatefulSet member internally:

```
kubectl create -f services/redis-enterprise.yaml
```

Create the `redis-enterprise-lb` service to provide an inter-cluster LB for the Redis discovery service and client connectivity:

```
kubectl create -f services/redis-enterprise-lb.yaml
```

Create the `redis-enterprise` statefulset:

```
kubectl create -f statefulsets/redis-enterprise.yaml
```
