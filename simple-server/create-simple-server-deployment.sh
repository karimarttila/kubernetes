#!/usr/bin/env bash

if [ $# -ne 9 ]
then
  echo "Usage: ./create-simple-server-deployment.sh <ss-version> <azure/aws/minikube> <ip> <nodeport> <image version> <acr-registry-name> <aws-account-id> <aws-region> <aws-ecr-repo>"
  echo "Example: ./create-simple-server-deployment.sh single-node azure 11.11.11.11 31112 0.1 kari2ssaksdevacrdemo dummy-aws-id dummy-aws-region dummy-aws-ecr-repo"
  echo "Remember to check your kubectl context first: kubectl config current-context"
  exit 1
fi

MY_SS_VERSION=$1
MY_CHOICE=$2
MY_IP=$3
MY_NODEPORT=$4
MY_VERSION=$5
MY_AZURE_ACR=$6
MY_AWS_ACCOUNT=$7
MY_AWS_REGION=$8
MY_AWS_ECR_REPO=$9

MY_SS_ENDPOINT="DUMMY-NOT-USED-OUTSIDE-AZURE"
MY_SS_IP_LINE="#DUMMY-NOT-USED-OUTSIDE-AZURE"

if [ "$MY_SS_VERSION" == "single-node" ]; then
  MY_IMAGE_VERSION="simple-server-clojure-single-node:$MY_VERSION"
  MY_SS_ENV_VALUE=single-node
  MY_KUBE_NAME=single-node
elif [ "$MY_SS_VERSION" == "azure-table-storage" ]; then
  MY_IMAGE_VERSION="simple-server-clojure-table-storage:$MY_VERSION"
  MY_SS_ENV_VALUE=azure-table-storage
  MY_KUBE_NAME=table-storage
  if [[ -z "${AZURE_CONNECTION_STRING}" ]]; then
    echo "Environmental variable AZURE_CONNECTION_STRING is not set"
    echo "Source it first using command:"
    echo "source ~/.azure/kari2ssaksdevtables-connectionstring.sh"
    exit -1
  fi
  MY_SS_ENDPOINT=$AZURE_CONNECTION_STRING
elif [ "$MY_SS_VERSION" == "aws-dynamodb" ]; then
  MY_IMAGE_VERSION="simple-server-clojure-aws-dynamodb:$MY_VERSION"
  MY_SS_ENV_VALUE=aws-dynamodb
  MY_KUBE_NAME=dynamodb
else
  echo "Unknown choice: $MY_SS_VERSION"
  exit 2
fi

MINIKUBE_IMAGE_TAG="karimarttila\/$MY_IMAGE_VERSION"
AZURE_IMAGE_TAG="${MY_AZURE_ACR}.azurecr.io\/karimarttila\/$MY_IMAGE_VERSION"
AWS_IMAGE_TAG="${MY_AWS_ACCOUNT}.dkr.ecr.${MY_AWS_REGION}.amazonaws.com\/${MY_AWS_ECR_REPO}\/karimarttila\/$MY_IMAGE_VERSION"


if [ "$MY_CHOICE" == "minikube" ]; then
  MY_IMAGE_TAG=$MINIKUBE_IMAGE_TAG
elif [ "$MY_CHOICE" == "azure" ]; then
  MY_IMAGE_TAG=$AZURE_IMAGE_TAG
  MY_SS_IP_LINE="loadBalancerIP: $MY_IP"
elif [ "$MY_CHOICE" == "aws" ]; then
  MY_IMAGE_TAG=$AWS_IMAGE_TAG
else
  echo "Unknown choice: $MY_CHOICE"
  exit 2
fi



# NOTE: You can comment this line if you want to test pod/svc deployment
# and preserve namespace.
./create-simple-server-namespace.sh $MY_SS_VERSION

echo "Using ss-version: $MY_SS_VERSION"
echo "Using tag: $MY_IMAGE_TAG"

ORIG_DEPLOYMENT_FILENAME="simple-server-deployment-template.yml"
FINAL_DEPLOYMENT_FILENAME="simple-server-deployment_${MY_CHOICE}_${MY_SS_VERSION}_final.yml"

cp $ORIG_DEPLOYMENT_FILENAME $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_IMAGE_TAG/$MY_IMAGE_TAG/" $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_IP/$MY_SS_IP_LINE/" $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_ENV_VERSION/$MY_SS_ENV_VALUE/" $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_VERSION/$MY_KUBE_NAME/" $FINAL_DEPLOYMENT_FILENAME
sed -i "s/REPLACE_SS_NODEPORT/$MY_NODEPORT/" $FINAL_DEPLOYMENT_FILENAME
# NOTE: Use different separator character since password uses also '/' character. You may have to escape other metacharacters also.
sed -i "s|REPLACE_SS_ENDPOINT|$MY_SS_ENDPOINT|" $FINAL_DEPLOYMENT_FILENAME

# Just comment these lines out when debugging the script.
kubectl create -f "$FINAL_DEPLOYMENT_FILENAME"
rm $FINAL_DEPLOYMENT_FILENAME

