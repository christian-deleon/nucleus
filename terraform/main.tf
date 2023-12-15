terraform {
  required_version = "~> 1.6"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.6.1"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_endpoint
  allow_unverified_ssl = true
}

module "k8s_cluster" {
  source  = "gitlab.robochris.net/devops/vmware-kubernetes-cluster/vmware"
  version = "1.2.1"

  datacenter      = var.datacenter
  compute_cluster = var.compute_cluster
  network         = var.network
  create_folder   = false
  folder_path     = var.folder
  cluster_name    = var.project_name

  # Master
  master_vm_template = "nucleus-${var.project_name}"
  master_cores       = var.master_cpu
  master_memory      = var.master_memory
  master_disk_size   = var.master_disk_size

  master_mapping = [
    {
      host      = "esxi1.local"
      datastore = "host1_datastore1"
    },
    {
      host      = "esxi2.local"
      datastore = "host2_datastore1"
    },
    {
      host      = "esxi3.local"
      datastore = "host3_datastore1"
    }
  ]

  # Worker
  worker_vm_template = "nucleus-${var.project_name}"
  worker_cores       = var.worker_cpu
  worker_memory      = var.worker_memory
  worker_disk_size   = var.worker_disk_size
  
  worker_mapping = [
    {
      host      = "esxi1.local"
      datastore = "host1_datastore1"
    },
    {
      host      = "esxi2.local"
      datastore = "host2_datastore1"
    },
    {
      host      = "esxi3.local"
      datastore = "host3_datastore1"
    }
  ]
}
