#!/bin/bash

# Create the namespace
kubectl create namespace task4

# Set the namespace as the current context
kubectl config set-context --current --namespace=task4

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:

# Install Nginx Ingress Controller using Helm
echo "Installing Nginx Ingress Controller..."

# Add the nginx-ingress Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install the Nginx Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace task4 \
  --set controller.replicaCount=1 \
  --set controller.service.type=NodePort

# Wait for the Ingress Controller to be ready
echo "Waiting for Nginx Ingress Controller to be ready..."
kubectl wait --namespace task4 \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "Nginx Ingress Controller has been installed successfully!"
