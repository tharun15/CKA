# Migrate from Kubernetes Ingress to Gateway API

## Task Overview
In this task, you will migrate a web application from using traditional Kubernetes Ingress resources to the newer Gateway API. You'll create Gateway API resources that provide the same functionality as the previous Ingress configuration while maintaining secure HTTPS access.

The Ingress resource is already configured with a Kubernetes FQDN hostname format (`web-app-service.task5.svc.cluster.local`). Your task is to migrate to Gateway API using a different hostname that starts with "gateway".

**Note:** A TLS Secret with a certificate for example.com is already provided in the resources.yaml file (reused from task1).

## Setup Instructions

1. First, execute the setup script to create the namespace and install the necessary components:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `task5` and set it as your current working namespace
   - Install the Gateway API Custom Resource Definitions (CRDs)
   - Install Nginx Ingress Controller for the Ingress resource
   - Install Nginx Gateway Fabric for the Gateway API resources
   - Configure both controllers with NodePort service type for external access

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

4. Test the Ingress resource:
   ```bash
   # Get the Ingress service IP or use the provided IP
   INGRESS_IP=$(kubectl get service nginx-ingress-ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')
   
   # Then access the application via the hostname:
   curl -k -H "Host: web-app-service.task5.svc.cluster.local" https://$INGRESS_IP
   
   # Or use a known IP address:
   # curl -k -H "Host: web-app-service.task5.svc.cluster.local" https://10.102.37.123
   
   # The -k flag is used to skip certificate validation when using self-signed certificates
   ```

## Task Requirements

Your task is to migrate from Ingress to Gateway API resources. The Ingress resource is already configured with a hostname of `web-app-service.task5.svc.cluster.local`. Instead of using a single Ingress resource, you'll need to create three separate Gateway API resources with a new hostname that starts with "gateway".

Follow these steps to complete the task:

1. Create a GatewayClass resource (e.g., `gateway-class.yaml`):
   ```yaml
   apiVersion: gateway.networking.k8s.io/v1
   kind: GatewayClass
   metadata:
     name: nginx
   spec:
     controllerName: "nginx.org/gateway-fabric"
   ```

2. Create a Gateway resource (e.g., `gateway.yaml`) with TLS configuration:
   ```yaml
   apiVersion: gateway.networking.k8s.io/v1
   kind: Gateway
   metadata:
     name: web-gateway
   spec:
     gatewayClassName: nginx
     listeners:
     - name: https
       protocol: HTTPS
       port: 443
       hostname: gateway.task5.svc.cluster.local  # New hostname starting with "gateway"
       tls:
         mode: Terminate
         certificateRefs:
         - name: nginx-tls-secret
     - name: http
       protocol: HTTP
       port: 80
       hostname: gateway.task5.svc.cluster.local  # New hostname starting with "gateway"
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
     - "gateway.task5.svc.cluster.local"  # New hostname starting with "gateway"
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
   
   # Then access the application via the hostname:
   curl -k -H "Host: gateway.task5.svc.cluster.local" https://localhost:$NODE_PORT
   
   # The -k flag is used to skip certificate validation when using self-signed certificates
   
   # Alternatively, you can use these specific commands:
   # First, get the correct NodePort numbers:
   kubectl get svc -n nginx-gateway
   
   # For HTTP (replace 30626 with the actual HTTP NodePort):
   curl -H "Host: gateway.task5.svc.cluster.local" http://localhost:30626
   
   # For HTTPS (replace 31775 with the actual HTTPS NodePort):
   curl -k --resolve gateway.task5.svc.cluster.local:31775:127.0.0.1 https://gateway.task5.svc.cluster.local:31775
   ```

7. Once you've verified that the Gateway API configuration is working correctly, delete the Ingress resource to complete the migration:
   ```bash
   kubectl delete ingress web-app-ingress
   ```

## Success Criteria
- A GatewayClass named `nginx-gateway-class` is created and registered
- A Gateway named `web-gateway` is created with proper TLS configuration
- An HTTPRoute named `web-app-route` is created that routes traffic to the web-app-service
- The web application is accessible via HTTPS using the gateway.task5.svc.cluster.local hostname
- The custom HTML content is displayed when accessing the application
- The original Ingress resource is deleted after confirming Gateway API is working properly

## Troubleshooting
If you encounter issues, check:
- Gateway status: `kubectl describe gateway web-gateway`
- HTTPRoute status: `kubectl describe httproute web-app-route`
- Web app pod status: `kubectl describe pod <web-app-pod-name>`
- Service configuration: `kubectl describe service web-app-service`
- Nginx Ingress Controller logs: `kubectl logs -n task5 -l app.kubernetes.io/name=nginx-ingress-controller`
- Nginx Gateway Fabric logs: `kubectl logs -n task5 -l app.kubernetes.io/name=nginx-gateway-fabric`

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
| Hostname: web-app-service.task5.svc.cluster.local | Hostname: gateway.task5.svc.cluster.local |
| Nginx Ingress Controller | Nginx Gateway Fabric |

## Note
The Gateway API is designed to be a more expressive, extensible, and role-oriented replacement for the Ingress API. By completing this migration, you're adopting a more modern approach to Kubernetes traffic routing that offers better multi-tenancy, enhanced security, and more powerful routing capabilities.
