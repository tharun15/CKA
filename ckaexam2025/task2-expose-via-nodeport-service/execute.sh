#!/bin/bash

# Create the namespace
kubectl create namespace task2

# Set the namespace as the current context
kubectl config set-context --current --namespace=task2

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:
