# Expose Nginx via NodePort Service

## Task Overview
In this task, you will expose an Nginx web server using a NodePort service, making it accessible from outside the Kubernetes cluster.

## Setup Instructions

1. First, execute the setup script to create and set the namespace:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will create a namespace called `task2` and set it as your current working namespace.

2. Apply the provided resources:
   ```bash
   kubectl apply -f resources.yaml
   ```
   This will create an Nginx deployment.

## Task Requirements

Your task is to create a NodePort service that exposes the Nginx deployment to make it accessible from outside the cluster.

Follow these steps to complete the task:

1. Create a NodePort service that targets the Nginx deployment:
   ```bash
   # Option 1: Create the service using a YAML file
   # Create a file named nginx-nodeport.yaml with the service definition
   # Then apply it with: kubectl apply -f nginx-nodeport.yaml
   
   # Option 2: Create the service using kubectl expose command
   kubectl expose deployment nginx-web --type=NodePort --port=80 --name=nginx-service
   ```

2. Verify the service was created correctly:
   ```bash
   kubectl get service nginx-service
   ```
   Note the assigned NodePort (a port in the 30000-32767 range).

3. Access the Nginx web server:
   ```bash
   # Get the node's IP address
   kubectl get nodes -o wide
   
   # Access Nginx using curl or a web browser
   curl http://<node-ip>:<node-port>
   ```

## Success Criteria
- A NodePort service named `nginx-service` is created and running
- The service correctly targets the Nginx deployment with label `app: nginx`
- The Nginx web server is accessible from outside the cluster using the node's IP and assigned NodePort

## Troubleshooting
If you encounter issues, check:
- The Nginx pod status: `kubectl get pods`
- The service configuration: `kubectl describe service nginx-service`
- Make sure the service selector matches the pod labels: `kubectl get pods --show-labels`
- Check if the node port is accessible (firewall settings, etc.)
