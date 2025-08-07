#!/bin/bash

# Create the namespace
kubectl create namespace task7

# Set the namespace as the current context
kubectl config set-context --current --namespace=task7

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:

# Check if there are any existing default StorageClasses
echo "Checking for existing default StorageClasses..."
DEFAULT_SC=$(kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')

if [ -n "$DEFAULT_SC" ]; then
  echo "Found existing default StorageClass: $DEFAULT_SC"
  echo "Note: You may need to remove the default status from this StorageClass as part of the task."
else
  echo "No default StorageClass found."
fi

# List all available StorageClasses
echo "Available StorageClasses:"
kubectl get storageclass

# Apply the StorageClass from resources.yaml
echo "Creating the low-latency StorageClass..."
kubectl apply -f resources.yaml

# Check if there's an existing default StorageClass and remove its default status
if [ -n "$DEFAULT_SC" ]; then
  echo "Removing default status from existing StorageClass: $DEFAULT_SC"
  kubectl patch storageclass $DEFAULT_SC -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
fi

# Make the low-latency StorageClass the default
echo "Setting low-latency as the default StorageClass..."
kubectl patch storageclass low-latency -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Verify the change
echo "Verifying the default StorageClass:"
kubectl get storageclass

echo "The low-latency StorageClass has been created and set as the default."
