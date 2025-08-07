#!/bin/bash

# Apply the resources needed for the task
echo "Setting up the environment for the priority class task..."

# Apply all resources at once
kubectl apply -f resources.yaml

echo "Waiting for deployments to be ready..."
# Wait for the deployments to be ready (or at least in a steady state)
kubectl -n priority wait --for=condition=Available=True --timeout=60s deployment/resource-consumer || true
kubectl -n priority wait --for=condition=Available=True --timeout=60s deployment/busybox-logger || true

# Show the current state of the cluster
echo ""
echo "Current deployments in the 'priority' namespace:"
kubectl -n priority get deployments

echo ""
echo "Current pods in the 'priority' namespace:"
kubectl -n priority get pods

echo ""
echo "Current priority classes:"
kubectl get priorityclasses

echo ""
echo "Resource usage in the 'priority' namespace:"
kubectl -n priority describe resourcequota

echo ""
echo "Environment is ready for the task."
echo "Task: Create a high-priority PriorityClass and patch the busybox-logger Deployment."
