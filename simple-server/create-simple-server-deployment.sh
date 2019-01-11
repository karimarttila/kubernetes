#!/usr/bin/env bash

if [ $# -ne 5 ]
then
  echo "Usage: ./create-simple-server-deployment.sh <ss-version> <azure/aws/minikube> <ip> <image version> <acr-registry-name>"
  echo "Example: ./create-simple-server-deployment.sh single-node azure 11.11.11.11 0.1 kari2ssaksdevacrdemo"
  echo "Remember to check your kubectl context first: kubectl config current-context"
  exit 1
fi

MY_SS_VERSION=$1
MY_CHOICE=$2
MY_IP=$3
MY_VERSION=$4
MY_ACR=$5

if [ "$MY_SS_VERSION" == "single-node" ]; then
  MY_SS_ENV_VALUE=single-node
  MY_KUBE_NAME=single-node
elif [ "$MY_SS_VERSION" == "azure-table-storage" ]; then
  MY_SS_ENV_VALUE=azure-table-storage
  MY_KUBE_NAME=table-storage
elif [ "$MY_SS_VERSION" == "aws-dynamodb" ]; then
  MY_SS_ENV_VALUE=aws-dynamodb
  MY_KUBE_NAME=dynamodb
else
  echo "Unknown choice: $MY_SS_VERSION"
  exit 2
fi

MINIKUBE_IMAGE_TAG="karimarttila\/simple-server-clojure-single-node:$MY_VERSION"
AZURE_IMAGE_TAG="${MY_ACR}.azurecr.io\/karimarttila\/simple-server-clojure-single-node:$MY_VERSION"
AWS_IMAGE_TAG="TODO"

if [ "$MY_CHOICE" == "minikube" ]; then
  MY_IMAGE_TAG=$MINIKUBE_IMAGE_TAG
elif [ "$MY_CHOICE" == "azure" ]; then
  MY_IMAGE_TAG=$AZURE_IMAGE_TAG
elif [ "$MY_CHOICE" == "aws" ]; then
  MY_IMAGE_TAG=$AWS_IMAGE_TAG
else
  echo "Unknown choice: $MY_CHOICE"
  exit 2
fi

echo "Using ss-version: $MY_SS_VERSION"
echo "Using tag: $MY_IMAGE_TAG"

ORIG_DEPLOYMENT_FILENAME="simple-server-deployment-template.yml"
FINAL_DEPLOYMENT_FILENAME="simple-server-deployment_${MY_CHOICE}_${MY_SS_VERSION}_final.yml"

cp $ORIG_DEPLOYMENT_FILENAME $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_IMAGE_TAG/$MY_IMAGE_TAG/" $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_IP/$MY_IP/" $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_ENV_VERSION/$MY_SS_ENV_VALUE/" $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VERSION/$MY_KUBE_NAME/" $FINAL_DEPLOYMENT_FILENAME

kubectl create -f "$FINAL_DEPLOYMENT_FILENAME"

sleep 1

rm $FINAL_DEPLOYMENT_FILENAME

