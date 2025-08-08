# Migration from Ingress to Gateway API

## Current Configuration

You have a web application running in Kubernetes with the following components:
- A Deployment running Nginx
- A ConfigMap with HTML content
- A ClusterIP Service exposing the application
- A TLS Secret with a certificate for example.com
- An Ingress resource that routes traffic to the service using a Kubernetes FQDN hostname format (`web-app-service.task5.svc.cluster.local`)

## Gateway API Migration Task

Your task is to migrate the current Ingress-based configuration to use the Gateway API. The Gateway API provides more advanced routing capabilities, better security controls, and a more expressive configuration model.

### Required Steps:

1. Create a `GatewayClass` resource that defines the Nginx Gateway implementation
2. Create a `Gateway` resource that defines the actual listener for incoming traffic
3. Create an `HTTPRoute` resource that defines how HTTP traffic is routed to the Kubernetes service

### Requirements:

- Use the Nginx Gateway implementation
- Configure TLS termination using the existing `nginx-tls-secret`
- The Gateway API resources should use a different hostname that starts with "gateway" (unlike the Ingress hostname)
- Ensure traffic is properly routed to the `web-app-service` on port 80

## Example Gateway API Resources

Here's a template for the Gateway API resources you need to create with the appropriate hostname format:

```yaml
# 1. GatewayClass - Defines the type of Gateway implementation to use
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-gateway-class
spec:
  controllerName: "nginx.org/gateway-controller"

---
# 2. Gateway - Defines the actual listener for incoming traffic
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-app-gateway
spec:
  gatewayClassName: nginx-gateway-class
  listeners:
  - name: https-listener
    protocol: HTTPS
    port: 443
    hostname: gateway.task5.svc.cluster.local  # New hostname starting with "gateway"
    tls:
      mode: Terminate
      certificateRefs:
      - name: nginx-tls-secret

---
# 3. HTTPRoute - Defines how HTTP traffic is routed to Kubernetes services
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-app-route
spec:
  parentRefs:
  - name: web-app-gateway
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
      kind: Service
      port: 80
```

## Testing the Migration

After applying the Gateway API resources, you should be able to access the application using the new hostname configuration. The execute.sh script installs Nginx Gateway Controller (a Gateway API implementation) configured for NodePort access, alongside the Nginx Ingress Controller for the Ingress resource.

## Completing the Migration

Once you've verified that the Gateway API resources are working correctly, you should delete the Ingress resource to complete the migration:

```bash
kubectl delete ingress web-app-ingress
```

This finalizes the migration process by removing the old Ingress resource, leaving only the Gateway API resources to handle incoming traffic.
