packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/hashicorp/vsphere"
    }

    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

locals {
  data_source_command = "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg"
  data_source_content = {
    "/ks.cfg" = templatefile("${abspath(path.root)}/data/ks.pkrtpl.hcl", {
      build_username = var.build_username
      build_ssh_key  = file("${var.ssh_directory}/${var.nucleus_project_name}.pub")
    })
  }
}

source "vsphere-iso" "nucleus" {
  // vSphere Settings
  vcenter_server      = var.vsphere_endpoint
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = var.vsphere_insecure_connection
  datacenter          = var.vsphere_datacenter
  cluster             = var.vsphere_cluster
  host                = var.vsphere_host
  datastore           = var.vsphere_datastore
  folder              = var.vsphere_folder

  // Virtual Machine Settings
  vm_name              = "nucleus-${var.nucleus_project_name}"
  guest_os_type        = "rhel8_64Guest"
  firmware             = "efi-secure"
  disk_controller_type = ["pvscsi"]
  CPUs                 = 2
  RAM                  = 2048

  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
  }

  network_adapters {
    network_card = "vmxnet3"
  }

  // ISO Settings
  iso_checksum = "sha256:635b30b967b509a32a1a3d81401db9861922acb396d065922b39405a43a04a31"
  iso_url      = "https://repo.almalinux.org/almalinux/8.8/isos/x86_64/AlmaLinux-8.8-x86_64-dvd.iso"

  // Boot and Provisioning Settings
  ssh_username         = var.build_username
  ssh_private_key_file = "${var.ssh_directory}/${var.nucleus_project_name}"
  convert_to_template  = true
  http_content  = local.data_source_content
  http_port_min = var.http_port
  http_port_max = var.http_port
  boot_order    = "disk,cdrom"
  boot_wait     = "2s"
  boot_command = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    " ${local.data_source_command}",
    "<enter><wait><leftCtrlOn>x<leftCtrlOff>"
  ]
}
