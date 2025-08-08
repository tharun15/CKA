#!/bin/bash

# Apply the resources needed for the task
echo "Setting up the environment for the persistent storage task..."

# Apply all resources at once
kubectl apply -f resources.yaml

# Generate the deployment file with only the PVC part commented out
cat <<EOF > mariadb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: task14
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.5
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
        - name: MYSQL_DATABASE
          value: "mydatabase"
        - name: MYSQL_USER
          value: "myuser"
        - name: MYSQL_PASSWORD
          value: "mypassword"
        ports:
        - containerPort: 3306
          name: mariadb
        volumeMounts:
        - name: mariadb-data
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-data
        persistentVolumeClaim:
          claimName: mariadb
          # This PVC should be created to reuse the existing PV

# The PersistentVolumeClaim that needs to be created is not included here
# You will need to create it as part of the task
# ---
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: mariadb
#   namespace: task14
# spec:
#   storageClassName: manual
#   accessModes:
#     - ReadWriteOnce
#   resources:
#     requests:
#       storage: 250Mi
EOF

echo "Created mariadb-deployment.yaml with the MariaDB deployment definition."

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
echo "Task: Create a PVC to reuse the existing PV, then apply the generated MariaDB deployment."
