Below is a guide to help setup a Microsoft Azure Kubernetes Cluster (AKS) using the azure cli utility. This guide is meant to provide steps to setup the cluster. Please refer to the [helm chart](/README.md) to install alfalfa chart once the AKS is up and running.  

## Prerequisites

- Microsoft Azure Account with Kubernetes privileges
- Microsoft Azure CLI utility `az`

## Install Azure cli client
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli


## Use az to login to your account. 
`az login`

This will allow you to login to your Azure account. If your using only a terminal w/o a web browser, you can use altertative ways to use the cli utility to login. Please refer to the [login instructions](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az_login)

## Create a resource group

Create a resource group and specifiy a data center location. The example below uses westus2 region. 

`az group create --name alfalfa --location westus2`


## Create the cluster. Change the --max-count and --node-vm-size to your use case. 

    az aks create --resource-group alfalfa \
    --name alfalfa \
    --kubernetes-version 1.18.14 \
    --node-count 1 \
    --node-vm-size Standard_D4_v4 \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 8 \
    --ssh-key-value  ~/.ssh/id_rsa.pub 

## Set credentials to use cluster. 

`az aks get-credentials --resource-group alfalfa --name alfalfa`

The above command creates the config in ~/.kube/config which is needed to use the `kubectl` cli to interface with the cluster. Once this is ran, confirm that you are connected and able to interface with the cluster by running the following. 

`kubectl get nodes`

You should see similar output to this. 

```
NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-23944537-vmss000000   Ready    agent   12m   v1.18.14
aks-nodepool1-23944537-vmss000001   Ready    agent   12m   v1.18.14
aks-nodepool1-23944537-vmss000002   Ready    agent   12m   v1.18.14
```
The cluster is now ready to deploy the helm chart. Please refer to the helm [README.md](../README.md) to deploy the alfalfa helm chart. 

## Delete cluster

When you are finished and you can simply delete the entire cluster. 

 `az aks delete --resource-group alfalfa --name alfalfa`

## Delete resource group 

`az group delete --resource-group alfalfa`


















