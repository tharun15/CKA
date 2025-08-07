#!/bin/bash

# Apply the resources needed for the task
echo "Setting up the environment for the Network Policy task..."

# Apply all resources at once (except the network policies that need to be chosen by the user)
kubectl apply -f <(cat resources.yaml | grep -v -E "Network Policy [23]:" -A1000 | grep -v -E "Network Policy [3]:" -A1000)

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl -n frontend wait --for=condition=available --timeout=60s deployment/frontend
kubectl -n backend wait --for=condition=available --timeout=60s deployment/backend

# Show the current deployments and pods
echo ""
echo "Current deployments in the frontend namespace:"
kubectl -n frontend get deployments

echo ""
echo "Current deployments in the backend namespace:"
kubectl -n backend get deployments

echo ""
echo "Current pods in the frontend namespace:"
kubectl -n frontend get pods

echo ""
echo "Current pods in the backend namespace:"
kubectl -n backend get pods

echo ""
echo "Current network policies in the backend namespace:"
kubectl -n backend get networkpolicies

# Create the networkpolicy files for user reference
echo "Creating Network Policy files for the task..."
mkdir -p networkpolicies

# Extract and save each network policy to a file
cat resources.yaml | grep -A1000 "# Network Policy 1:" | grep -B1000 "# Network Policy 2:" > networkpolicies/deny-all.yaml
cat resources.yaml | grep -A1000 "# Network Policy 2:" | grep -B1000 "# Network Policy 3:" > networkpolicies/allow-frontend-to-backend.yaml
cat resources.yaml | grep -A1000 "# Network Policy 3:" > networkpolicies/allow-all-in-namespace.yaml

echo ""
echo "Network Policy files have been created in the networkpolicies directory."
echo "You can examine them with:"
echo "  cat networkpolicies/deny-all.yaml"
echo "  cat networkpolicies/allow-frontend-to-backend.yaml"
echo "  cat networkpolicies/allow-all-in-namespace.yaml"

echo ""
echo "Test the connectivity between frontend and backend:"
echo "  kubectl -n frontend exec \$(kubectl -n frontend get pods -l app=frontend -o name | head -1) -- curl -s --connect-timeout 5 backend-svc.backend.svc.cluster.local"
echo ""
echo "Note: The test will likely fail due to the 'deny-all' policy being applied."
echo "Your task is to apply the appropriate network policy to allow communication between frontend and backend."
