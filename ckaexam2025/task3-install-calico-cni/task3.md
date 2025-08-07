Task: Install Calico CNI in Kubernetes

Background:
Container Network Interface (CNI) is a standard interface for configuring networking for Linux containers. Calico is a popular CNI solution that provides networking and network policy for Kubernetes clusters. It offers advanced networking features and security capabilities.

Objective:
Install Calico CNI in a Kubernetes cluster to provide networking and network policy capabilities.

Tasks:
1. Install the Tigera Operator and custom resource definitions
   - The Tigera Operator manages the lifecycle of Calico components

2. Install Calico by creating the necessary custom resources
   - These resources define the configuration for Calico installation

3. Monitor and verify the installation
   - Check that all components show as available
   - Ensure Calico pods are running correctly

Resources:
The execute.sh script is provided to guide you through the installation process. Calico v3.30.2 manifests are used in this task, which include the Tigera Operator and custom resources required for installation.
