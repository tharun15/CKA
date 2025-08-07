# Add a Sidecar Container for Log Processing

## Task Overview
In this task, you will add a sidecar container to an existing Kubernetes deployment. The sidecar container will process log files that are produced by the main application container, with both containers sharing a volume to access the same log files.

## Setup Instructions

1. First, execute the setup script to create the namespace and deploy the main application:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `task10` and set it as your current working namespace
   - Deploy the main application that writes logs to a file
   - Wait for the deployment to be ready

2. Verify that the main application is running:
   ```bash
   kubectl get pods
   ```
   You should see a pod with the main-container running.

3. Check the logs being written by the main container:
   ```bash
   POD_NAME=$(kubectl get pods -l app=main-app -o jsonpath='{.items[0].metadata.name}')
   kubectl exec $POD_NAME -- cat /var/log/app/app.log
   ```
   You should see log entries showing "Application running at [timestamp]".

## Task Requirements

Your task is to add a sidecar container to the existing deployment that processes the logs produced by the main application container.

The sidecar container should:
- Run in the same pod as the main container
- Mount the same volume as the main container at `/var/log/app`
- Read logs from `/var/log/app/app.log`
- Process the logs (add a prefix) and write them to `/var/log/app/processed.log`

Follow these steps to complete the task:

1. Create a new YAML file for the updated deployment (e.g., `updated-deployment.yaml`):
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: main-app
     labels:
       app: main-app
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: main-app
     template:
       metadata:
         labels:
           app: main-app
       spec:
         containers:
         - name: main-container
           image: busybox:latest
           command: ["sh", "-c", "while true; do echo \"Application running at $(date)\" >> /var/log/app/app.log; sleep 10; done"]
           env:
           - name: APP_ENV
             value: "production"
           - name: LOG_LEVEL
             value: "info"
           volumeMounts:
           - name: log-volume
             mountPath: /var/log/app
         - name: log-sidecar
           image: busybox:latest
           command: ["sh", "-c", "tail -F /var/log/app/app.log | while read line; do echo \"[Sidecar] $line\" >> /var/log/app/processed.log; done"]
           volumeMounts:
           - name: log-volume
             mountPath: /var/log/app
         volumes:
         - name: log-volume
           emptyDir: {}
   ```

2. Apply the updated deployment:
   ```bash
   kubectl apply -f updated-deployment.yaml
   ```

3. Wait for the updated deployment to roll out:
   ```bash
   kubectl rollout status deployment/main-app
   ```

## Verifying the Solution

To verify that your sidecar container is working properly:

1. Get the name of the pod:
   ```bash
   POD_NAME=$(kubectl get pods -l app=main-app -o jsonpath='{.items[0].metadata.name}')
   ```

2. Check that both containers are running in the pod:
   ```bash
   kubectl get pod $POD_NAME -o jsonpath='{.spec.containers[*].name}'
   ```
   You should see both `main-container` and `log-sidecar`.

3. View the original logs from the main container:
   ```bash
   kubectl exec $POD_NAME -c main-container -- cat /var/log/app/app.log
   ```

4. View the processed logs created by the sidecar container:
   ```bash
   kubectl exec $POD_NAME -c log-sidecar -- cat /var/log/app/processed.log
   ```
   You should see the same log entries, but with a `[Sidecar]` prefix added.

5. Watch the logs being processed in real-time:
   ```bash
   kubectl exec -it $POD_NAME -c log-sidecar -- tail -f /var/log/app/processed.log
   ```
   Press Ctrl+C to exit when done.

## Success Criteria
- The deployment has two containers: main-container and log-sidecar
- Both containers are running in the same pod
- Both containers have access to the shared volume at /var/log/app
- The main container continues to write logs to app.log
- The sidecar container reads from app.log and writes processed logs to processed.log
- The processed logs include the added prefix

## Troubleshooting
If you encounter issues, check:
- Pod status: `kubectl describe pod $POD_NAME`
- Sidecar container logs: `kubectl logs $POD_NAME -c log-sidecar`
- Main container logs: `kubectl logs $POD_NAME -c main-container`
- Volume mounts: `kubectl describe pod $POD_NAME | grep -A 5 Mounts:`
- Check if the log file exists: `kubectl exec $POD_NAME -c main-container -- ls -la /var/log/app/`

## Understanding the Sidecar Pattern

The sidecar pattern is a design pattern where a helper container is added to a pod to enhance or extend the functionality of the main container. Key advantages include:

1. **Separation of Concerns**: The main container focuses solely on its primary task, while the sidecar handles auxiliary functionality.

2. **Modularity**: Sidecar containers can be developed, tested, and deployed independently of the main application.

3. **Reusability**: The same sidecar container can be used with different main applications.

4. **Resource Sharing**: Containers in a pod share the same network, IPC, and can share volumes, making communication efficient.

Common use cases for sidecar containers include:
- Log collection and forwarding
- Monitoring and metrics collection
- Proxy servers or API gateways
- Data synchronization
- Configuration updaters

In this task, the sidecar demonstrates the log processing use case, where it:
1. Reads logs from the main application
2. Processes them (adds a prefix)
3. Writes the processed logs to a different file in the shared volume

This approach ensures that the main application doesn't need to be modified to add log processing functionality.
