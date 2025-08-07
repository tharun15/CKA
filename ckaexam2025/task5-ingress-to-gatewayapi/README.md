# Migrate from Kubernetes Ingress to Gateway API

## Task Overview
In this task, you will migrate a web application from using traditional Kubernetes Ingress resources to the newer Gateway API. You'll create Gateway API resources that provide the same functionality as the previous Ingress configuration while maintaining secure HTTPS access.

**Note:** A TLS Secret with a certificate for example.com is already provided in the resources.yaml file (reused from task1).

## Setup Instructions

1. First, execute the setup script to create the namespace and install the Gateway API components:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `task5` and set it as your current working namespace
   - Install the Gateway API Custom Resource Definitions (CRDs)
   - Install Contour as a Gateway API implementation
   - Configure Contour with NodePort service type for external access

2. Apply the provided resources:
   ```bash
   kubectl apply -f resources.yaml
   ```
   This will create:
   - A TLS Secret with a certificate for example.com
   - A Deployment running an Nginx container
   - A ConfigMap with custom HTML content
   - A Service that exposes the Deployment within the cluster

3. Verify the resources are running:
   ```bash
   kubectl get pods
   kubectl get services
   ```

## Task Requirements

Your task is to migrate from Ingress to Gateway API resources. Instead of creating a single Ingress resource, you'll need to create three separate Gateway API resources.

Follow these steps to complete the task:

1. Create a GatewayClass resource (e.g., `gateway-class.yaml`):
   ```yaml
   apiVersion: gateway.networking.k8s.io/v1
   kind: GatewayClass
   metadata:
     name: contour-gateway-class
   spec:
     controllerName: bitnami.com/contour
   ```

2. Create a Gateway resource (e.g., `gateway.yaml`) with TLS configuration:
   ```yaml
   apiVersion: gateway.networking.k8s.io/v1
   kind: Gateway
   metadata:
     name: web-gateway
   spec:
     gatewayClassName: contour-gateway-class
     listeners:
     - name: https
       protocol: HTTPS
       port: 443
       tls:
         mode: Terminate
         certificateRefs:
         - name: nginx-tls-secret
       allowedRoutes:
         namespaces:
           from: Same
   ```

3. Create an HTTPRoute resource (e.g., `http-route.yaml`) to define the routing rules:
   ```yaml
   apiVersion: gateway.networking.k8s.io/v1
   kind: HTTPRoute
   metadata:
     name: web-app-route
   spec:
     parentRefs:
     - name: web-gateway
       kind: Gateway
     hostnames:
     - "example.com"
     rules:
     - matches:
       - path:
           type: PathPrefix
           value: /
       backendRefs:
       - name: web-app-service
         port: 80
   ```

4. Apply the Gateway API resources:
   ```bash
   kubectl apply -f gateway-class.yaml
   kubectl apply -f gateway.yaml
   kubectl apply -f http-route.yaml
   ```

5. Verify the Gateway API resources were created:
   ```bash
   kubectl get gatewayclass
   kubectl get gateway
   kubectl get httproute
   ```

6. Test the Gateway API configuration:
   ```bash
   # Get the Gateway NodePort
   NODE_PORT=$(kubectl get gateway web-gateway -o jsonpath='{.status.addresses[0].value}')
   
   # If using a local environment, you might need to add an entry to /etc/hosts
   # 127.0.0.1 example.com
   
   # Then access the application via the hostname:
   curl -k -H "Host: example.com" https://localhost:$NODE_PORT
   # Or use a web browser to navigate to https://example.com:$NODE_PORT
   
   # The -k flag is used to skip certificate validation when using self-signed certificates
   ```

## Success Criteria
- A GatewayClass named `contour-gateway-class` is created and registered
- A Gateway named `web-gateway` is created with proper TLS configuration
- An HTTPRoute named `web-app-route` is created that routes traffic to the web-app-service
- The web application is accessible via HTTPS using the example.com hostname
- The custom HTML content is displayed when accessing the application

## Troubleshooting
If you encounter issues, check:
- Gateway status: `kubectl describe gateway web-gateway`
- HTTPRoute status: `kubectl describe httproute web-app-route`
- Web app pod status: `kubectl describe pod <web-app-pod-name>`
- Service configuration: `kubectl describe service web-app-service`
- Contour controller logs: `kubectl logs -n task5 -l app.kubernetes.io/name=contour`

## Comparison with Ingress
| Ingress Feature | Gateway API Equivalent |
|----------------|------------------------|
| Ingress resource | Gateway + HTTPRoute resources |
| IngressClass | GatewayClass |
| annotations for customization | Structured fields in specs |
| TLS configuration (secretName) | certificateRefs in Gateway listener |
| pathType, path matching | HTTPRoute matches with types |
| host rules | hostnames in HTTPRoute |
| backend service | backendRefs in HTTPRoute |

## Note
The Gateway API is designed to be a more expressive, extensible, and role-oriented replacement for the Ingress API. By completing this migration, you're adopting a more modern approach to Kubernetes traffic routing that offers better multi-tenancy, enhanced security, and more powerful routing capabilities.
