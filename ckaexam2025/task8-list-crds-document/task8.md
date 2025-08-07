Task: List and Document cert-manager Custom Resource Definitions

Background:
Custom Resource Definitions (CRDs) extend the Kubernetes API, allowing you to define custom resources with their own schemas. cert-manager is a popular Kubernetes addon that uses CRDs to manage X.509 certificates and issuers. It introduces several CRDs like Certificate, Issuer, and ClusterIssuer, which are used to automate certificate management in Kubernetes.

Objective:
Verify the cert-manager application is deployed in the cluster, list all cert-manager CRDs, and extract documentation for a specific field in the Certificate custom resource.

Tasks:
1. Verify that cert-manager is deployed in the cluster
   - The cert-manager application should already be running in the cluster

2. Create a list of all cert-manager Custom Resource Definitions (CRDs)
   - Use kubectl's default output format (do not specify an output format)
   - Save the output to ~/resources.yaml

3. Extract documentation for the "subject" specification field
   - Extract documentation for the "subject" field in the Certificate custom resource
   - Save the output to ~/subject.yaml
   - You may use any output format that kubectl supports for this task

Resources:
The execute.sh script verifies that cert-manager is deployed in your cluster and provides instructions for completing the task. cert-manager introduces several CRDs for certificate management, and you'll need to identify these CRDs and extract specific documentation using kubectl commands.
