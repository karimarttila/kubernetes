# Simple Server Kubernetes Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [Minikube](#minikube)
- [Kubernetes Deployment Configurations](#kubernetes-deployment-configurations)
  - [Single Node](#single-node)
    - [Build Docker Images to the Right Registry](#build-docker-images-to-the-right-registry)
    - [Make Kubernetes Deployment](#make-kubernetes-deployment)
- [Kubernetes Documentation Resources](#kubernetes-documentation-resources)

# Introduction

This Simple Server Kubernetes project comprises various Kubernetes configurations for studying Kubernetes. 

The Simple Server Single-node K8 configuration is just for testing Simple Server with local Kubernetes Minikube deployment.

The Simple Server Azure Table Storage version provides Kubernetes deployment for Azure AKS.

The Simple Server AWS DynamoDB version provides Kubernetes deployments for AWS EKS and Fargate.

The Simple Server language version in all these K8 versions is the Clojure version, see: [Simple Server Clojure](https://github.com/karimarttila/clojure/tree/master/clj-ring-cljs-reagent-demo/simple-server).

 

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

There are some auxiliary scripts to view all entities and delete entities in a K8 namespace: [scripts](TODO).

## Single Node

### Build Docker Images to the Right Registry

First build the base image(s) and Simple Server Single-node image to Minikube/AWS/Azure registry. Example using Minikube:

```bash
eval $(minikube docker-env)    # Switch to Minikube registry.
#... deploy base-image(s) and Simple Server version.
docker images                  # => Check that you see the Docker images.
```

### Make Kubernetes Deployment

Go to [single-node](TODO) directory. 

```bash
kubectl config current-context                     # => Check context.
./create-simple-server-namespace.sh                # => Deploy.
./create-simple-server-deployment.sh
minikube ip                                        # => Check Minikube's ip.
kubectl get all --namespace km-ss-single-node-ns   # => Check LB's port.
./call-all-ip-port.sh 192.168.99.100 30088         # call-all-ip-port.sh in Clojure Simple Server scripts directory.
```

# Kubernetes Documentation Resources

Some useful documentation resources for Kubernetes and using Minikube specifically:

- [Kubernetes](https://kubernetes.io/) - Kubernetes home page.
- [Kubernetes Basics Official Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/) - A good tutorial with online Minikube to test Kubernetes.
- [Pluralsight - Getting Started with Kubernetes MOOC](https://www.pluralsight.com/courses/getting-started-kubernetes) - A good tutorial to Kubernetes.



