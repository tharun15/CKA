# Install Argo CD in Kubernetes Using Helm

## Task Overview
In this task, you will install Argo CD in a Kubernetes cluster using Helm. You'll add the official Argo CD Helm repository, generate a Helm template for the Argo CD chart, and install Argo CD with specific configurations.

## Setup Instructions

1. First, execute the setup script to prepare the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will create the argocd namespace and pre-install the Argo CD CRDs, preparing the environment for you to complete the task.

## Task Requirements

You need to complete the following tasks to install Argo CD:

1. Add the official Argo CD Helm repository:
   - Repository URL: https://argoproj.github.io/argo-helm
   - Repository name: argo

2. Generate a Helm template of the Argo CD chart:
   - Use version 7.7.3 of the Argo CD chart
   - Configure for the argocd namespace
   - Configure the chart to not install CRDs (as they are already pre-installed)
   - Save the template to /argo-helm.yaml

3. Install Argo CD using Helm:
   - Use release name "argocd"
   - Use the same version (7.7.3) as in the template
   - Install in the argocd namespace
   - Configure it to not install CRDs

## Implementation Steps

1. Create the argocd namespace:
   ```bash
   kubectl create namespace argocd
   ```

2. Add the Argo CD Helm repository:
   ```bash
   helm repo add argo https://argoproj.github.io/argo-helm
   helm repo update
   ```

3. Generate the Helm template:
   ```bash
   helm template argocd argo/argo-cd --version 7.7.3 \
     --namespace argocd \
     --set crds.install=false > /argo-helm.yaml
   ```

4. Install Argo CD:
   ```bash
   helm install argocd argo/argo-cd --version 7.7.3 \
     --namespace argocd \
     --set crds.install=false
   ```

## Success Criteria
- The Argo CD Helm repository is added with the name "argo"
- A Helm template is generated for Argo CD version 7.7.3 and saved to /argo-helm.yaml
- Argo CD is installed in the argocd namespace with CRDs installation disabled
- All Argo CD pods are running successfully in the argocd namespace

## Verification
You can verify the installation with these commands:

1. Check if the Argo CD pods are running:
   ```bash
   kubectl get pods -n argocd
   ```

2. Check the Argo CD services:
   ```bash
   kubectl get svc -n argocd
   ```

3. Verify the template was generated:
   ```bash
   ls -la /argo-helm.yaml
   ```

## Troubleshooting
If you encounter issues, check:
- Helm repository list: `helm repo list`
- Helm installation status: `helm list -n argocd`
- Helm chart version availability: `helm search repo argo/argo-cd --versions`
- Kubernetes events: `kubectl get events -n argocd`
- Pod logs: `kubectl logs -n argocd <pod-name>`
- Make sure you have proper RBAC permissions to create resources in the argocd namespace
