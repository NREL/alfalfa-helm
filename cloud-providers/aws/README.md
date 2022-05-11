
Below is a guide to help setup a AWS Elastic Kubernetes Cluster (EKS) cluster using the AWS eksclt cli utility. This guide is meant to provide steps to setup the EKS cluster. Please refer to the [helm chart](/README.md) to install alfalfa chart once the EKS cluster is up and running.  

## Prerequisites

- AWS Account with EKS privileges
- AWS [eksctl client](https://docs.aws.amazon.com/eks/latest/userguide/eksctl) (v0.34.0 or higher)

## Install eksctl client
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html#installing-eksctl (0.34.0 or higher)


## Create a cluster using eksctl

eksctl will need access to AWS. You can provide access by setting ENV variables in your shell before running the cli (example below). More advanced info on eksctl can be found here: https://eksctl.io/

```
 export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
 export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
 export AWS_DEFAULT_REGION="YOUR_AWS_DEFAULT_REGION"
```
Below is an example that will create an AWS EKS cluster that has 3 nodes of instance type `t2.xlarge` with max nodes = 8 in us-west-2 region. This cluster is set to autoscale up to this max node amount. You can change the instance type and min and max node setting to your use case.  More info on [AWS instance types](https://aws.amazon.com/ec2/instance-types/)

```
eksctl create cluster \
    --name alfalfa \
    --version 1.22 \
    --region us-west-2 \
    --nodegroup-name standard-workers \
    --node-type t2.xlarge\
    --nodes 1 \
    --nodes-min 1 \
    --nodes-max 8 \
    --asg-access \
    --ssh-access \
    --ssh-public-key ~/.ssh/id_rsa.pub \
    --zones=us-west-2a,us-west-2b,us-west-2d \
    --managed
```

This is an example of the output you should see when you create the cluster: 

```TODO 
```

## Connecting to your cluster using kubectl

Once eksctl is done setting up the cluster, it will automatically setup the connection by creating a `~/.kube/config` file so you and can begin using helm and kubectl cli tools to communicate with the cluster.  You may need to run generate this config manually (e.g. opening up a new terminal or on another machine ). To generate this kube config, run `aws eks update-kubeconfig --name alfalfa`  Change the `--name` to match the cluster name if different from the example.  

## Delete the cluster using eksctl

To delete the cluster you just need to specify the name of the cluster. 

`eksctl delete cluster --name alfalfa`

This is an example of the output you should see when you delete the cluster: 

```
TODO
```

It's always good idea to verify the cluster has been deleted. 

`eksctl get cluster`

This cmd should return no clusters. You can also use the web console in your AWS account to verify as well. 











