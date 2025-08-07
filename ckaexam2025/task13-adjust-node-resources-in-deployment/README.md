# Adjust Pod Resource Requests in a Deployment

## Task Overview
In this task, you will adjust resource requests in a Kubernetes deployment to ensure all pods can run successfully on a node with limited resources. The deployment is configured with resource requests and limits that allow only 2 of the 3 pods to run. Your job is to modify the resource settings to allow all 3 pods to run.

## Setup Instructions

1. First, execute the setup script to create and set the namespace:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will create a namespace called `task13`, set it as your current working namespace, and generate a deployment manifest based on the node's allocatable resources.

2. Apply the provided resources:
   ```bash
   kubectl apply -f resources.yaml
   ```
   This will create a deployment with 3 replicas, but due to the resource configurations, only 2 out of 3 pods will be able to run.

## Task Requirements

You need to adjust the resource requests in the deployment to ensure all 3 pods can run successfully on the node.

Follow these steps to complete the task:

1. Check the current status of the pods to confirm that only 2 out of 3 are running:
   ```bash
   kubectl get pods
   ```

2. Examine the resource settings in the current deployment:
   ```bash
   kubectl get deployment nginx -o yaml
   ```

3. Check the node's allocatable resources:
   ```bash
   kubectl describe node node01
   ```

4. Based on the node's capacity, calculate appropriate resource requests and limits for the pods:
   - Each pod should have a fair share of CPU and memory
   - The total resources requested by all pods should not exceed the node's capacity
   - Consider the resources needed for both the main container and the init container

5. Create an updated deployment YAML file with adjusted resource settings:
   ```bash
   kubectl get deployment nginx -o yaml > updated-deployment.yaml
   # Edit the file to adjust resource requests and limits
   ```

6. Apply the updated deployment:
   ```bash
   kubectl apply -f updated-deployment.yaml
   ```

## Resource Calculation Example

For a node with 4 CPU and 1234556Mi memory:

1. **Original settings (allowing only 2 pods to run)**:
   - 90% available for pods: 3.6 CPU and 1111100Mi memory
   - Per pod limits (for 2 pods): 1.8 CPU and 555550Mi memory
   - Per pod requests (50% of limits): 0.9 CPU and 277775Mi memory

2. **Adjusted settings (allowing all 3 pods to run)**:
   - 90% available for pods: 3.6 CPU and 1111100Mi memory
   - Per pod limits (for 3 pods): 1.2 CPU and 370367Mi memory
   - Per pod requests (adjusted accordingly): 0.6 CPU and 185183Mi memory

## Success Criteria
- All 3 pods should be in the Running state
- All pods should have resource requests that allow them to fit on the node
- The resource settings should be fair and balanced across all pods
- Both the main container and init container should have the same resource settings

## Verification
You can verify the successful completion of the task with these commands:

1. Check pod status:
   ```bash
   kubectl get pods
   ```
   All 3 pods should show as Running.

2. Verify resource settings:
   ```bash
   kubectl get deployment nginx -o yaml | grep -A 10 resources
   ```
   The resource requests and limits should be adjusted to allow all 3 pods to run.

## Troubleshooting
If you encounter issues, check:
- Pod status and events: `kubectl describe pods`
- Node resource usage: `kubectl describe node node01`
- Deployment events: `kubectl describe deployment nginx`
- Make sure your resource calculations account for both the main container and init container
