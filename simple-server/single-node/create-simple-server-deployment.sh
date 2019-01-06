#!/usr/bin/env bash

if [ $# -ne 0 ]
then
  echo "Usage: ./create-simple-server-deployment.sh"
  echo "Remember to check your kubectl context first: kubectl config current-context"
  exit 1
fi

kubectl create -f simple-server-deployment.yml