#!/usr/bin/env bash

if [ $# -ne 1 ]
then
  echo "Usage: ./create-simple-server-namespace.sh <ss-version>"
  echo "Example: ./create-simple-server-namespace.sh single-node"
  echo "Remember to check your kubectl context first: kubectl config current-context"
  exit 1
fi

MY_SS_VERSION=$1

if [ "$MY_SS_VERSION" == "single-node" ]; then
  MY_KUBE_NAME=single-node
elif [ "$MY_SS_VERSION" == "azure-table-storage" ]; then
  MY_KUBE_NAME=table-storage
elif [ "$MY_SS_VERSION" == "aws-dynamodb" ]; then
  MY_KUBE_NAME=dynamodb
else
  echo "Unknown choice: $MY_SS_VERSION"
  exit 2
fi

echo "Using ss-version: $MY_SS_VERSION"

ORIG_DEPLOYMENT_FILENAME="simple-server-namespace-template.yml"
FINAL_DEPLOYMENT_FILENAME="simple-server-namespace_${MY_SS_VERSION}_final.yml"

cp $ORIG_DEPLOYMENT_FILENAME $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VERSION/$MY_KUBE_NAME/" $FINAL_DEPLOYMENT_FILENAME

kubectl create -f "$FINAL_DEPLOYMENT_FILENAME"

sleep 1

rm $FINAL_DEPLOYMENT_FILENAME
