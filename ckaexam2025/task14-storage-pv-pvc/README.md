# Recover a Deleted Deployment Using Persistent Storage

## Task Overview
In this task, you will recover from a scenario where a MariaDB deployment was accidentally deleted, but its associated PersistentVolume still exists. You will create a new PersistentVolumeClaim to reuse this volume, then recreate the MariaDB deployment to restore service with the preserved data.

## Setup Instructions

1. First, execute the setup script to create the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `task14`
   - Create a PersistentVolume named `mariadb-pv` that is in the Released state
   - Display the current state of resources in the namespace

2. Verify the current state of the PersistentVolume:
   ```bash
   kubectl get pv mariadb-pv -o wide
   ```
   You should see that the PV is in the "Released" state, indicating it was previously used but is now available for reuse.

## Task Requirements

Your task is to:

1. Create a PersistentVolumeClaim named `mariadb` in the `task14` namespace that will reuse the existing PersistentVolume.

2. Create a MariaDB deployment that uses this PVC to access the preserved data.

3. Verify that the MariaDB deployment is running successfully with the restored data.

Follow these steps to complete the task:

### Step 1: Create the PersistentVolumeClaim

Create a YAML file for the PVC (e.g., `mariadb-pvc.yaml`):

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: task14
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
```

Apply the PVC:

```bash
kubectl apply -f mariadb-pvc.yaml
```

### Step 2: Verify that the PVC is bound to the existing PV

```bash
kubectl get pvc -n task14
kubectl get pv mariadb-pv
```

The PVC should now be in the "Bound" state, and it should be bound to the `mariadb-pv` PersistentVolume.

### Step 3: Create the MariaDB Deployment

Create a YAML file for the deployment (e.g., `mariadb-deployment.yaml`):

```yaml
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
```

Apply the deployment:

```bash
kubectl apply -f mariadb-deployment.yaml
```

### Step 4: Verify that the MariaDB deployment is running

```bash
kubectl get pods -n task14
kubectl get deployment mariadb -n task14
```

### Step 5: Check the logs to ensure MariaDB started successfully

```bash
POD_NAME=$(kubectl get pods -n task14 -l app=mariadb -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD_NAME -n task14
```

If MariaDB started successfully and could access the previous data, you should see normal startup logs without any errors related to corrupted data or initialization.

## Success Criteria
- A PersistentVolumeClaim named `mariadb` is created in the `task14` namespace
- The PVC is bound to the existing `mariadb-pv` PersistentVolume
- A MariaDB deployment is created that uses this PVC
- The MariaDB pod is running successfully
- The logs indicate that MariaDB started without data integrity issues

## Troubleshooting
If you encounter issues, check:
- PV and PVC status: `kubectl get pv,pvc -n task14`
- PVC details: `kubectl describe pvc mariadb -n task14`
- Pod status: `kubectl describe pod -l app=mariadb -n task14`
- MariaDB logs: `kubectl logs -l app=mariadb -n task14`
- Events: `kubectl get events -n task14 --sort-by='.lastTimestamp'`

## Understanding Persistent Storage in Kubernetes

### The Lifecycle of Persistent Storage

1. **Creation**: A PersistentVolume is provisioned by an admin or dynamically via a StorageClass.

2. **Binding**: A PersistentVolumeClaim requests storage and, if a matching PV is available, they are bound together.

3. **Usage**: Pods mount the PVC, which provides access to the underlying PV.

4. **Reclaiming**: When a PVC is deleted, what happens to the PV depends on its reclaim policy:
   - **Delete**: The PV is deleted along with its data (default for dynamically provisioned PVs)
   - **Retain**: The PV and its data are kept, but it must be manually reclaimed (common for stateful applications)
   - **Recycle**: The volume is scrubbed before making it available again (deprecated)

### Recovery Scenarios

When a deployment or stateful application using persistent storage is accidentally deleted, the data may still be intact if:

1. The PV has a "Retain" reclaim policy
2. Only the deployment/pod was deleted, not the PVC

In these cases, you can recover by:

1. If the PVC still exists: Simply recreate the deployment with the same PVC reference
2. If the PVC was deleted but PV exists: Create a new PVC with matching specifications and reference it in the new deployment

This task simulates the second scenario, which is more challenging but demonstrates how Kubernetes persistent storage can be leveraged for data durability even in accident scenarios.
