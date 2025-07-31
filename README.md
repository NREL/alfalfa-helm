# Alfalfa Helm Chart

[Alfalfa](https://github.com/NREL/alfalfa) is an open source web application forged in the melting pot of Building Energy Modeling (BEM), Building Controls, and Software Engineering domain expertise.​ Alfalfa transforms a Building Energy Models (BEMs) into virtual buildings by providing industry standard building control interfaces for interacting with models as they run.​ From a software engineering perspective, Alfalfa leverages widely adopted open source products and is architected according to best practices for a robust, modular, and scalable architecture.

## Chart Components

The `chart/` contains the complete Alfalfa application:
- **Application Services**: Web UI, Worker processes
- **Data Stores**: MongoDB, Redis, MinIO (S3-compatible storage), InfluxDB  
- **Monitoring**: Grafana dashboards
- **Application Ingresses**: Routes for web, grafana, and minio

## Chart Releases

This repository includes automated release workflows. Charts are automatically packaged and published when GitHub releases are created:

- **GitHub Releases**: Download chart packages (.tgz) directly from releases
- **Helm Repository**: Available at `https://nrel.github.io/alfalfa-helm`
- **OCI Registry**: Available at `oci://ghcr.io/nrel/helm-charts/alfalfa`

### Using Released Charts

```bash
# From Helm repository
helm repo add alfalfa https://nrel.github.io/alfalfa-helm
helm repo update
helm install alfalfa alfalfa/alfalfa

# From OCI registry
helm install alfalfa oci://ghcr.io/nrel/helm-charts/alfalfa

# From GitHub release
curl -LO https://github.com/NREL/alfalfa-helm/releases/latest/download/alfalfa-<version>.tgz
helm install alfalfa ./alfalfa-<version>.tgz
```

## Prerequisites

- Kubernetes 1.20+ cluster
- [Helm client](https://helm.sh/docs/intro/install/) (v3.4.2 or higher)
- [kubectl client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (v1.20.0 or higher)

## Installation

### Basic Installation
Install Alfalfa with default settings:

```bash
helm upgrade --install alfalfa ./chart --namespace alfalfa --create-namespace
```

## Uninstalling the Chart

To uninstall/delete the `alfalfa` helm chart:

`helm delete alfalfa`

The command removes all the Kubernetes components associated with the chart and deletes the release *including* persistent volumes. See more about persistent volumes below. *Make sure to run this command before deleting the k8s cluster itself as many cloud providers retain the persistent volumes on k8s deletion. The helm delete command will remove everything. 

## Configuration

The following table lists common configurable parameters of the alfalfa chart and their default values. This list is not representative of the full list. You can override any of the [values.yaml](chart/values.yaml) by specify the parameter name using the `--set key=value[,key=value]` argument to `helm install`. For example, to change the data storage for mongo from the default 100GB to 200GB, you would run this install command:

`helm install alfalfa alfalfa/alfalfa --set mongodb.persistence.size=200Gi`

Alternatively, you can create a `values.yaml` file you pass to helm via the `-values`


Parameter | Description | Default
--------- | ----------- | -------
mongo.persistence.size | Size of the volume for MongoDB | 10Gi |
mongo.persistence.size | Size of the volume for MongoDB | 10Gi |
minio.persistence.size | Size of the volume for Minio | 100Gi |
worker.replicas | Number of worker pods that run the simulations | 2 |
web.container.image   | Container to run the web front-end. Can use a custom image to override default | nrel/alfalfa-web:0.2.0 |
worker.container.image   | Container to run the worker. Can use a custom image to override default | nrel/alfalfa-worker:0.2.0 |


## Accessing alfalfa

Once you install the chart it'll take a couple of minutes to start all the containers. You can verify all the Kubernetes pods are up in running by running the following.  

`kubectl get po`  

example output of all pods running: 

```
NAME                             READY   STATUS      RESTARTS   AGE
goaws-899f94b7d-fpxnx            1/1     Running     0          74s
mc-xnk7l                         0/1     Completed   0          74s
minio-7ff55bc775-4hpwf           1/1     Running     0          75s
mongo-8448cb556c-zlwmr           1/1     Running     0          74s
nginx-ingress-6797b7b778-pnxzj   1/1     Running     0          74s
redis-55498c6cdd-xz2hb           1/1     Running     0          74s
web-64f5659554-rntjk             1/1     Running     0          74s
worker-7856c6d8fd-8phrl          1/1     Running     0          74s
worker-7856c6d8fd-b6pht          1/1     Running     0          74s

```

Once the cluster is up and running, you can use `kubectl get svc ingress-load-balancer` to determine the external IP or Domain Name to access alfalfa and use this to connect to the alfalfa web dashboard and the Kibana ELK dashboard if you enable the optional logging stack. 

AWS
```
$ kubectl get svc  ingress-load-balancer
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)                                     AGE
ingress-load-balancer   LoadBalancer   10.100.191.93   af021bf2cf1e6402780053ddb1109853-270686644.us-west-2.elb.amazonaws.com   80:31092/TCP,443:30635/TCP,9000:30843/TCP   108s
``` 

You will then use this EXTERNAL-IP to use with alfalfa cli commands. For the examples above, these would be:
AWS: http://a0a4014d98f0211ea91cb06528280f48-1900622776.us-west-2.elb.amazonaws.com 

Note that if you enabled https and have a domain, it's accessible via your domain name. e.g. https://myalfalfa.net

## Persistent Volumes

This helm chart provisions persistent storage for the database (MongoDB). This volume will persist throughout the life of the helm chart while it's running. It will **NOT** persist if you delete the helm chart. The volumes will be deleted along with it.   

## Auto Scaling

The worker pods __can__ be configured to auto-scale based on CPU threshold (default 50%). So once the aggregate CPU for all worker pods exceeds the defined threshold (in this case 50%), the Kubernetes engine will start adding additional worker pods up to the maximum specified. This is also dependent on how the Kuebernetes cluster was configured as additional VM node instances will also be added. Please refer to the notes on [aws](/aws/README.md) and [google](/google/README.md) when setting up the cluster and note the instance type and maximum nodes specified.  
