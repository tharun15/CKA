# Secure Nginx with TLS 1.3 Only

## Task Overview
In this task, you will configure an Nginx web server to accept HTTPS connections using only TLS 1.3, rejecting any connections that attempt to use TLS 1.2 or older protocols.

## Setup Instructions

1. First, execute the setup script to create and set the namespace:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will create a namespace called `task1` and set it as your current working namespace.

2. Apply the provided resources:
   ```bash
   kubectl apply -f task1/resources.yaml
   ```
   This will create:
   - An Nginx ConfigMap
   - A TLS Secret
   - A Deployment running Nginx
   - A Service exposing the Nginx deployment

## Task Requirements

The current Nginx configuration allows both TLS 1.2 and TLS 1.3 connections. Your task is to modify the configuration to only allow TLS 1.3.

Follow these steps to complete the task:

1. Since the ConfigMap is marked as immutable, create a new ConfigMap with the updated configuration:
   ```bash
   # Extract the current ConfigMap content
   kubectl get configmap nginx-config -o yaml > new-config.yaml
   
   # Edit the file to:
   # 1. Change 'ssl_protocols TLSv1.2 TLSv1.3;' to 'ssl_protocols TLSv1.3;'
   # 2. Remove the resourceVersion, uid, creationTimestamp fields
   # 3. Give it a new name if needed
   
   # Apply the updated ConfigMap
   kubectl apply -f new-config.yaml
   ```

2. Update the Deployment to use the new ConfigMap:
   ```bash
   kubectl edit deployment nginx-https
   ```
   Update the volume definition to reference your new ConfigMap name if you changed it.

3. Alternatively, you can delete and recreate the Deployment:
   ```bash
   kubectl delete deployment nginx-https
   kubectl apply -f updated-deployment.yaml
   ```

4. Test the configuration:
   - Find the pod IP:
     ```bash
     kubectl get pods -o wide
     ```
   - Test TLS 1.3 (should work):
     ```bash
     curl -k -v --tlsv1.3 https://<pod-ip>:443
     ```
   - Test TLS 1.2 (should fail):
     ```bash
     curl -k -v --tlsv1.2 --tls-max 1.2 https://<pod-ip>:443
     ```

## Success Criteria
- The TLS 1.3 connection should successfully return the Nginx welcome page
- The TLS 1.2 connection should fail with a protocol version error
- The Nginx configuration should only specify `ssl_protocols TLSv1.3;`

## Troubleshooting
If you encounter issues, check:
- The Nginx configuration inside the pod: `kubectl exec <pod-name> -- cat /etc/nginx/nginx.conf`
- The Nginx logs: `kubectl logs <pod-name>`
- Pod status: `kubectl describe pod <pod-name>`