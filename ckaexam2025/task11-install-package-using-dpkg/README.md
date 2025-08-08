# Prepare Linux System for Kubernetes with cri-dockerd

## Task Overview
In this task, you will prepare a Linux system for Kubernetes by installing and configuring cri-dockerd. Docker is already installed, but you need to configure it for kubeadm by installing the cri-dockerd package and setting up essential system parameters.

## Setup Instructions

1. First, execute the setup script to prepare the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will check if Docker is installed, display system information, and set up the environment for installing packages using dpkg.

## Task Requirements

You need to complete the following tasks to prepare the system for Kubernetes:

1. Set up cri-dockerd:
   - Use the provided Debian package cri-dockerd_0.4.0.3-0.debian-bookworm_amd64.deb
   - Install the package using dpkg

2. Enable and start the cri-docker service:
   - Enable and start both cri-docker.service and cri-docker.socket

3. Configure system parameters with persistence across restarts:
   - Set net.bridge.bridge-nf-call-iptables to 1
   - Set net.ipv6.conf.all.forwarding to 1
   - Set net.ipv4.ip_forward to 1
   - Set net.netfilter.nf_conntrack_max to 131072
   - Ensure these settings persist even after system restarts

## Implementation Steps

1. The cri-dockerd package is already downloaded in the task directory. If not present, you can download it:
   ```bash
   wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.4.0/cri-dockerd_0.4.0.3-0.debian-bookworm_amd64.deb
   ```

2. Install the package using dpkg:
   ```bash
   sudo dpkg -i cri-dockerd_0.4.0.3-0.debian-bookworm_amd64.deb
   sudo apt-get update
   sudo apt-get -f install -y
   ```

3. Enable and start the cri-docker service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable cri-docker.service
   sudo systemctl enable cri-docker.socket
   sudo systemctl start cri-docker.service
   sudo systemctl start cri-docker.socket
   ```

4. Configure system parameters:
   ```bash
   # Create persistent sysctl config file
   sudo tee /etc/sysctl.d/k8s.conf > /dev/null << EOF
   # Kubernetes sysctl configuration - persists across system restarts
   net.bridge.bridge-nf-call-iptables = 1
   net.ipv6.conf.all.forwarding = 1
   net.ipv4.ip_forward = 1
   net.netfilter.nf_conntrack_max = 131072
   EOF

   # Ensure br_netfilter module is loaded
   sudo modprobe br_netfilter

   # Make br_netfilter load at boot time
   echo "br_netfilter" | sudo tee -a /etc/modules

   # Apply sysctl settings
   sudo sysctl --system
   ```

## Success Criteria
- cri-dockerd package is successfully installed
- cri-docker service is enabled and running
- System parameters are correctly configured:
  - net.bridge.bridge-nf-call-iptables = 1
  - net.ipv6.conf.all.forwarding = 1
  - net.ipv4.ip_forward = 1
  - net.netfilter.nf_conntrack_max = 131072
- All settings persist after system restart

## Verification
You can verify the installation and configuration with these commands:

1. Check if cri-dockerd is installed:
   ```bash
   dpkg -l | grep cri-dockerd
   ```

2. Check the cri-docker service status:
   ```bash
   systemctl status cri-docker.service
   ```

3. Verify system parameters:
   ```bash
   sysctl net.bridge.bridge-nf-call-iptables net.ipv6.conf.all.forwarding net.ipv4.ip_forward net.netfilter.nf_conntrack_max
   ```

4. Confirm persistence configuration:
   ```bash
   cat /etc/sysctl.d/k8s.conf
   ```

## Troubleshooting
If you encounter issues, check:
- Installation logs for any errors
- Service status using systemctl
- System parameters with sysctl
- Network module loading with lsmod
- Persistence configuration in /etc/sysctl.d/k8s.conf and /etc/modules
