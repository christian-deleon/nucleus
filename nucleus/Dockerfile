# Base Image
FROM python:3.11.6

# Set Working Directory
WORKDIR /usr/src/app

# Install Dependencies
RUN apt-get update && \
    apt-get install -y \
    unzip git openssh-client sshpass

# Install Yaml Parser (yq)
ENV YQ_VERSION=4.40.4
ADD https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64.tar.gz /tmp
RUN tar xzf /tmp/yq_linux_amd64.tar.gz && \
    mv yq_linux_amd64 /usr/local/bin/yq && \
    rm /tmp/yq_linux_amd64.tar.gz

# Install Packer
ENV PACKER_VERSION=1.9.4
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip /tmp
RUN unzip /tmp/packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm /tmp/packer_${PACKER_VERSION}_linux_amd64.zip

# Install Terraform
ENV TERRAFORM_VERSION=1.6.4
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp
RUN unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Ansible
RUN pip install ansible==8.6.1

# Copy packer files into the Container
COPY ./packer/ /usr/src/app/packer/

# Initialize Packer
RUN packer init /usr/src/app/packer/

# Copy Terraform files into the Container
COPY ./terraform/ /usr/src/app/terraform/

# Initialize Terraform
RUN terraform -chdir=/usr/src/app/terraform init

# Copy Ansible Python Requirements into the Container
COPY ./ansible/requirements.txt /usr/src/app/ansible/

# Install Ansible Python Requirements
RUN pip install -r /usr/src/app/ansible/requirements.txt

# Copy Ansible files into the Container
COPY ./ansible/ /usr/src/app/ansible/

# Copy Templates into the Container
COPY ./templates/ /usr/src/app/templates/

# Copy Parser into the Container
COPY ./nucleus/config_parser.py /usr/src/app/nucleus/config_parser.py

# Add an Entry Point Script
COPY ./nucleus/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
