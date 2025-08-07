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

# Install Contour (an implementation of Gateway API) using Helm
echo "Installing Contour Gateway Controller..."

# Add the Bitnami Helm repository (which contains Contour)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install Contour with Gateway API support enabled
helm install contour bitnami/contour \
  --namespace task5 \
  --set enableGatewayAPI=true \
  --set service.type=NodePort

# Wait for the Contour controller to be ready
echo "Waiting for Contour Gateway Controller to be ready..."
kubectl wait --namespace task5 \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=contour \
  --timeout=120s

echo "Contour Gateway Controller has been installed successfully!"
echo ""
echo "The system is now ready for migrating from Ingress to Gateway API."
