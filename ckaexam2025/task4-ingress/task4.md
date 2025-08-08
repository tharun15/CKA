Task: Configure Secure Kubernetes Ingress with TLS
Background
In this task, you'll be setting up an Ingress resource with TLS to securely expose a web application to external traffic. Kubernetes Ingress is an API object that manages external access to services in a cluster, typically HTTP. Ingress can provide load balancing, SSL termination, and name-based virtual hosting.

Objective
Configure a Kubernetes Ingress resource with TLS to securely expose the provided Nginx web application, making it accessible from outside the cluster via HTTPS using the hostname example.com.

Resources
The Kubernetes resources are provided in the task4/resources.yaml file, which includes:
- A TLS Secret with a certificate for example.com (reused from task1)
- A Deployment running an Nginx container with HTTP (port 80) support
- A ConfigMap with custom HTML content
- A Service that exposes the Deployment within the cluster on port 80

Additionally, the execute.sh script will install the Nginx Ingress Controller using Helm to provide the necessary infrastructure for Ingress resources.

Task Challenge
Your challenge is to create an Ingress resource that:
1. Routes traffic to the web application via the example.com hostname
2. Configures TLS using the provided nginx-tls-secret to enable HTTPS access
3. Properly implements TLS termination at the Ingress controller level

The Ingress will handle TLS termination:
- Client → Ingress: HTTPS connection (port 443) with TLS encryption
- Ingress → Service → Pod: HTTP connection (port 80) inside the cluster
