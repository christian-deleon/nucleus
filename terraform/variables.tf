variable "vsphere_endpoint" {
  type = string
  description = "The vSphere endpoint to connect to."
}

variable "vsphere_username" {
  type = string
  description = "The username to use to connect to vSphere."
}

variable "vsphere_password" {
  type      = string
  sensitive = true
  description = "The password to use to connect to vSphere."
}

variable "datacenter" {
  type        = string
  description = "The name of the datacenter to use for the virtual machines."
}

variable "compute_cluster" {
  type        = string
  description = "The name of the compute cluster to use for the virtual machines."
}

variable "network" {
  type        = string
  description = "The name of the network to use for the virtual machines."
}

variable "folder" {
  type        = string
  description = "The name of the folder to use for the virtual machines."
}

variable "project_name" {
  type        = string
  description = "The name of the project to use for the virtual machines."
}

variable "master_cpu" {
  type        = number
  description = "The number of CPUs to use for the master virtual machine."
  default = 4
}

variable "master_memory" {
  type        = number
  description = "The amount of memory to use for the master virtual machine."
  default = 8192
}

variable "master_disk_size" {
  type        = number
  description = "The size of the disk to use for the master virtual machine."
  default = 100
}

variable "worker_cpu" {
  type        = number
  description = "The number of CPUs to use for the worker virtual machine."
  default = 6
}

variable "worker_memory" {
  type        = number
  description = "The amount of memory to use for the worker virtual machine."
  default = 16384
}

variable "worker_disk_size" {
  type        = number
  description = "The size of the disk to use for the worker virtual machine."
  default = 250
}
