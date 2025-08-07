#!/bin/bash

# Apply the resources needed for the task
echo "Setting up the environment for the persistent storage task..."

# Apply all resources at once
kubectl apply -f resources.yaml

# Show the current state of the PersistentVolume
echo ""
echo "Current PersistentVolume state:"
kubectl get pv mariadb-pv -o wide

# Verify the PV's status (should be Released, meaning it was previously used)
PV_STATUS=$(kubectl get pv mariadb-pv -o jsonpath='{.status.phase}')
if [ "$PV_STATUS" = "Released" ]; then
  echo ""
  echo "The PersistentVolume is in the Released state, indicating it was previously claimed but now available for reuse."
  echo "This simulates a scenario where the MariaDB deployment was deleted but its data volume remains."
else
  echo ""
  echo "Warning: The PersistentVolume is not in the expected Released state."
  echo "Current state: $PV_STATUS"
fi

# Check if there are any PVCs in the namespace (should be none)
echo ""
echo "Current PersistentVolumeClaims in the task14 namespace:"
kubectl get pvc -n task14

# Check if there are any Deployments in the namespace (should be none)
echo ""
echo "Current Deployments in the task14 namespace:"
kubectl get deployments -n task14

echo ""
echo "Environment is ready for the task."
echo "Task: Create a PVC to reuse the existing PV, then recreate the MariaDB deployment."
