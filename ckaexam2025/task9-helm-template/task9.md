Task: Install Argo CD in Kubernetes Using Helm

Background:
Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. It automates the deployment of applications to specified target environments, following the GitOps principles where the desired application state is versioned in Git. Helm is a package manager for Kubernetes that helps you manage Kubernetes applications through Helm Charts, which are packages of pre-configured Kubernetes resources.

Objective:
Install Argo CD in a Kubernetes cluster using Helm, generate a Helm template of the Argo CD chart, and configure it not to install CRDs since they will be pre-installed by the setup script.

Tasks:
1. Add the official Argo CD Helm repository with the name "argo"
   - The Argo CD Helm repository URL is https://argoproj.github.io/argo-helm

2. Generate a Helm template of the Argo CD Helm chart:
   - Use version 7.7.3 of the Argo CD chart
   - Generate the template for the argocd namespace
   - Configure the chart to not install CRDs
   - Save the template to /argo-helm.yaml

3. Install Argo CD using Helm:
   - Use the release name "argocd"
   - Install version 7.7.3 (same as the template)
   - Install in the argocd namespace
   - Configure it to not install CRDs

Resources:
The execute.sh script is provided to prepare the environment for this task. It creates the argocd namespace and pre-installs the Argo CD CRDs in the cluster. You need to complete the remaining steps to add the Helm repository, generate the template, and install Argo CD.

Note: You do not need to configure access to the Argo CD server UI as part of this task.
