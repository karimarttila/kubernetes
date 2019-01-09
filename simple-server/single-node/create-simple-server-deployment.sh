#!/usr/bin/env bash

if [ $# -ne 4 ]
then
  echo "Usage: ./create-simple-server-deployment.sh <azure/aws/minikube> <ip> <image version> <acr-registry-name>"
  echo "Remember to check your kubectl context first: kubectl config current-context"
  exit 1
fi

MY_CHOICE=$1
MY_IP=$2
MY_VERSION=$3
MY_ACR=$4

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

echo "Using tag: $MY_IMAGE_TAG"

ORIG_DEPLOYMENT_FILENAME="simple-server-deployment-template.yml"
TMP_DEPLOYMENT_FILENAME_1="simple-server-deployment_${MY_CHOICE}_1.yml"
FINAL_DEPLOYMENT_FILENAME="simple-server-deployment_${MY_CHOICE}_final.yml"

sed "s/REPLACE_IMAGE_TAG/$MY_IMAGE_TAG/" $ORIG_DEPLOYMENT_FILENAME > $TMP_DEPLOYMENT_FILENAME_1
sed "s/REPLACE_IP/$MY_IP/" $TMP_DEPLOYMENT_FILENAME_1 > $FINAL_DEPLOYMENT_FILENAME

kubectl create -f "$FINAL_DEPLOYMENT_FILENAME"

sleep 1

rm $TMP_DEPLOYMENT_FILENAME_1
rm $FINAL_DEPLOYMENT_FILENAME

