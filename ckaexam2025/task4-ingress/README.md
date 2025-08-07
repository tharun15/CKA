# Configure Secure Kubernetes Ingress for Web Application

## Task Overview
In this task, you will configure a Kubernetes Ingress resource with TLS to securely expose a web application to external traffic, making it accessible from outside the cluster via HTTPS with the example.com hostname.

**Note:** A TLS Secret with a certificate for example.com is already provided in the resources.yaml file (reused from task1).

## Setup Instructions

1. First, execute the setup script to create the namespace and install the Nginx Ingress Controller:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `task4` and set it as your current working namespace
   - Install the Nginx Ingress Controller using Helm
   - Configure the Ingress Controller with NodePort service type

2. Apply the provided resources:
   ```bash
   kubectl apply -f resources.yaml
   ```
   This will create:
   - A Deployment running an Nginx container
   - A ConfigMap with custom HTML content
   - A Service that exposes the Deployment within the cluster

3. Verify the resources are running:
   ```bash
   kubectl get pods
   kubectl get services
   ```

## Task Requirements

Your task is to create an Ingress resource that exposes the web application to external traffic.

Follow these steps to complete the task:

1. Create an Ingress resource file (e.g., `ingress.yaml`) with TLS configuration:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: web-app-ingress
     annotations:
       # Add any necessary annotations here depending on your Ingress controller
       # For example, for Nginx Ingress Controller:
       # nginx.ingress.kubernetes.io/rewrite-target: /
   spec:
     tls:
     - hosts:
       - example.com
       secretName: nginx-tls-secret
     rules:
     - host: example.com  # Use the hostname that matches the TLS certificate
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: web-app-service
               port:
                 number: 80
   ```

2. Apply the Ingress resource:
   ```bash
   kubectl apply -f ingress.yaml
   ```

3. Verify the Ingress resource was created:
   ```bash
   kubectl get ingress
   kubectl describe ingress web-app-ingress
   ```

4. Test the Ingress configuration:
   ```bash
   # If you're using a local environment, you might need to add an entry to /etc/hosts
   # 127.0.0.1 example.com
   
   # Then access the application via the hostname:
   curl -k -H "Host: example.com" https://<ingress-controller-ip>
   # Or use a web browser to navigate to https://example.com
   
   # The -k flag is used to skip certificate validation when using self-signed certificates
   ```

## Success Criteria
- An Ingress resource named `web-app-ingress` is created and running
- The Ingress resource correctly routes traffic to the web-app-service
- TLS is properly configured using the provided `nginx-tls-secret`
- The web application is accessible via HTTPS using the example.com hostname
- The custom HTML content is displayed when accessing the application

## Troubleshooting
If you encounter issues, check:
- Ingress controller status: `kubectl get pods -n <ingress-controller-namespace>`
- Ingress resource status: `kubectl describe ingress web-app-ingress`
- Web app pod status: `kubectl describe pod <web-app-pod-name>`
- Service configuration: `kubectl describe service web-app-service`
- Ingress controller logs: `kubectl logs -n <ingress-controller-namespace> <ingress-controller-pod-name>`

## Note
The execute.sh script will install the Nginx Ingress Controller in your cluster. If you already have an Ingress controller installed, you might need to adjust the Ingress resource configuration to match your existing controller.
