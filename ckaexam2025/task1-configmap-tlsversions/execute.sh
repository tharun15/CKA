#!/bin/bash

# Create the namespace
kubectl create namespace task1

# Set the namespace as the current context
kubectl config set-context --current --namespace=task1

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace: