<p align="center">
  <img src="./assets/nucleus-small.png" alt="Nucleus Logo" width="250" height="250">
</p>

# Nucleus: Streamlined Kubernetes Cluster Deployment

Welcome to Nucleus, an advanced solution tailored for efficient and streamlined Kubernetes cluster deployment. Nucleus combines key Infrastructure as Code (IaC) tools into a single Podman image, ensuring a consistent and reliable setup process.

## Key Features

Unified IaC Tools in a Podman Image
Nucleus integrates essential IaC tools such as Packer, Terraform, and Ansible into a consolidated Podman image. This approach guarantees a uniform environment, free from the hassle of managing separate tool installations.

### Consistent Versioning with Configuration File

The main.nucleus.yml configuration file maintains the consistency of tool versions used across your Kubernetes deployments. By specifying a version in this file, Nucleus ensures that each build of your cluster uses the same versions of Packer, Terraform, and Ansible, enhancing reliability and predictability.

### Terraform State Management in S3

Efficiently manage multiple Kubernetes clusters with Terraform state securely stored in an S3 bucket. This feature allows for distinct and organized state management for each deployment.

### vSphere Support with Future IaaS Expansion

Nucleus currently supports vSphere for Kubernetes cluster deployments, with plans to extend its compatibility to other IaaS providers, broadening its scope and utility.

### Scalable and Customizable

Nucleus adapts to various project scales and requirements, offering scalability and customization options to align with different deployment scenarios.

## Use Cases

Streamlined Kubernetes Cluster Creation
Deploy Kubernetes clusters with ease using Nucleus, leveraging a comprehensive suite of IaC tools for a smooth and efficient setup.

### Consistent and Reliable Deployments

Achieve consistent and reliable development, testing, and production environments, courtesy of Nucleus’s unified Podman-based toolset and consistent tool versioning.

### Efficient Infrastructure Management

Nucleus simplifies the management of your Kubernetes infrastructure, supported by the integrated toolset and Terraform’s S3 state storage capabilities.

## Getting Started

Dive into our comprehensive documentation to start with Nucleus. It's designed for both Kubernetes beginners and experienced users who seek an efficient, consistent cluster management tool.

Step into a new era of Kubernetes deployment with Nucleus – your solution for a simplified, consistent, and scalable Kubernetes environment.

### Installation

```bash
sudo touch /usr/local/bin/nucleus \
&& sudo chmod +x /usr/local/bin/nucleus \
&& sudo tee /usr/local/bin/nucleus <<EOF
#!/bin/bash
bash <(curl -s https://gitlab.robochris.net/devops/nucleus/-/raw/main/nucleus.sh) "\$@"
EOF
```
