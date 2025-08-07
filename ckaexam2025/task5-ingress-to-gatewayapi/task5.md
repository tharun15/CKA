Task: Migrate from Kubernetes Ingress to Gateway API
Background
In this task, you'll be migrating from the traditional Kubernetes Ingress resource to the newer Gateway API. The Gateway API is the next generation of the Ingress API, providing more advanced routing capabilities, better security controls, and a more expressive configuration model. It represents a significant evolution in how Kubernetes exposes services to external traffic.

Objective
Migrate a web application from using Kubernetes Ingress to using Gateway API resources, while maintaining secure TLS access via HTTPS using the example.com hostname.

Resources
The Kubernetes resources are provided in the task5/resources.yaml file, which includes:
- A TLS Secret with a certificate for example.com (reused from task1)
- A Deployment running an Nginx container
- A ConfigMap with custom HTML content
- A Service that exposes the Deployment within the cluster

Additionally, the execute.sh script will install:
- The Gateway API Custom Resource Definitions (CRDs)
- Contour, an implementation of the Gateway API, configured for NodePort access

Key Gateway API Resources
Instead of a single Ingress resource, the Gateway API introduces a layered approach with:

1. GatewayClass - Defines the type of Gateway implementation to use (similar to StorageClass)
2. Gateway - Defines the actual listener for incoming traffic (IP, port, TLS settings)
3. HTTPRoute - Defines how HTTP traffic is routed to Kubernetes services

Benefits of Gateway API over Ingress:
- Better multi-tenant support
- Enhanced security model
- Improved traffic splitting and header manipulation
- More expressive routing capabilities
- Standardized way to configure TLS
