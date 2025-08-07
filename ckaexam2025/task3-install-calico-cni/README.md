# Install Calico CNI in Kubernetes

## Task Overview
In this task, you will install Calico, a Container Network Interface (CNI) solution for Kubernetes. Calico provides networking and network policy for Kubernetes clusters.

## Setup Instructions

1. First, execute the setup script to prepare the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will provide instructions for installing Calico CNI.

## Task Requirements

You need to complete the following tasks to install Calico CNI:

1. Install the Tigera Operator and custom resource definitions
2. Install Calico by creating the necessary custom resources
3. Monitor and verify the installation

## Implementation Steps

1. Install the Tigera Operator:
   ```bash
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml
   ```

2. Install Calico custom resources:
   ```bash
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/custom-resources.yaml
   ```

3. Monitor the deployment:
   ```bash
   watch kubectl get tigerastatus
   ```

4. Verify Calico pods are running:
   ```bash
   kubectl get pods -n calico-system
   ```

## Success Criteria
- Tigera Operator is installed successfully
- Calico custom resources are created
- All Calico components show as available (True in the AVAILABLE column)
- All Calico pods are running in the calico-system namespace

## Verification
You can verify the installation by checking:
- Calico components status: `kubectl get tigerastatus`
- Calico pods: `kubectl get pods -n calico-system`

## Troubleshooting
If you encounter issues, check:
- Operator logs: `kubectl logs -n tigera-operator deployment/tigera-operator`
- Component status: `kubectl get tigerastatus -o yaml`
- Events: `kubectl get events -n calico-system`
