# Base Image
FROM python:3.11.6

# Set Working Directory
WORKDIR /root

################################################
# Install Dependencies
################################################

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

# Copy Ansible Python Requirements into the Container
COPY ./ansible/requirements.txt /root/ansible/

# Install Ansible Python Requirements
RUN pip install -r /root/ansible/requirements.txt

################################################
# Configure Container
################################################

# Copy packer files into the Container
COPY ./packer/ /root/packer/

# Initialize Packer
RUN packer init /root/packer/

# Copy Terraform files into the Container
COPY ./terraform/ /root/terraform/

# Initialize Terraform
RUN terraform -chdir=/root/terraform init

# Copy Ansible files into the Container
COPY ./ansible/ /root/ansible/

# Install Ansible Collections
WORKDIR /root/ansible
RUN ansible-galaxy collection install -r requirements.yml
WORKDIR /root

# Copy Templates into the Container
COPY ./templates/ /root/templates/

# Copy Nuclues files into the Container
COPY ./nucleus/ /root/nucleus/

# Make Nuclues Scripts Executable
RUN chmod +x /root/nucleus/*.sh
