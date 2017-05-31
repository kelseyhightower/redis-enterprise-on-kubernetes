#!/bin/bash

kubectl delete statefulset redis-enterprise
# kubectl delete configmap redis-enterprise
# kubectl delete secret redis-enterprise
kubectl delete svc redis-enterprise
kubectl delete jobs load-test

DEDICATED_NODES=$(kubectl get nodes -l dedicated=redis-enterprise -o jsonpath={.items[*].metadata.name})
kubectl taint nodes ${DEDICATED_NODES} dedicated-
