Task: Troubleshoot Kubernetes Control Plane Components

Background:
The Kubernetes control plane consists of several critical components that manage the overall state of the cluster. The key components include:
- kube-apiserver: The API server that exposes the Kubernetes API and serves as the front-end for the control plane
- kube-scheduler: Responsible for assigning newly created pods to nodes in the cluster
- kubelet: An agent that runs on each node and ensures containers are running in a pod
- etcd: A consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data

When any of these components fail or are misconfigured, the cluster can experience significant issues that prevent normal operation. Troubleshooting these components requires understanding their configurations, logs, and interdependencies.

Objective:
Identify and fix several issues affecting the Kubernetes control plane components: kube-apiserver, kube-scheduler, and kubelet.

Tasks:
1. Fix the kube-apiserver etcd port configuration issue
   - The kube-apiserver is configured to connect to etcd on the wrong port (2380 instead of 2379)
   - Identify and correct the port configuration in the kube-apiserver manifest

2. Restart the stopped kubelet service
   - The kubelet service is stopped on node01
   - Restart the kubelet service to restore node functionality

3. Fix the kube-scheduler unknown flag error
   - The kube-scheduler is failing due to an invalid flag (--author)
   - Remove the invalid flag from the kube-scheduler configuration

4. Fix the kube-apiserver certificate path issue
   - The kube-apiserver is failing to start due to a missing certificate file
   - Create the necessary directory structure and symbolic link to resolve the certificate path issue

Resources:
The execute.sh script creates log files and configuration files that simulate the various control plane issues. These resources include:
- apiserver-port-error.log: Shows connection errors to etcd
- kubelet-stopped.log: Shows the kubelet service stopped status
- scheduler-flag-error.log: Shows the error due to an unknown flag
- apiserver-cert-error.log: Shows the certificate path error
- apiserver-config.yaml: The kube-apiserver configuration with the incorrect etcd port
- scheduler-config.yaml: The kube-scheduler configuration with the invalid flag

These resources will help you identify the issues and implement the appropriate fixes to restore the functionality of the Kubernetes control plane components.
