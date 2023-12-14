# AlmaLinux OS 8 Minimal Installation for vSphere
#version=RHEL8

# Basic Configuration
text
eula --agreed
lang en_US
keyboard us
timezone UTC

# Network Setup
network --bootproto=dhcp --device=eth0 --onboot=on --ipv6=auto --activate

# User Configuration
rootpw --lock
user --name=${build_username} --groups=wheel

# System Security
firewall --enabled --ssh
authselect select sssd
selinux --enforcing

# Disk Setup
zerombr
clearpart --all --initlabel
part /boot --fstype=xfs --size=512
part /boot/efi --fstype=efi --size=200 --fsoptions="umask=0077"
part swap --fstype=swap --size=2048
part / --fstype=xfs --grow --size=1

# Bootloader Configuration
bootloader --location=mbr

# Service Configuration
services --enabled=NetworkManager,sshd

# Skip X Window System installation
skipx

# Package Installation
%packages --ignoremissing --excludedocs
@^minimal-environment
%end

# Post-Installation Setup
%post
dnf makecache
dnf install -y epel-release
dnf makecache
dnf install -y sudo open-vm-tools perl cloud-init
systemctl enable vmtoolsd

# Configure sudoers for the user without password authentication
echo "${build_username} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${build_username}
chmod 0440 /etc/sudoers.d/${build_username}

# Setup SSH key authentication for the user
mkdir -m0700 /home/${build_username}/.ssh/
echo "${build_ssh_key}" > /home/${build_username}/.ssh/authorized_keys
chmod 0600 /home/${build_username}/.ssh/authorized_keys
chown -R ${build_username}:${build_username} /home/${build_username}/.ssh/
restorecon -Rv /home/${build_username}/.ssh/

# Harden SSH configuration
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers
%end

# Finalization
reboot --eject
