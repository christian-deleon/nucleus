variable "vsphere_endpoint" {
  type = string
}

variable "vsphere_insecure_connection" {
  type    = bool
  default = true
}

variable "vsphere_username" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "vsphere_folder" {
  type        = string
  description = "The folder to create the VM in. i.e. /example-folder"
}

variable "vsphere_host" {
  type = string
}

variable "http_port" {
  type        = number
  description = "The port to host the kickstart file on"
  default     = 8792
}

variable "build_username" {
  type        = string
  description = "The username to use for the build"
  default     = "nucleus"
}

variable "nucleus_project_name" {
  type        = string
  description = "The name of the project to create the VM in"
}

variable "ssh_directory" {
  type        = string
  description = "The directory to store the ssh key in"
  default     = "~/.ssh"
}
