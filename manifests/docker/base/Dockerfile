FROM centos:7

ARG ARG_AWS_ACCESS_KEY_ID
ARG ARG_AWS_SECRET_ACCESS_KEY

RUN yum update -y
RUN yum install -y python
RUN yum install -y curl
RUN yum install -y wget
RUN yum install -y bash
RUN yum install -y vim

# Install latest pip.
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN rm get-pip.py

RUN pip install awscli
RUN pip install boto3

RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
RUN chmod +x kops-linux-amd64
RUN mv kops-linux-amd64 /usr/local/bin/kops

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Install Packer and unzip (needed to unpack binary)
RUN yum install -y unzip
RUN curl https://releases.hashicorp.com/packer/1.2.1/packer_1.2.1_linux_amd64.zip?_ga=2.78657748.1572937325.1520607817-268057995.1520607817 -o packer_1.2.1_linux_amd64.zip
RUN unzip packer_1.2.1_linux_amd64.zip
RUN mv packer /usr/local/bin
RUN rm packer_1.2.1_linux_amd64.zip

# Install Terraform
RUN curl https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip?_ga=2.205903571.1394138376.1520866634-1643579460.1520607757 -o terraform_0.11.3_linux_amd64.zip
RUN unzip terraform_0.11.3_linux_amd64.zip
RUN mv terraform /usr/local/bin
RUN rm terraform_0.11.3_linux_amd64.zip

ENV AWS_ACCESS_KEY_ID=$ARG_AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_REGION=us-west-2
ENV KOPS_STATE_STORE=s3://kops-datastore-k8s
ENV EDITOR=vim
ENV VISUAL=vim
