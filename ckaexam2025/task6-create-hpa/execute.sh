#!/bin/bash

# Create the namespace
kubectl create namespace task6

# Set the namespace as the current context
kubectl config set-context --current --namespace=task6

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:

# Enable the metrics server if not already installed
echo "Checking if metrics-server is installed..."

# Check if metrics-server is already deployed
if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
  echo "Metrics Server is already installed."
else
  echo "Installing Metrics Server..."
  # Add the metrics-server Helm repository
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
  helm repo update

  # Install metrics-server
  helm install metrics-server metrics-server/metrics-server \
    --namespace kube-system \
    --set args="{--kubelet-insecure-tls}"

  # Wait for the metrics-server to be ready
  echo "Waiting for Metrics Server to be ready..."
  kubectl wait --namespace kube-system \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/name=metrics-server \
    --timeout=90s
  
  echo "Metrics Server has been installed successfully!"
fi

echo "The system is now ready for Horizontal Pod Autoscaling."
