Task: Prepare Linux System for Kubernetes with cri-dockerd

Background:
Kubernetes requires a container runtime to function properly. While Docker is installed on the system, additional configuration is needed to make it work with kubeadm. The cri-dockerd adapter provides an interface between Docker and Kubernetes, allowing Docker to be used as the container runtime.

Objective:
Install and configure cri-dockerd package on a Linux system and set up required system parameters to prepare the system for Kubernetes installation.

Tasks:
1. Set up cri-dockerd:
   - Install the Debian package ~/cri-dockerd_0.3.18-0.ubuntu-jammy_amd64.deb using dpkg

2. Enable and start the cri-docker service:
   - Configure the service to start automatically at boot
   - Start the service immediately

3. Configure these system parameters:
   - Set net.bridge.bridge-nf-call-iptables to 1
   - Set net.ipv6.conf.all.forwarding to 1
   - Set net.ipv4.ip_forward to 1
   - Set net.netfilter.nf_conntrack_max to 131072

4. Ensure all configurations persist across system restarts:
   - Create proper configuration files
   - Enable module loading at boot time

Resources:
The execute.sh script is provided which checks the system prerequisites, verifies Docker is installed, and displays system information. You will need to modify this script to complete the required tasks.

Note: Docker is already installed on the system, as verified by the execute.sh script. You only need to configure cri-dockerd and the system parameters.
