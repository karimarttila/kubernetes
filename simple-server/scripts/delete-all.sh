#!/usr/bin/env bash

if [ $# -ne 1 ]
then
  echo "Usage: ./delete-all.sh <prefix>"
  echo "Example: ./delete-all.sh kari-ss-single-node"
  echo "Remember to check your kubectl context first: kubectl config current-context"
  exit 1
fi

MY_PREFIX=$1

echo "Deleting pods, deployments and services in ${MY_PREFIX}-ns namespace..."
kubectl delete pods,deployments,services -l component=${MY_PREFIX}-component --namespace=${MY_PREFIX}-ns
echo "Deleting ${MY_PREFIX}-ns namespace..."
kubectl delete namespaces ${MY_PREFIX}-ns
echo "If you still see some resources, delete them manually."
echo "If remaining resources are in status terminating, then just wait"
echo "Listing resources:"
kubectl get all --all-namespaces | grep "${MY_PREFIX}-ns"
