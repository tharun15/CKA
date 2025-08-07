#!/bin/bash

# Display banner
echo "==================================================="
echo "  Installing Calico CNI for Kubernetes"
echo "==================================================="

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it before proceeding."
    exit 1
fi

echo "Task Instructions:"
echo "-----------------"
echo "Complete the following tasks to install Calico CNI:"
echo ""
echo "1. Install the Tigera Operator:"
echo "   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml"
echo ""
echo "2. Install Calico by creating the necessary custom resources:"
echo "   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/custom-resources.yaml"
echo ""
echo "3. Monitor the deployment:"
echo "   watch kubectl get tigerastatus"
echo ""
echo "4. Verify Calico pods are running:"
echo "   kubectl get pods -n calico-system"
echo ""
echo "The environment is ready for you to complete the task."
