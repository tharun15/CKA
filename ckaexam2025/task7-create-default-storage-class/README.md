# Create and Configure Default Storage Class

## Task Overview
In this task, you will create a high-performance StorageClass with specific parameters and then configure it to be the default StorageClass in the cluster. This ensures that any PersistentVolumeClaim (PVC) that doesn't explicitly specify a StorageClass will automatically use this one.

## Setup Instructions

1. Execute the setup script to create the namespace, create the StorageClass, and set it as the default:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `task7` and set it as your current working namespace
   - Check if there are any existing default StorageClasses in the cluster
   - Apply the `low-latency` StorageClass from resources.yaml
   - If there's an existing default StorageClass, remove its default status
   - Make the `low-latency` StorageClass the default using the patch command
   - Verify the changes by listing all StorageClasses

2. Verify the StorageClass was created and set as default:
   ```bash
   kubectl get storageclass
   kubectl describe storageclass low-latency
   ```
   You should see `low-latency` marked as `(default)`.

## Understanding the Default StorageClass Configuration

The execute.sh script performs the following operations to make the `low-latency` StorageClass the default:

1. Checks if there's an existing default StorageClass:
   ```bash
   DEFAULT_SC=$(kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
   ```

2. If there's an existing default StorageClass, removes its default status:
   ```bash
   kubectl patch storageclass $DEFAULT_SC -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
   ```

3. Makes the `low-latency` StorageClass the default using the patch command:
   ```bash
   kubectl patch storageclass low-latency -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
   ```

This approach uses the kubectl patch command, which is a powerful way to make partial updates to Kubernetes resources without having to reapply the entire resource definition.

## Testing the Default StorageClass

To verify that the default StorageClass works correctly, create a PVC without specifying a StorageClass:

1. Create a test PVC file (e.g., `test-pvc.yaml`):
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: test-pvc
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 1Gi
   ```
   Note: The `storageClassName` field is deliberately omitted.

2. Apply the test PVC:
   ```bash
   kubectl apply -f test-pvc.yaml
   ```

3. Verify that the PVC is using the default StorageClass:
   ```bash
   kubectl get pvc test-pvc -o jsonpath='{.spec.storageClassName}'
   ```
   It should output: `low-latency`

## Success Criteria
- The `low-latency` StorageClass is created with all the specified parameters
- Any previous default StorageClass is no longer marked as default
- The `low-latency` StorageClass is marked as the default StorageClass
- A PVC created without specifying a StorageClass automatically uses the `low-latency` StorageClass

## Troubleshooting
If you encounter issues, check:
- StorageClass status: `kubectl describe storageclass low-latency`
- Annotations on the StorageClass: `kubectl get storageclass low-latency -o yaml | grep annotations -A 3`
- Events related to PVCs: `kubectl get events | grep PersistentVolumeClaim`
- Kubernetes API server logs if you have access

## Understanding StorageClass Parameters

The `low-latency` StorageClass has several important parameters:

1. **Provisioner**: `csi-driver.example-vendor.example`
   - This identifies the volume plugin used to provision PVs.
   - In a real environment, this would be a specific CSI driver like `ebs.csi.aws.com` for AWS EBS.

2. **ReclaimPolicy**: `Retain`
   - When a PVC is deleted, the PV will not be deleted and remains in the Released state.
   - This preserves data even after the PVC is deleted, but requires manual reclamation.

3. **allowVolumeExpansion**: `true`
   - Allows users to resize volumes by editing the PVC.
   - Without this, volumes would be fixed in size once created.

4. **mountOptions**: `["discard"]`
   - Applied when mounting the volume on nodes.
   - The `discard` option can enable TRIM/UNMAP which allows the storage to reclaim unused blocks.

5. **volumeBindingMode**: `WaitForFirstConsumer`
   - Delays the binding and provisioning of a PV until a Pod using the PVC is created.
   - This enables topology-aware provisioning, ensuring volumes are created in the same zone as the Pod.

6. **parameters**: `{"guaranteedReadWriteLatency": "true"}`
   - Provider-specific parameters to customize the volume behavior.
   - In this case, requesting guaranteed low latency for read/write operations.

By setting this StorageClass as the default, you ensure that all users who don't explicitly specify a storage class will get high-performance storage with these optimized settings.
