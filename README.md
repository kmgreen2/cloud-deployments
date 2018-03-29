# Environment, Manifests and Scripts for Deploying Systems to AWS

This repository contains everything needed to stand-up Kubernetes in AWS and
deploy services on top of Kubernetes.  This also contains a basic service that
can be used to test connectivity of instances running outside of Kubernetes.

Currently, the following systems are supported:

- echoserver: This is a simple service that will either echo the text sent to \
port 1337, or forward to another, specified echoserver that will echo the text.  \
Forwarding can be chained as long as necessary and the echoed output will \
contain the path taken.  The echoserver runs in both Kubernetes and in AWS instances.\

- kafka: This contains a basic Kafka deployment (including a ZK deployment) in \
Kubernetes.  It makes extensive use of stateful sets. 

- ethereum: This deploys all of the components needed to deploy and bootstrap a \
private ethereum network.

Before you begin:

- Be sure to put a public key that can be used to access your AWS account in this directory (it must be called: id_rsa.pub).

- Put a key-pair in this directory to be used for instance-to-instance ssh in AWS (they must be called: id_rsa_instance.pub and id_rsa_instance)

- Be sure to export your AWS credentials to the following env vars: ARG_AWS_ACCESS_KEY_ID, ARG_AWS_SECRET_ACCESS_KEY

- Create a directory called root-dir, which is used to maintain the configurations generated for the resulting Kuberneters cluster. 

## ./build-env.sh

Top-level script that will build the Docker image for the "deployment" environment, which
is where we actually run kops, packer, terraform, kubectl, awscli, etc.

This will also create the Docker images that we ultimately want to deploy, such
as the image for echo_server.py.

## ./run-env.sh

Open an interactive shell with appropriate volume mounts into the deployment
environment.  This is the environment used to actually do the deployments.

## manifests/

Contains the manifests for each of the main components: docker, packer, k8s, terraform

## scripts/

Contains the scripts used to trigger builds or deployments for the main
components: docker, packer, k8s, terraform

### scripts/docker/build-images.sh

Builds an image that is used to perform the setup and accessibility to a
Kubernetes cluster script (setup_k8s.sh).  It also installs Python, kubectl
and kops to be used in managing and interacting with the cluster built.

It also builds a Docker image for the echo server, which will be used by the
Kubernetes manifest (and deployed to the Kuberentes cluster).

### scripts/docker/run-image.sh 

Run the image.  State is maintained in a bind mount, ./root-dir, that contains
the config info needed to interact with kops and kubectl after creating the
cluster using setup_k8s.sh

### scripts/packer/build-dumbstack-ami.sh

Shell script and Packer manifest for generating a Linux AMI containing
ha-proxy, which is used as a proxy between Kubernetes and regular VMs.  The
manifest is build-haproxy-ami.json.

### scripts/packer/build-echoserver-ami.sh

Shell script and Packer manifest for generating a Linux AMI containing the echo
server.  The manifest is build-echoserver-ami.json.

### scripts/k8s/setup-k8s.sh

This is run from within the container (run-image.sh) to create a new cluster.
Only needs to be run once to create the cluster.  The cluster can be torn down
using 'kops delete cluster <cluster> --yes'

## services/

Contains the service and configuration for each service.  Currerntly, we have
four: dumbstack, echoserver.  The other services (e.g. Kafka and Ethereum) pull
specific versions from github.

### services/echoserver/echo_server.py 

A dumb server to use for testing.  This can be deployed to either an amazon
instance (via AMI) or applied to the Kubernetes cluster (via Docker and k8s
manifest).

### services/dumbstack

Dumbstack is similar to Smartstack, but much simpler and not as "smart."  It uses
the information from the AWS API to configure haproxy.

Dumbstack is comprised of a python script, a daemon and haproxy.  The python script
uses the AWS API to get eligable instances to add to the haproxy config (via tags).
The tags are used to create FE and BE in an haproxy config.

The daemon periodically calls the python script, writes a new haproxy config, and
reloads haproxy.

## TODO

Explain the overall architecture with a picture and provide examples for using this repo.
