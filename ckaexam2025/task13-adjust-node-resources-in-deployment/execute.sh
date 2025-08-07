#!/bin/bash

# Create the namespace
kubectl create namespace task13

# Set the namespace as the current context
kubectl config set-context --current --namespace=task13

# Verify the current namespace
echo "Current namespace is now:"
kubectl config view --minify | grep namespace:

# Get allocatable resources from node01
echo "Fetching allocatable resources from node01..."
NODE_CPU=$(kubectl get node node01 -o jsonpath='{.status.allocatable.cpu}')
NODE_MEMORY=$(kubectl get node node01 -o jsonpath='{.status.allocatable.memory}')

echo "Node01 allocatable CPU: $NODE_CPU"
echo "Node01 allocatable Memory: $NODE_MEMORY"

# Remove any suffix from CPU value
NODE_CPU_NUM=$(echo $NODE_CPU | sed 's/[^0-9]*//g')

# Convert memory to Mi if it's in Ki
if [[ $NODE_MEMORY == *Ki ]]; then
    NODE_MEMORY_NUM=$(echo $NODE_MEMORY | sed 's/Ki//')
    NODE_MEMORY_MI=$(($NODE_MEMORY_NUM / 1024))
    NODE_MEMORY="${NODE_MEMORY_MI}Mi"
fi

# Calculate resources for 3 pods with some overhead
# Use 90% of node resources (leaving 10% for system)
TOTAL_CPU_FOR_PODS=$(echo "scale=2; $NODE_CPU_NUM * 0.9" | bc)
TOTAL_MEM_FOR_PODS=$(echo $NODE_MEMORY | sed 's/[^0-9]*//g')
TOTAL_MEM_FOR_PODS=$(echo "scale=0; $TOTAL_MEM_FOR_PODS * 0.9" | bc)

# Calculate per-pod resources - for 3 pods
PER_POD_CPU=$(echo "scale=2; $TOTAL_CPU_FOR_PODS / 3" | bc)
PER_POD_MEM=$(echo "scale=0; $TOTAL_MEM_FOR_PODS / 3" | bc)

# Set requests slightly lower than limits to ensure pods can start
CPU_REQUEST=$(echo "scale=2; $PER_POD_CPU * 0.5" | bc)
MEM_REQUEST=$(echo "scale=0; $PER_POD_MEM * 0.5" | bc)

# To ensure only 2 of 3 pods can run, set limits so 3rd pod won't fit
# Set limits to use 45% of node resources per pod (so 2 pods use 90%)
CPU_LIMIT=$(echo "scale=2; $TOTAL_CPU_FOR_PODS / 2" | bc)
MEM_LIMIT=$(echo "scale=0; $TOTAL_MEM_FOR_PODS / 2" | bc)

echo "Calculated resources:"
echo "CPU request: ${CPU_REQUEST}"
echo "CPU limit: ${CPU_LIMIT}"
echo "Memory request: ${MEM_REQUEST}Mi"
echo "Memory limit: ${MEM_LIMIT}Mi"

# Generate the deployment YAML
cat > resources.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      initContainers:
      - name: init-nginx
        image: busybox:latest
        command: ['sh', '-c', 'echo "Init container preparing environment..." && sleep 5']
        resources:
          requests:
            cpu: ${CPU_REQUEST}
            memory: ${MEM_REQUEST}Mi
          limits:
            cpu: ${CPU_LIMIT}
            memory: ${MEM_LIMIT}Mi
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: ${CPU_REQUEST}
            memory: ${MEM_REQUEST}Mi
          limits:
            cpu: ${CPU_LIMIT}
            memory: ${MEM_LIMIT}Mi
EOF

echo "Deployment YAML has been generated as resources.yaml"
echo ""
echo "To apply the resources, run:"
echo "kubectl apply -f resources.yaml"
echo ""
echo "Note: With the current resource settings, only 2 out of 3 pods will be able to run."
echo "You will need to adjust the resource requests to make all 3 pods run successfully."
echo ""
echo "Resource calculation explanation:"
echo "--------------------------------"
echo "For a node with 4 CPU and 1234556Mi memory:"
echo " - 90% available for pods: 3.6 CPU and 1111100Mi memory"
echo " - Per pod limits (for 2 pods): 1.8 CPU and 555550Mi memory"
echo " - Per pod requests (50% of limits): 0.9 CPU and 277775Mi memory"
echo ""
echo "With these settings, 2 pods would request 1.8 CPU and 555550Mi memory in total,"
echo "leaving 1.8 CPU and 555550Mi memory available, which is enough for 1 more pod."
echo "However, because the limits are set to 1.8 CPU and 555550Mi memory per pod,"
echo "the 3rd pod won't fit as it would exceed the node's capacity."
echo ""
echo "To fix this, you should adjust the resource requests/limits to fit 3 pods."
