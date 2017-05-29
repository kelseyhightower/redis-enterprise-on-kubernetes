# Redis Enterprise on Kubernetes

```
gcloud container clusters create redislabs \
  --cluster-version 1.6.4 \
  --num-nodes 3 \
  --machine-type n1-standard-2
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
