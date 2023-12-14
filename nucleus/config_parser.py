import yaml


def read_yaml(file_path: str):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)


def write_hcl(file_path: str, data: dict):
    with open(file_path, 'w') as file:
        for key, value in data.items():
            file.write(f'{key} = "{value}"\n')


def packer():
    packer_variables = {
        "vsphere_endpoint": config['vsphere']['endpoint'],
        "vsphere_insecure_connection": "true" if config['vsphere']['insecure_connection'] else "false",
        "vsphere_username": variables['vsphere']['username'],
        "vsphere_password": variables['vsphere']['password'],
        "vsphere_datacenter": config['vsphere']['datacenter'],
        "vsphere_cluster": config['vsphere']['cluster'],
        "vsphere_network": config['vsphere']['network'],
        "vsphere_folder": config['vsphere']['folder'],
        "vsphere_host": config['vsphere']['template']['host'],
        "vsphere_datastore": config['vsphere']['template']['datastore'],
        "nucleus_project_name": config['name'],
    }

    write_hcl('.nucleus/variables.pkrvars.hcl', packer_variables)


def terraform():
    terraform_variables = {
        "vsphere_endpoint": config['vsphere']['endpoint'],
        "vsphere_insecure_connection": "true" if config['vsphere']['insecure_connection'] else "false",
        "vsphere_username": variables['vsphere']['username'],
        "vsphere_password": variables['vsphere']['password'],
        "datacenter": config['vsphere']['datacenter'],
        "compute_cluster": config['vsphere']['cluster'],
        "network": config['vsphere']['network'],
        "folder": config['vsphere']['folder'],
        "project_name": config['name'],
        "master_cpu": config['cluster']['master']['cpu'],
        "master_memory": config['cluster']['master']['memory'],
        "master_disk_size": config['cluster']['master']['disk_size'],
        "worker_cpu": config['cluster']['worker']['cpu'],
        "worker_memory": config['cluster']['worker']['memory'],
        "worker_disk_size": config['cluster']['worker']['disk_size'],
    }

    write_hcl('.nucleus/variables.tfvars', terraform_variables)


if __name__ == "__main__":
    config = read_yaml('main.nucleus.yml')
    variables = read_yaml('vars.nucleus.yml')

    packer()
    terraform()
