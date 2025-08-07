#!/bin/bash

# Display banner
echo "==================================================="
echo "  Setting up environment for Argo CD Installation"
echo "==================================================="

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Please install it before proceeding."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it before proceeding."
    exit 1
fi

# Create argocd namespace if it doesn't exist
echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Pre-install Argo CD CRDs
echo "Pre-installing Argo CD CRDs..."
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.7.7/manifests/crds/application-crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.7.7/manifests/crds/applicationset-crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.7.7/manifests/crds/appproject-crd.yaml

echo "Argo CD CRDs have been pre-installed in the cluster."
echo ""
echo "Task Instructions:"
echo "-----------------"
echo "Complete the following tasks:"
echo ""
echo "1. Add the official Argo CD Helm repository with the name 'argo'"
echo "   Repository URL: https://argoproj.github.io/argo-helm"
echo ""
echo "2. Generate a Helm template of the Argo CD chart version 7.7.3"
echo "   - Configure for the argocd namespace"
echo "   - Configure to NOT install CRDs (they are already installed)"
echo "   - Save the template to /argo-helm.yaml"
echo ""
echo "3. Install Argo CD using Helm"
echo "   - Use release name 'argocd'"
echo "   - Use version 7.7.3"
echo "   - Install in the argocd namespace"
echo "   - Configure to NOT install CRDs"
echo ""
echo "Example commands (uncomment and modify as needed):"
echo ""
echo "# Add the Argo CD Helm repository"
echo "# helm repo add argo https://argoproj.github.io/argo-helm"
echo "# helm repo update"
echo ""
echo "# Generate Helm template"
echo "# helm template argocd argo/argo-cd --version 7.7.3 \\"
echo "#   --namespace argocd \\"
echo "#   --set crds.install=false > /argo-helm.yaml"
echo ""
echo "# Install Argo CD"
echo "# helm install argocd argo/argo-cd --version 7.7.3 \\"
echo "#   --namespace argocd \\"
echo "#   --set crds.install=false"
echo ""
echo "# Verify the installation"
echo "# kubectl get pods -n argocd"
echo "# kubectl get svc -n argocd"
echo ""
echo "The environment is ready for you to complete the task."
