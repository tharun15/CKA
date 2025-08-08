#!/bin/bash

# Create the namespace
kubectl create namespace task5

# Set the namespace as the current context
kubectl config set-context --current --namespace=task5

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:

# Install Gateway API CRDs using Helm
echo "Installing Gateway API CRDs..."

# Add the Gateway API Helm repository
helm repo add gateway-api https://kubernetes-sigs.github.io/gateway-api
helm repo update

# Install the Gateway API CRDs
helm install gateway-api-crds gateway-api/gateway-api-crds

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

# Install Nginx Gateway Controller (for the Gateway API resources)
echo "Installing Nginx Gateway Controller..."

# Add the Nginx Gateway Helm repository
helm repo add nginx-gateway https://helm.nginx.com/gateway
helm repo update

# Install Nginx Gateway Controller
helm install nginx-gateway nginx-gateway/nginx-gateway \
  --namespace task5 \
  --set service.type=NodePort

# Wait for the Nginx Gateway Controller to be ready
echo "Waiting for Nginx Gateway Controller to be ready..."
kubectl wait --namespace task5 \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=nginx-gateway \
  --timeout=120s

echo "Nginx Gateway Controller has been installed successfully!"
echo ""
echo "The system is now ready for migrating from Ingress to Gateway API."
