build {
  sources = ["source.vsphere-iso.nucleus"]

  provisioner "ansible" {
    user          = var.build_username
    playbook_file = "${path.root}/../ansible/configure-template.yml"
    ansible_env_vars = [ "ANSIBLE_CONFIG=${path.root}/ansible.cfg" ]
    extra_arguments = [ "-e", "project_name=${var.nucleus_project_name}",
    ]
  }
}
