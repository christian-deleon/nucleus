#!/bin/bash

set -e


WORK_DIR="/root"
NUCLEUS_DIR="${WORK_DIR}/nucleus"
NUCLEUS_DATA_DIR="${WORK_DIR}/nucleus-data"
NUCLUES_DOT_DIR="${NUCLEUS_DATA_DIR}/.nucleus"
MAIN_NUCLEUS_FILE="${NUCLEUS_DATA_DIR}/main.nucleus.yml"
PROJECT_NAME=$(yq ".name" $MAIN_NUCLEUS_FILE)
VMWARE_HOST=$(yq ".vsphere.endpoint" $MAIN_NUCLEUS_FILE)
VAR_NUCLEUS_FILE="${NUCLEUS_DATA_DIR}/vars.nucleus.yml"
VMWARE_USER=$(yq ".vsphere.username" $VAR_NUCLEUS_FILE)
VMWARE_PASSWORD=$(yq ".vsphere.password" $VAR_NUCLEUS_FILE)


# Function to apply Nucleus
apply_nucleus() {
    echo 
    echo "Would you like to build the Nucleus images? (y/n)"
    echo "Note: If you have already built the images, you can skip this step."
    read -r build_images
    if [ "$build_images" == "y" ]; then
        echo "Building Nuclues images..."
        run_packer build
    fi

    echo 
    echo "Provisioning Virtual Machines..."
    run_terraform apply
    
    echo 
    echo "Deploying RKE2..."
    echo
    run_ansible configure-k8s.yml
}


# Terraform commands
run_terraform() {
    # Check if the first argument is "apply" or "destroy"
    if [ "$1" != "apply" ] && [ "$1" != "destroy" ]; then
        echo "Unsupported Terraform command: $1"
        exit 1
    fi

    # Change to the Terraform directory
    cd $WORK_DIR/terraform

    # Set your variables
    BUCKET="cdeleon-terraform-state"
    KEY="${PROJECT_NAME}/terraform.tfstate"
    REGION="us-east-1"

    # Replace placeholders in the template
    sed -e "s|\${bucket}|$BUCKET|" \
        -e "s|\${key}|$KEY|" \
        -e "s|\${region}|$REGION|" \
        backend.tf.template > backend.tf

    terraform init

    # Execute Terraform with all passed arguments
    terraform "$@" \
        -auto-approve \
        -var-file=$NUCLUES_DOT_DIR/variables.tfvars \
        -state=$NUCLUES_DOT_DIR/terraform.tfstate
}


# Packer commands
run_packer() {
    # Change to the Packer directory
    cd $WORK_DIR/packer

    # Execute Packer with all passed arguments
    packer "$@" \
        -force \
        -var-file=$NUCLUES_DOT_DIR/variables.pkrvars.hcl \
        -only=vsphere-iso.nucleus .
}


# Ansible commands
run_ansible() {
    # Change to the Ansible directory
    ANSIBLE_DIR="$WORK_DIR/ansible"
    cd $ANSIBLE_DIR

    # Replace variables in the inventory file
    INVENTORY_FILE="${ANSIBLE_DIR}/hosts/vmware.yml"
    sed -i "s/HOSTNAME/$VMWARE_HOST/" $INVENTORY_FILE
    sed -i "s/USERNAME/$VMWARE_USER/" $INVENTORY_FILE
    sed -i "s/PASSWORD/$VMWARE_PASSWORD/" $INVENTORY_FILE
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/" $INVENTORY_FILE

    # Execute Ansible with all passed arguments
    ansible-playbook "$@" --private-key=~/.ssh/$PROJECT_NAME
}


# Check if NUCLUES_DOT_DIR exists
if [ ! -d "$NUCLUES_DOT_DIR" ]; then
    mkdir -p $NUCLUES_DOT_DIR
fi


# Parse Config Files
python $NUCLEUS_DIR/config_parser.py


# Main command handling
case "$1" in
    apply)
        shift
        apply_nucleus
        ;;
    destroy)
        shift
        run_terraform destroy
        ;;
    terraform)
        shift
        run_terraform "$@"
        ;;
    packer)
        shift
        run_packer "$@"
        ;;
    ansible)
        shift
        run_ansible "$@"
        ;;
    *)
        # Check for configuration files only if not running init
        if [ ! -f $NUCLEUS_DATA_DIR/template.main.nucleus.yml ] || [ ! -f $NUCLEUS_DATA_DIR/template.vars.nucleus.yml ]; then
            echo "Configuration file main.nucleus.yml or sensitive.vars.nucleus not found."
            echo "Would you like to create them now? (y/n)"
            read -r create_config
            if [ "$create_config" == "y" ]; then
                initialize_nucleus
            else
                exit 1
            fi
        fi

        if [ "$1" == "-h" ] || [ -z "$1" ]; then
            echo "Show help message here..."
        else
            echo "Unsupported command: $1"
        fi
        ;;
esac
