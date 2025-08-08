#!/bin/bash

# Create the namespace
kubectl create namespace task5

# Set the namespace as the current context
kubectl config set-context --current --namespace=task5

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:

# Install Gateway API CRDs
echo "Installing Gateway API CRDs..."

# Install the Gateway API CRDs directly from the official repository
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

echo "Gateway API CRDs have been installed."

# Install Nginx Ingress Controller (for the Ingress resource)
echo "Installing Nginx Ingress Controller..."

# Add the Nginx Ingress Controller Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install Nginx Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace task5 \
  --set controller.service.type=NodePort

# Wait for the Nginx Ingress Controller to be ready
echo "Waiting for Nginx Ingress Controller to be ready..."
kubectl wait --namespace task5 \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress \
  --timeout=120s

echo "Nginx Ingress Controller has been installed successfully!"

# Install Nginx Gateway Fabric (for the Gateway API resources)
echo "Installing Nginx Gateway Fabric..."

# Install Nginx Gateway Fabric using OCI registry
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --namespace task5 \
  --set service.type=NodePort

# Wait for the Nginx Gateway Fabric controller to be ready
echo "Waiting for Nginx Gateway Fabric controller to be ready..."
kubectl wait --namespace task5 \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=nginx-gateway-fabric \
  --timeout=120s

echo "Nginx Gateway Fabric has been installed successfully!"
echo ""
echo "The system is now ready for migrating from Ingress to Gateway API."
