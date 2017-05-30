# Redis Enterprise on Kubernetes

## Create a Kubernetes Cluster

```
gcloud beta container clusters create redis-enterprise \
  --cluster-version 1.6.4 \
  --num-nodes 3 \
  --machine-type n1-standard-2
```

```
gcloud beta container node-pools create redis-enterprise-flash \
  --cluster redis-enterprise \
  --local-ssd-count 1 \
  --machine-type n1-standard-2 \
  --num-nodes 3 \
  --node-labels ssd=true,dedicated=redis-enterprise-flash
```

Ensure only the redis-enterprise instances run on the `redis-enterprise-flash` node pool.

```
DEDICATED_NODES=$(kubectl get nodes -l dedicated=redis-enterprise-flash -o jsonpath={.items[*].metadata.name})
```

Taint the nodes to ensure only pods from the `redis-enterprise` statefulset are scheduled on them:

```
kubectl taint nodes ${DEDICATED_NODES} dedicated=redis-enterprise-flash:NoSchedule
```

```
export REDIS_CLUSTER_PASSWORD="redislabs123"
```

```
kubectl create secret generic redis-enterprise \
  --from-literal "password=${REDIS_CLUSTER_PASSWORD}" \
  --from-literal "username=kelsey.hightower@gmail.com" \
  --from-file "license.key=${HOME}/license.key"
```

```
kubectl create configmap redis-enterprise \
  --from-literal "name=cluster.local" \
  --from-file configs/ccs-redis.conf
```

```
kubectl create -f services/redis-enterprise.yaml
```

```
kubectl create -f services/redis-enterprise-lb.yaml
```

```
kubectl create -f statefulsets/redis-enterprise.yaml
```
