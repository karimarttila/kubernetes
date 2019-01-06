#!/bin/bash

if [ $# -ne 2 ]
then
  echo "Usage: ./while-true-get-all.sh <namespace> <wait-secs>"
  echo "Example: ./while-true-get-all.sh km-ss-single-node-ns 5"
  exit 1
fi

MY_NS=$1
MY_SECS=$2

echo "Starting with wait time: $MY_SECS"
while true; do echo "*********************";kubectl get all --namespace $MY_NS; sleep "$MY_SECS"; done
