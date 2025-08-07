#!/bin/bash

# Display banner
echo "==================================================="
echo "  List and Document cert-manager CRDs"
echo "==================================================="

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it before proceeding."
    exit 1
fi

# Verify cert-manager is deployed
echo "Verifying cert-manager deployment..."
if kubectl get deployment -A | grep -q cert-manager; then
    echo "✅ cert-manager is deployed in the cluster."
else
    echo "⚠️ cert-manager doesn't appear to be deployed. Please check your cluster."
fi

echo ""
echo "Task Instructions:"
echo "-----------------"
echo "Complete the following tasks:"
echo ""
echo "1. Create a list of all cert-manager Custom Resource Definitions (CRDs)"
echo "   and save it to ~/resources.yaml"
echo ""
echo "   Example command (use default output format):"
echo "   kubectl get crds -l app.kubernetes.io/name=cert-manager > ~/resources.yaml"
echo ""
echo "2. Extract the documentation for the 'subject' specification field"
echo "   of the Certificate Custom Resource and save it to ~/subject.yaml"
echo ""
echo "   Example command (you can use any output format that kubectl supports):"
echo "   kubectl explain certificate.spec.subject > ~/subject.yaml"
echo ""
echo "Important Notes:"
echo "- Use kubectl's default output format when listing CRDs"
echo "- Do not set an output format flag for the first task"
echo "- For the second task, you may use any output format that kubectl supports"
echo ""
echo "The environment is ready for you to complete the task."
