# Simple Server Kubernetes Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [Minikube](#minikube)
- [Kubernetes Deployment Configurations](#kubernetes-deployment-configurations)
  - [Some Observations Regarding the Kubernetes Configuration](#some-observations-regarding-the-kubernetes-configuration)
  - [Single Node](#single-node)
    - [Minikube Deployment](#minikube-deployment)
    - [Azure AKS Deployment](#azure-aks-deployment)
      - [Tag and Push Docker Images](#tag-and-push-docker-images)
      - [Get Kubectl Context for Azure AKS](#get-kubectl-context-for-azure-aks)
      - [Deploy Kubernetes Configuration to Azure AKS](#deploy-kubernetes-configuration-to-azure-aks)
  - [Azure Table Storage Service](#azure-table-storage-service)
- [Kubernetes Documentation Resources](#kubernetes-documentation-resources)

# Introduction

This Simple Server Kubernetes project comprises various Kubernetes configurations for studying Kubernetes. 

The Simple Server Single-node K8 configuration is just for testing Simple Server with local Kubernetes Minikube deployment.

The Simple Server Azure Table Storage version provides Kubernetes deployment for Azure AKS.

The Simple Server AWS DynamoDB version provides Kubernetes deployments for AWS EKS and Fargate.

The Simple Server language version in all these K8 versions is the Clojure version, see: [Simple Server Clojure](https://github.com/karimarttila/clojure/tree/master/clj-ring-cljs-reagent-demo/simple-server).

# Dependency to My Docker Repository

This Kubernetes project uses Simple Server Docker images - the build instructions and scripts are in my [Docker Repository](https://github.com/karimarttila/docker/tree/master/demo-images/simple-server/clojure).


# Minikube

Minikube provides a local single node Kubernetes cluster that you can use for testing Kubernetes deployments.

Install **minikube** using instructions in [Minikube installation instructions](https://github.com/kubernetes/minikube).

You also need to install the **kubectl** command line tool: [kubectl installation instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

The first time you give the ```minikube start``` command minikube starts downloading the Minikube ISO image and kube tools, this takes a while, be patient. When you see: "Starting cluster components..." this also takes a while, be patient. When you finally see: "Kubectl is now configured to use the cluster. Loading cached images from config file." you are done. 

Test:

```bash
kubectl cluster-info               # => "Kubernetes master is running at..."
kubectl get pods --all-namespaces  # => Lists all system pods...
minikube dashboard                 # => Opens the Minikube dashboard in a browser.
```

Learn other kubectl commands to be able to use the tool effectively.

If you need to build Docker images to be used in a Minikube deployment you need to build the Docker images into the Minikube Docker registry (Minikube cannot access the Docker images you built into your workstation's Docker registry). First set your Docker environment to be the Minikube Docker registry:

```bash
eval $(minikube docker-env)
```

Then build Docker images the same way as you would build them using your host workstation - the images will be stored in the Minikube's Docker registry.


# Kubernetes Deployment Configurations

There are separate directories for single-node, azure-table-storage and aws-dynamodb K8 deployment configurations. The same script should deploy the Kubernetes deployment the same way to Minikube and to target Kubernetes clusters in Azure and AWS. Just check that you are using the right kubectl context and switch the context if necessary:


```bash
kubectl config current-context       # => Lists e.g. "minikube"
kubectl config get-contexts          # => List all contexts.
kubectl config use-context minikube  # => Switched to context "minikube".
```

There are some auxiliary scripts to view all entities and delete entities in a K8 namespace: [scripts](https://github.com/karimarttila/kubernetes/tree/master/simple-server/scripts).


## Some Observations Regarding the Kubernetes Configuration

Before we go to the actual Kubernetes deployments let's have a short review regarding some aspects of the configurations I've done.

**Image name**. Kubernetes deployment configurations are static yaml files - you don't have an argument mechanism e.g. to supply the image name to the deployment as an argument. We could have used [Helm](https://helm.sh/) which is a Kubernetes Package Manager to provide parameterization but using Helm just to provide the image name sounds a bit of an overkill. Therefore I did this part with bash/sed. Maybe later on I explore Helm a bit and provide this part using Helm.
**Automation**. I automated the actual ACR, AKS ets. Azure infra using Terraform. But the Kubernetes deployment part could be automated as well using Helm, bash or something like that. I didn't automate that part so that the reader can experiment the commands himself/herself and maybe this way get a better understanding of the overall Kubernetes deployment process. Maybe I will provide a short bash script to automate most of this anyway later on.
 

## Single Node

The single-node version of Simple Server can be running only in a single node since it uses a simulated internal server embedded database (Clojure Atom, to be specific). But it is easy to use this single-node version in basic Kubernetes deployment exploration since it has no dependencies to external databases.


### Minikube Deployment

First build the base image(s) and Simple Server Single-node image to Minikube registry:

```bash
eval $(minikube docker-env)    # Switch to Minikube registry.
#... deploy base-image(s) and Simple Server version.
docker images                  # => Check that you see the Docker images.
```

Then we can do the actual Kubernetes deployment. Go to [single-node](https://github.com/karimarttila/kubernetes/tree/master/simple-server/single-node) directory. 

```bash
kubectl config current-context                     # => Check context.
./create-simple-server-namespace.sh                # => Deploy namespace.
minikube ip                                        # => Check Minikube's ip.
./create-simple-server-deployment.sh minikube 192.168.99.100 0.1  # => Deploy K8 deployment. Use Minikube's ip.
kubectl get all --namespace kari-ss-single-node-ns # => Check LB's port.
curl http://192.168.99.100:31111/info              # => Try curling LB.
./call-all-ip-port.sh 192.168.99.100 31111         # call-all-ip-port.sh in Clojure Simple Server scripts directory.
kubectl get all --all-namespaces                   # => See all stuff in K8 cluster.
kubectl describe pod kari-ss-single-node-deployment-7c5557db8 --namespace kari-ss-single-node-ns                # => Check pod details of one pod.
```

If you got a lot of data when running "call-all-ip-port.sh" test script the deployment worked and you have successfully deployed the Simple Server Single-node version to Minikube Kubernetes cluster.


### Azure AKS Deployment

To build the Azure AKS infra needed for this Kubernetes deployment is given in my [Azure Repository](https://github.com/karimarttila/azure/tree/master/simple-server-aks).


#### Tag and Push Docker Images

I'm using the AKS infra I created in [Simple Server Azure AKS](https://github.com/karimarttila/azure/tree/master/simple-server-aks).

Next we deploy the same single-node version to Azure AKS.

First we need to know the name of the ACR terraform created. You can output the ACR name using terraform output command:

```bash
terraform output -module=env-def.acr  # => acr_name = YOURACRNAME
```

Login to that ACR registry:

az acr login --name YOURACRNAME

First you need to tag the Docker images using that acr name:

```bash
docker images   # => Check the initial tags first.
docker tag karimarttila/debian-openjdk11:0.1 YOURACRNAME.azurecr.io/karimarttila/debian-openjdk11:0.1
docker tag karimarttila/simple-server-clojure-single-node:0.1 YOURACRNAME.azurecr.io/karimarttila/simple-server-clojure-single-node:0.1
docker images   # => Check that you have the ACR tagged images.
```

Then we can push the tagged images to Azure ACR we created using terraform:

```bash
docker images   # => Check the images you are about to push.
docker push YOURACRNAME.azurecr.io/karimarttila/debian-openjdk11:0.1
docker push YOURACRNAME.azurecr.io/karimarttila/simple-server-clojure-single-node:0.1
az acr repository list --name YOURACRNAME --output table  # => Check that the images are safely in your Azure ACR registry.
```

You can automate this application layer Docker push to ACR later on if you wish.

#### Get Kubectl Context for Azure AKS

For using kubectl command line tool with Azure AKS I created earlier in [Simple Server Azure AKS](https://github.com/karimarttila/azure/tree/master/simple-server-aks) we need to get the azure aks credentials:

```bash
kubectl config get-clusters      # => Check the original set of your kube clusters.
terraform output -module=env-def.main-resource-group  # => Get the resource group name using terraform.
terraform output -module=env-def.aks | grep name      # => Get the AKS cluster name
az aks get-credentials --resource-group RESOURCE-GROUP-NAME --name AKS-CLUSTER-NAME
kubectl config get-clusters          # => You should now see the new cluster.
kubectl config current-context       # => Check which cluster is current.
kubectl config use-context AZURE-AKS-CONTEXT   # => Choose the Azure AKS context you got.  
```
 
#### Deploy Kubernetes Configuration to Azure AKS

The actual deployment goes almost the same way as with Minikube earlier. The only exception is that we are going to need the static ip for the Simple server Kubernetes Load balancer entity. You can ask the public ip address that we earlier created using terraform using command:

```bash
terraform output -module=env-def.single-node-pip  # => public_ip_address = PUBLIC-IP
```

Or using Azure cli (it's either 0 or 1):

```bash
az network public-ip list --resource-group karissaks-dev-main --query [0].ipAddress --output tsv
az network public-ip list --resource-group karissaks-dev-main --query [0].name --output tsv
```

```bash
kubectl config current-context                     # => Check context.
kubectl config use-context AZURE-AKS-CONTEXT       # => Change context if needed.
./create-simple-server-namespace.sh                # => Deploy namespace.
# I added the ACR as parameter - I wanted to test pulling images from different ACRs.
./create-simple-server-deployment.sh azure 11.11.11.11 0.1 ACR-NAME  # => Deploy K8 deployment. Use Static ip we created earlier and you queried just 5 secs ago.
kubectl get all --namespace kari-ss-single-node-ns # => Check LB's port.
# Wait till you get the static ip assigned for "EXTERNAL-IP" (might take for some minutes..., using "11.11.11.11" below as an example).
curl http://11.11.11.11:3045/info                  # => Use the external IP and try curling LB.
./call-all-ip-port.sh 11.11.11.11.100 3045         # call-all-ip-port.sh in Clojure Simple Server scripts directory.
kubectl get all --all-namespaces                   # => See all stuff in K8 cluster.
kubectl describe pod kari-ss-single-node-deployment-XXXXXX --namespace kari-ss-single-node-ns                # => Check pod details of one pod.
```

So, we demonstrated how to deploy the Simple Server Single-node version to the Azure AKS infra we created earlier in the azure repo side. Let's next deploy the actual Table-storage version that uses Azure Table storage tables as the database.


## Azure Table Storage Service

The Simple Server Tables-storage version application needs to access the Tables in the Storage account. There are two basic ways how to do this:

1. The Simple Server application needs the Table storage connection string or storage name and access key as secrets to be able to connect to the Azure Table storage.
2. We can create a Role assignment in which the scope is the Storage account and we create a Managed identity and give Contributor role for this Managed identity and later on configure the Kubernetes pods running the Simple Server to use this Managed identity (which has access to the Storage account).
 
 The second option is usually how I do things in the AWS side but let's first use the easier solution 1. In the first option there are a couple of ways to provide the secrets to the application running in a Kubernetes cluster pod:
 
 1. Somehow in the terraform configuration inject the secrets to AKS infra and the appication reads that secret there from the environment.
 2. Add the secretes to Azure Key Vault and the application reads the secrets from the Azure Key Vault. In this solution we still have to authorize the app to access the Azure Key Vault first.
 3. Inject the secrets as Kubernetes secrets to the Kubernetes cluster and the app running in pod reads the secrets from the Kubernetes environment as instructed in [Distribute Credentials Securely Using Secrets] (https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/).
 4. Just inject the secrets from sourced environmental variables to the temporary Kubernetes deployment file which is deleted right after deployment and the secret does not end up into Git repository but is safely in the home directory where it was sourced in the first place
 
 The fourth option is the easiest and this is an exercise so I'll first implement the Storage account access this way, maybe later on try other solutions as well.
 

### Minikube Deployment

Let's first deploy the Simple Server Azure Table Storage version to Minikube. "Minikube?" - you might be wondering. Yes, the app should be able to access the Azure Table Storage from the Minikube Kubernetes cluster the same way if we have configured the Azure Storage account connection string properly.

```bash
./create-simple-server-deployment.sh azure-table-storage minikube 192.168.99.100 0.1 dummy-acr
./call-all-ip-port.sh 192.168.99.100 31111
```

If you see all api calls succesfully returning data then we are good and the pod was succesfully connecting to the Azure Table Storage with the Azure storage connection string that was injected to the pod using the environmental variable.

Doing this step I refactored the ```create-simple-server-deployment.sh``` script quite a bit. So, now we can use the same bash script to deploy different Simple Server versions (single-node / table-storage...) and to deploy to different Kubernetes cluster versions (Minikube / Azure AKS...) 


### Azure AKS Deployment

We have to tag the table-storage version and push the tagged images to the Azure ACR registry just with the previous single-node version: see the details in the previous "Single Node" chapter.





# Kubernetes Debugging Tricks

## Getting Interactive Shell to a Running Kubernetes Pod

I had to use this trick when I was wondering why the application couldn't find one environmental variable in the pod - and the application crashed and the pod crashed as well. So, first you have to override the Docker entrypoint in the Kubernetes deployment, use e.g. the following command right after image definition:

```yaml
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo hello; sleep 10;done"]
```

The idea is to override the application entrypoint defined in the Docker image with some dummy entrypoint which leaves the pod doing something and not exiting immediately (that's why the indefinite bash while loop).

Then check the pod identifier and use the pod identifier to get an interactive bash to the pod:

```bash
kubectl get pods --namespace $MY_NS  => Get pod identifier, and use it in the next command:
kubectl exec -it kari-ss-table-storage-deployment-86b6d498ff-zdqq2  --namespace kari-ss-table-storage-ns /bin/bash
```








# Kubernetes Documentation Resources

Some useful documentation resources for Kubernetes and using Minikube specifically:

- [Kubernetes](https://kubernetes.io/) - Kubernetes home page.
- [Kubernetes Basics Official Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/) - A good tutorial with online Minikube to test Kubernetes.
- [Pluralsight - Getting Started with Kubernetes MOOC](https://www.pluralsight.com/courses/getting-started-kubernetes) - A good tutorial to Kubernetes.



