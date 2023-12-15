#!/bin/bash

set -e

signature() {
    echo -e "\e[1;31m"
    echo "         _           _                  _            _            _     _                 _        "
    echo "        /\ \     _  /\_\              /\ \          _\ \         /\ \  /\_\              / /\      "
    echo "       /  \ \   /\_/ / /         _   /  \ \        /\__ \       /  \ \/ / /         _   / /  \     "
    echo "      / /\ \ \_/ / \ \ \__      /\_\/ /\ \ \      / /_ \_\     / /\ \ \ \ \__      /\_\/ / /\ \__  "
    echo "     / / /\ \___/ / \ \___\    / / / / /\ \ \    / / /\/_/    / / /\ \_\ \___\    / / / / /\ \___\ "
    echo "    / / /  \/____/   \__  /   / / / / /  \ \_\  / / /        / /_/_ \/_/\__  /   / / /\ \ \ \/___/ "
    echo "   / / /    / / /    / / /   / / / / /    \/_/ / / /        / /____/\   / / /   / / /  \ \ \       "
    echo "  / / /    / / /    / / /   / / / / /         / / / ____   / /\____\/  / / /   / / _    \ \ \      "
    echo " / / /    / / /    / / /___/ / / / /________ / /_/_/ ___/\/ / /______ / / /___/ / /_/\__/ / /      "
    echo "/ / /    / / /    / / /____\/ / / /_________/_______/\__\/ / /_______/ / /____\/ /\ \/___/ /       "
    echo "\/_/     \/_/     \/_________/\/____________\_______\/   \/__________\/_________/  \_____\/        "
    echo -e "\e[0m"
    echo "by Christian De Leon"
    echo "https://christiandeleon.me/"
    echo 
}

show_help_menu() {
    signature
    echo "Nucleus Command Usage:"
    echo "  nucleus init          - Initialize the Nucleus environment."
    echo "  nucleus apply         - Apply the Nucleus configuration."
    echo "  nucleus destroy       - Destroy the Nucleus configuration."
    echo "  nucleus -h            - Show this help menu."
    echo
    echo "Other Commands:"
    echo "  nucleus terraform [command]   - Run a Terraform command."
    echo "  nucleus packer [command]      - Run a Packer command."
    echo "  nucleus ansible [command]     - Run an Ansible command."
    echo 
}

# Function to install Podman on Ubuntu/Debian
install_podman_ubuntu() {
    sudo apt update
    sudo apt install -y podman
}

# Function to install Podman on Fedora
install_podman_fedora() {
    sudo dnf -y install podman
}

# Function to install Podman on CentOS/RHEL
install_podman_centos() {
    sudo yum -y install podman
}

# Function to install Podman
install_podman() {
    # Detect the OS
    OS_NAME=$(grep '^ID=' /etc/os-release | cut -d= -f2)

    # Call the appropriate installation function based on the OS
    case "$OS_NAME" in
        ubuntu|debian)
            install_podman_ubuntu
            ;;
        fedora)
            install_podman_fedora
            ;;
        centos|rhel)
            install_podman_centos
            ;;
        *)
            echo "Unsupported OS: $OS_NAME"
            exit 1
            ;;
    esac
}

# Function to get the Nucleus version
get_nucleus_version() {
    if [ -f main.nucleus.yml ]; then
        grep '^version:' main.nucleus.yml | cut -d' ' -f2 || echo "latest"
    else
        echo "latest"
    fi
}

# Show help menu if no arguments or -h is passed
if [ $# -eq 0 ] || [ "$1" == "-h" ]; then
    show_help_menu
    exit 0
fi

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    input "Podman is not installed. Would you like to install it? (y/n) " install_podman
fi

# Install Podman if user chooses to
if [ "$install_podman" == "y" ]; then
    echo "Installing Podman..."
    install_podman
    echo "Podman installed."
fi

# If init is passed, run the init command
if [ "$1" == "init" ]; then
    podman run --rm -it \
        -v "$(pwd)":/root/nucleus-data \
        -w /root/nucleus-data \
        --entrypoint /root/nucleus/init.sh \
        nucleus:latest
    exit 0
fi

PROJECT_NAME=$(grep '^name:' main.nucleus.yml | cut -d' ' -f2)

# Generate Nucleus Project SSH key if it doesn't exist
if [ ! -f ~/.ssh/"$PROJECT_NAME" ]; then
    echo "Generating Nucleus Project SSH key..."
    ssh-keygen -t rsa -b 4096 -C "$PROJECT_NAME" -f ~/.ssh/"$PROJECT_NAME" -q -N ""
    echo "Nucleus Project SSH key generated."
fi

# Get Nucleus version from main.nucleus.yml
NUCLEUS_VERSION=$(get_nucleus_version)

# Define Podman Image
NUCLEUS_IMAGE="nucleus:${NUCLEUS_VERSION}"

# Check if Nucleus image exists
if ! podman image exists "$NUCLEUS_IMAGE"; then
    echo "Pulling Nucleus Version $NUCLEUS_VERSION"
    if ! podman pull "$NUCLEUS_IMAGE" &> /dev/null; then
        echo "Error: Nucleus image not found or failed to pull. Please check Nucleus version in main.nucleus.yml or ensure network connectivity."
        exit 1
    fi
fi

# Create .kube directory if it doesn't exist
if [ ! -d ~/.kube ]; then
    mkdir ~/.kube
fi

# If command is exec, bash into the container
if [ "$1" == "exec" ]; then
    podman run --rm -it \
        --network host \
        -v "$(pwd)":/root/nucleus-data \
        -v ~/.ssh:/root/.ssh \
        -v ~/.kube:/root/.kube \
        -v ~/.aws:/root/.aws \
        --entrypoint /bin/bash \
        $NUCLEUS_IMAGE
    exit 0
fi

# Running the Podman Container with necessary mounts and arguments
podman run --rm -it \
    --network host \
    -v "$(pwd)":/root/nucleus-data \
    -v ~/.ssh:/root/.ssh \
    -v ~/.kube:/root/.kube \
    -v ~/.aws:/root/.aws \
    -w /root/nucleus-data \
    --entrypoint /root/nucleus/entrypoint.sh \
    $NUCLEUS_IMAGE "$@"
