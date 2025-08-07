#!/bin/bash

# Create the namespace
kubectl create namespace task10

# Set the namespace as the current context
kubectl config set-context --current --namespace=task10

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:

# Apply the deployment without the sidecar container
echo "Creating the main application deployment..."
kubectl apply -f resources.yaml

# Wait for the deployment to be ready
echo "Waiting for the deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/main-app

echo "Main application has been deployed successfully."
echo "You can now add the sidecar container to process the logs."
