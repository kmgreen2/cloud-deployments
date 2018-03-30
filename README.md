# Environment, Manifests and Scripts for Deploying Systems to AWS

This repository contains everything needed to stand-up Kubernetes in AWS and
deploy services on top of Kubernetes.  This also contains a basic service that
can be used to test connectivity of instances running outside of Kubernetes.

Currently, the following systems are supported:

- echoserver: This is a simple service that will either echo the text sent to \
port 1337, or forward to another, specified echoserver that will echo the text.  \
Forwarding can be chained as long as necessary and the echoed output will \
contain the path taken.  The echoserver runs in both Kubernetes and in AWS instances.\

- kafka (k8s only): This contains a basic Kafka deployment (including a ZK deployment) in \
Kubernetes.  It makes extensive use of stateful sets. 

- ethereum (k8s only): This deploys all of the components needed to deploy and bootstrap a \
private ethereum network.

The following infrastructure will be deployed to AWS (us-west-2 right now):

- Kubernetes cluster in its own VPC (currently using kops)
- A "Cloud VPC" is created with two subnets: private and public
- The following components are created within the "Cloud VPC":
  - 1-to-N echoservers are deployed in each subnet
  - A service called dumbstack is deployed.  This service contains two ENIs, one for each subnet.  In short, based on a configuration (see below), dumbstack will poll the AWS API to see if it should setup load balancing for any instances running in AWS.  By default, it will discover all echoservers running in the "Cloud VPC."  The power of dumbstack is its ability to load balance requests across different subnets.  This is particularly useful when running services across public and private clouds.  Dumbstack can be used as a proxy between cloud and on-prem networks.
  - VPC peering is setup between the "private" subnet in the "Cloud VPC" and the Kubernetes VPC.

Here is a figure captuing the main components:

## Quickstart

### Before You Begin

- Be sure to put a public key that can be used to access your AWS account in this directory (it must be called: id_rsa.pub).

- Put a key-pair in this directory to be used for instance-to-instance ssh in AWS (they must be called: id_rsa_instance.pub and id_rsa_instance)

- Be sure to export your AWS credentials to the following env vars: ARG_AWS_ACCESS_KEY_ID, ARG_AWS_SECRET_ACCESS_KEY

- Create a directory called root-dir, which is used to maintain the configurations generated for the resulting Kuberneters cluster. 

### Setup Deployment Environment

Once you set things up as descirbed above, you can build the docker image
containing an environment that you can deploy your infrastructure and services
from.

To build the Docker image:

`./build-env.sh`

To enter the environment:

`./run-env.sh`

Once in the environment, you can use packer, terraform, kops, kubectl, etc. without worrying about setting any configuration.

### Creating the Kubernetes Cluster

From the deployment environment, run:

`/scripts/k8s/base/deploy-cluster.sh`

When this script finishes, you will be prompted to run the following (do it!):

`kops update cluster kmg-cluster.k8s.local --yes`

A few minutes after that finishes, you should have the Kubernetes cluster up and running.

To delete the cluster, run:

`/scripts/k8s/base/delete-cluster.sh`

### Creating the Cloud VPC

Now that the Kubernetes cluster is up, we can create the other VPC (currently,
the Kubernetes cluster is needed to be up in order to setup peering).

Run the following:

`/scripts/terraform/terraform_run.sh -e -prod -o plan`

If that succeeds, then run:

`/scripts/terraform/terraform_run.sh -e -prod -o apply`

The apply should take a while.  When it is done, the base environment is ready for use.

### Deploy echoserver to Kubernetes

Once the Kubernetes cluster is operational (takes a few minutes), you can
deploy the echoserver to it.

Just run this:

`kubectl apply -f /manifests/k8s/base/k8s-echoserver-manifest.yaml`

### Deploying Other Services to Kubernetes

We currently have support for Kafka and Ethereum.  To deploy these services to Kubernetes, run:

`/scripts/k8s/<service>/deploy.sh`

To destroy, run:

`/scripts/k8s/<service>/teardown.sh`

## Some More Explanation

### ./build-env.sh

Top-level script that will build the Docker image for the "deployment" environment, which
is where we actually run kops, packer, terraform, kubectl, awscli, etc.

This will also create the Docker images that we ultimately want to deploy, such
as the image for echo_server.py.

### ./run-env.sh

Open an interactive shell with appropriate volume mounts into the deployment
environment.  This is the environment used to actually do the deployments.

### manifests/

Contains the manifests for each of the main components: docker, packer, k8s, terraform

### scripts/

Contains the scripts used to trigger builds or deployments for the main
components: docker, packer, k8s, terraform

### services/

Contains the service and configuration for each service.  Currerntly, we have
four: dumbstack, echoserver.  The other services (e.g. Kafka and Ethereum) pull
specific versions from github.

### services/dumbstack

Dumbstack is similar to Smartstack, but much simpler and not as "smart."  It uses
the information from the AWS API to configure haproxy.

Dumbstack is comprised of a python script, a daemon and haproxy.  The python script
uses the AWS API to get eligable instances to add to the haproxy config (via tags).
The tags are used to create FE and BE in an haproxy config.

The daemon periodically calls the python script, writes a new haproxy config, and
reloads haproxy.
