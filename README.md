# Alfalfa Helm Chart

[Alfalfa](https://github.com/NREL/alfalfa) Alfalfa is an open source web application forged in the melting pot of Building Energy Modeling (BEM), Building Controls, and Software Engineering domain expertise.​ Alfalfa transforms a Building Energy Models (BEMs) into virtual buildings by providing industry standard building control interfaces for interacting with models as they run.​ From a software engineering perspective, Alfalfa leverages widely adopted open source products and is architected according to best practices for a robust, modular, and scalable architecture.

## Introduction

This helm chart installs a Alfalfa web application instance on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager. 


## Prerequisites

- Kubernetes 1.8+ cluster.  Please refer to cluster setup instructions for [google](/cloud-providers/google/README.md), [aws](/cloud-providers/aws/README.md), or [azure](/cloud-providers/azure/README.md) for information on how to provision a k8s cluster. 
- [helm client](https://helm.sh/docs/intro/install/) (v3.4.2 or higher)
- [kubectl client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (v1.20.0 or higher) 

## Installing the Chart

To install the helm chart with the chart name `alfalfa`, you can run the following commands (below) in the root directory of this repo depending on which cloud provider you are using. This assumes you already have a Kubernetes cluster up and running. If you do not, please refer to [google](/cloud-providers/google/README.md), [aws](/cloud-providers/aws/README.md) or azure (/cloud-providers/azure/README.md) for help setting up the Kubernetes cluster. 


For Google  
`helm install alfalfa ./alfalfa-chart--set provider.name=google`

For Amazon  
`helm install  alfalfa ./alfalfa-chart --set provider.name=aws`

For Azure  
`helm install  alfalfa ./alfalfa-chart --set provider.name=azure`

The `--provider.name` is needed as parameter as each cloud provider uses different names for persistent volumes. For example, Google refers to ssd volumes as `pd-ssd`, aws is `gp2` and azure is `StandardSSD_LRS`.  This helm chart creates a new storage class called `ssd` and abstracts this to provide a single storage id. 

## Installing optional logging stack

The helm chart contains optional subcharts for advanced logging features. This includes the Elastic logging stack with a GUI dashboard called Kibana. It allows users to access the web GUI Kibana and investigate container logs and resource consumption such as cpu, memory, disk utilization, network I/O. To enable this optional logging feature, first you will need to install the dependencies (command below starting in the root of the repo)

```bash 
cd alfalfa-chart
helm repo add elastic https://helm.elastic.co
helm dependency update
```

Once the dependencies ares installed, pass in the optional arg `tags.log_stack=true` to helm (examples below) to enable this feature.

For Google  
`helm install alfalfa ./alfalfa-chart --set provider.name=google --set tags.log_stack=true`

For Amazon  
`helm install  alfalfa ./alfalfa-chart --set provider.name=aws --set tags.log_stack=true`

For Azure  
`helm install  alfalfa ./alfalfa-chart --set provider.name=azure --set tags.log_stack=true`

## url end-points

For http only installations, the various end-points are reached by the IP and port as indicated below, or if you have a domain and want to create a A records, that is an option too. 

## http and https (encryption)

Alfalfa provides web services that are all configurable to run over http or https. The default behavior of this helm chart is deploy all services as http, so please be aware that traffic is unencrypted using the defaults. To enable https properly, you will need to have a registered domain name with authority to create A records. You can use self-signed certs but this creates problems with web client browers and tools connecting to the urls, so these docs will not go into detail on how to setup self-signed certs but is entirely possible and may make sense for your workflow.  If you want to setup https with your domain, please read the instructions below. You can use your existing certificates if you have them, or you can use the built-in certificate manager "letsencrypt" that can generate certificates for you. This process is not a push-of-a-button (maybe someday) but it's close. There are few more steps involved than just installing the chart. 

## enable https

To enable https using CA signed certificates, you first need to have ownership of a domain name and  have rights to add in a A record. This repository is configured to use certbot using letsencrypt as the certificate authority. There are few extra steps that need to happen to enable https, which are mostly due to generating certificates that can be used with the nginx-controller. Below are those steps. 

1 ) set the following in values.yaml (your name will be different)  
   `domain_name: "exampledomain.come"`

2 ) install the helm chart. e.g. (more examples below on installing the chart). This one is used to install to aws. 
`helm install alfalfa ./alfalfa-chart --set provider.name=aws` 

3 ) Once the helm is installed, wait for all the pods to enter into running state. Once this is done, determine the public IP of the ingress-load-balancer. 

```
 kubectl get svc ingress-load-balancer
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)                                                                   AGE
ingress-load-balancer   LoadBalancer   10.100.121.15   a9bd74c960ff04768a94d7a6cc631f17-1542031464.us-west-2.elb.amazonaws.com   80:31730/TCP,443:32156/TCP,9000:32330/TCP,5601:32305/TCP,8081:31068/TCP   3d23h
``` 
AWS lists the domain name vs IP so you can do a nslookup to obtain the IP. Other cloud providers list the public IP.
```
nslookup a9bd74c960ff04768a94d7a6cc631f17-1542031464.us-west-2.elb.amazonaws.com
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
Name:	a9bd74c960ff04768a94d7a6cc631f17-1542031464.us-west-2.elb.amazonaws.com
Address: 52.26.3.143
```

Once you obtain the public IP, you will need to create an A record for your domain name to point to this IP. This process is outside the scope of this repo but there plenty of online resources to help with this process. 

Once the A record is created and available via DNS query, you can create the certificates and then enable https. See step 4. 

4 ) run the commands below to exec into the certbot container and create the certificates. 

First get the certbot \<pod-id> 
```
kubectl get po | grep certbot
certbot-6df4b786c-jvm2g          1/1     Running     0          14m    0          3d23h
```
 
 You can run the command below to generate the certificates.

 `kubectl exec -it <certbot-pod-id> certbot  certonly --webroot --webroot-path=/etc/letsencrypt/webroot -d yourdomainname.net` 
 
 Certbot will ask for a few questions such as your email address. Answer those and then the ACME challenge will start, and if all goes well, it will generate certs that you can use to enable https.  *Note* if you changed the default value of: 
`loadBalancerSourceRanges: 0.0.0.0/0` and set this to a restricted CIDR, you will need to change this back to `0.0.0.0/0` so the certificate authority can access and perform the ACME challenge. After this is complete, you can change the value back to your preferred setting. 

Here is an example of running certbot. 

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): test@exampledomain.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: N
Account registered.
Requesting a certificate for exampledomain.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/exampledomain.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/exampledomain.com/privkey.pem
This certificate expires on 2022-05-16.
These files will be updated when the certificate renews.

NEXT STEPS:
- The certificate will need to be renewed before it expires. Certbot can automatically renew the certificate in the background, but you may need to take steps to enable that functionality. See https://certbot.org/renewal-setup for instructions.
```

nginx_https:
5 ) Now that the certs are generated, simply change the value below to true and update helm. 

`nginx_https.enable: true`

Run the following update command. Note this command sets the value above using args. If you set this in values.yaml you do not need to pass in this to helm. 

 `helm upgrade alfalfa ./alfalfa-chart --set nginx_https.enable=true --set provider.name=aws`


TODO
Add in docs on how to use helm when working with TLS and enabling https. 

## Uninstalling the Chart

To uninstall/delete the `alfalfa` helm chart:

`helm delete alfalfa`

The command removes all the Kubernetes components associated with the chart and deletes the release *including* persistent volumes. See more about persistent volumes below. *Make sure to run this command before deleting the k8s cluster itself as many cloud providers retain the persistent volumes on k8s deletion. The helm delete command will remove everything. 

## Configuration

The following table lists common configurable parameters of the alfalfa chart and their default values. This list is not representative of the full list. You can override any of the [values.yaml](alfalfa-chart/values.yaml) by specify the parameter name using the `--set key=value[,key=value]` argument to `helm install`. For example, to change the data storage for mongo from the default 100GB to 200GB, you would run this install command:

For Google  
`helm install alfalfa ./alfalfa-chart --set provider.name=google --set mongo.persistence.size=200Gi`

For Amazon  
`helm install alfalfa ./alfalfa-chart --set provider.name=aws --set mongo.persistence.size=200Gi`

For Azure  
`helm install alfalfa ./alfalfa-chart --set provider.name=azure --set mongo.persistence.size=200Gi`

Alternatively, you can edit the [values.yaml](alfalfa-chart/values.yaml) directly. 


Parameter | Description | Default
--------- | ----------- | -------
mongo.persistence.size | Size of the volume for MongoDB | 10Gi |
mongo.persistence.size | Size of the volume for MongoDB | 10Gi |
minio.persistence.size | Size of the volume for Minio | 100Gi |
worker.replicas | Number of worker pods that run the simulations | 2 |
web.container.image   | Container to run the web front-end. Can use a custom image to override default | nrel/alfalfa-web |
worker.container.image   | Container to run the worker. Can use a custom image to override default | nrel/alfalfa-worker |


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

Once the cluster is up and running, you can use `kubectl` to determine the external IP or Domain Name to access alfalfa and use this to connect to the alfalfa API. For example, on AWS, a0a4014d98f0211ea91cb06528280f48-1900622776.us-west-2.elb.amazonaws.com is the external name. See the examples below for each cloud provider. 

AWS
```
$ kubectl get svc  ingress-load-balancer
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)                                     AGE
ingress-load-balancer   LoadBalancer   10.100.191.93   af021bf2cf1e6402780053ddb1109853-270686644.us-west-2.elb.amazonaws.com   80:31092/TCP,443:30635/TCP,9000:30843/TCP   108s


```
Google TODO
```
TODO
```
 Azure is TODO
```
TODO
```

You will then use this EXTERNAL-IP to use with alfalfa cli commands. For the examples above, these would be:
AWS: http://a0a4014d98f0211ea91cb06528280f48-1900622776.us-west-2.elb.amazonaws.com 
Google: TODO
Azure:  TODO


## Persistent Volumes

This helm chart provisions persistent storage for the Database (MongoDB). This volume will persist throughout the life of the helm chart while it's running. It will **NOT** persist if you delete the helm chart. The volumes will be deleted along with it.   
## Auto Scaling

The worker pods __could__ be configured to auto-scale based on CPU threshold (default 50%). So once the aggregate CPU for all worker pods exceeds the defined threshold (in this case 50%), the Kubernetes engine will start adding additional worker pods up to the maximum specified. This is also dependent on how the Kuebernetes cluster was configured as additional VM node instances will also be added. Please refer to the notes on [aws](/aws/README.md) and [google](/google/README.md) when setting up the cluster and note the instance type and maximum nodes specified.  This could be a nice add-on to this repo.  

## Run a test
TODO















