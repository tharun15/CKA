#!/bin/bash

# Display banner
echo "==================================================="
echo "  Preparing Linux System for Kubernetes with cri-dockerd"
echo "==================================================="

# Step 1: Verify the cri-dockerd package is available in the current directory
echo "Checking for cri-dockerd package..."
if [ ! -f "cri-dockerd_0.4.0.3-0.debian-bookworm_amd64.deb" ]; then
    echo "Downloading cri-dockerd v0.4.0 package..."
    wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.4.0/cri-dockerd_0.4.0.3-0.debian-bookworm_amd64.deb
fi

# Step 2: Install cri-dockerd package using dpkg
echo "Installing cri-dockerd package using dpkg..."
sudo dpkg -i cri-dockerd_0.4.0.3-0.debian-bookworm_amd64.deb
sudo apt-get update
sudo apt-get -f install -y

# Step 3: Enable and start the cri-docker service
echo "Setting up cri-docker service..."
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable cri-docker.socket
sudo systemctl start cri-docker.service
sudo systemctl start cri-docker.socket

# Step 4: Configure system parameters for Kubernetes
echo "Configuring system parameters for Kubernetes..."

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

# Step 5: Verify setup
echo "Verifying the setup..."
dpkg -l | grep cri-dockerd
systemctl status cri-docker.service --no-pager
sysctl net.bridge.bridge-nf-call-iptables net.ipv6.conf.all.forwarding net.ipv4.ip_forward net.netfilter.nf_conntrack_max
cat /etc/sysctl.d/k8s.conf

echo "System is now prepared for Kubernetes with cri-dockerd configured."
echo "All settings will persist across system restarts."
