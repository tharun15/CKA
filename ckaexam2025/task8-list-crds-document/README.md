# List and Document cert-manager CRDs

## Task Overview
In this task, you will work with Custom Resource Definitions (CRDs) from cert-manager, which is already deployed in your Kubernetes cluster. You'll list all cert-manager CRDs and extract documentation for a specific field in the Certificate custom resource.

## Setup Instructions

1. First, execute the setup script to prepare the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will verify that cert-manager is deployed in your cluster and provide instructions for completing the task.

## Task Requirements

You need to complete the following tasks:

1. Create a list of all cert-manager Custom Resource Definitions (CRDs):
   - Use kubectl's default output format (do not specify an output format)
   - Save the output to ~/resources.yaml

2. Extract documentation for the "subject" specification field of the Certificate Custom Resource:
   - Extract documentation for this specific field
   - Save the output to ~/subject.yaml
   - You may use any output format that kubectl supports for this part

## Implementation Steps

1. List all cert-manager CRDs:
   ```bash
   # Find all CRDs related to cert-manager
   kubectl get crds -l app.kubernetes.io/name=cert-manager > ~/resources.yaml
   
   # Alternatively, you can filter by name pattern
   kubectl get crds | grep cert-manager > ~/resources.yaml
   ```

2. Extract documentation for the "subject" field:
   ```bash
   kubectl explain certificate.spec.subject > ~/subject.yaml
   ```

## Success Criteria
- The file ~/resources.yaml contains a list of all cert-manager CRDs in the default kubectl output format
- The file ~/subject.yaml contains documentation for the "subject" specification field of the Certificate custom resource

## Verification
You can verify the successful completion of the task with these commands:

1. Check if the resources file was created:
   ```bash
   cat ~/resources.yaml
   ```
   Verify that it contains a list of cert-manager CRDs.

2. Check if the subject documentation was extracted:
   ```bash
   cat ~/subject.yaml
   ```
   Verify that it contains documentation about the "subject" field.

## Troubleshooting
If you encounter issues, check:
- Ensure cert-manager is actually deployed in your cluster
- Verify the correct labels or name patterns to filter cert-manager CRDs
- Check if the Certificate custom resource exists and has a subject field in its spec
- Make sure you're using the correct kubectl syntax for the `explain` command
