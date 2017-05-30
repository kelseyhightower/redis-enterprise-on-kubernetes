# Redis Enterprise on Kubernetes

## Create a Kubernetes Cluster

```
gcloud beta container clusters create k0 \
  --cluster-version 1.6.4 \
  --num-nodes 3 \
  --machine-type n1-standard-2
```

```
gcloud beta container node-pools create redis-enterprise-pool \
  --cluster k0 \
  --local-ssd-count 1 \
  --machine-type n1-standard-2 \
  --num-nodes 3 \
  --node-labels dedicated=redis-enterprise
```

### Taint the Kubernetes Nodes

Ensure only the redis-enterprise instances run on the `redis-enterprise-pool` node pool.

```
DEDICATED_NODES=$(kubectl get nodes -l dedicated=redis-enterprise -o jsonpath={.items[*].metadata.name})
```

Taint the nodes to ensure only pods from the `redis-enterprise` statefulset are scheduled on them:

```
kubectl taint nodes ${DEDICATED_NODES} dedicated=redis-enterprise:NoSchedule
```

### Deploy Redis Enterprise

Create the `redis-enterprise` secret:

```
export REDIS_CLUSTER_PASSWORD="redislabs123"
```

```
kubectl create secret generic redis-enterprise \
  --from-literal "password=${REDIS_CLUSTER_PASSWORD}" \
  --from-literal "username=kelsey.hightower@gmail.com" \
  --from-file "license.key=${HOME}/license.key"
```

Create the `redis-enterprise` configmap:

```
kubectl create configmap redis-enterprise \
  --from-literal "name=cluster.local" \
  --from-file configs/ccs-redis.conf
```

Create the `redis-enterprise` services:

```
kubectl create -f services/redis-enterprise.yaml
```

```
kubectl create -f services/redis-enterprise-lb.yaml
```

Create the `redis-enterprise` statefulset:

```
kubectl create -f statefulsets/redis-enterprise.yaml
```
