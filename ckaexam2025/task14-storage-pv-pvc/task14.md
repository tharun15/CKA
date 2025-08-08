Task: Recover a Deleted Deployment Using an Existing PersistentVolume

## Background
In this task, you'll be recovering from a scenario where a MariaDB deployment was accidentally deleted, but its associated PersistentVolume still exists. This is a common data recovery scenario in Kubernetes environments where persistent storage is used to maintain state across pod lifecycles.

## Objective
Create a new PersistentVolumeClaim to reuse an existing PersistentVolume, then apply the generated MariaDB deployment that uses this PVC, ensuring data continuity.

## Resources
The Kubernetes resources are provided in the task14/resources.yaml file, which includes:
- A namespace called "task14" for this demonstration
- A PersistentVolume named "mariadb-pv" with 250Mi capacity that was previously used by a now-deleted MariaDB deployment

When you run the execute.sh script, it will:
- Apply the resources.yaml file
- Generate a mariadb-deployment.yaml file with the MariaDB deployment uncommented and the PVC part commented out
- Display the current state of the PersistentVolume and other resources

## Key Persistent Storage Concepts
1. PersistentVolume (PV): A piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned
2. PersistentVolumeClaim (PVC): A request for storage by a user that can be fulfilled by binding to a PV
3. Storage Class: Defines the type of storage and provisioner to use
4. Access Modes: How the volume can be mounted (ReadWriteOnce, ReadOnlyMany, ReadWriteMany)
5. Reclaim Policy: What happens to a PV when its claim is deleted (Retain, Recycle, Delete)

## The Data Recovery Process
1. When a deployment is deleted, but its PV has a "Retain" reclaim policy, the data remains intact
2. The PV enters a "Released" state but is not available for new claims because it still has a reference to the old claim
3. To reuse the PV, a new PVC must be created with the exact same specifications
4. Once the PVC is bound to the existing PV, the MariaDB deployment can be applied to access the preserved data

## Task Challenge
The challenge in this task lies in:
1. Creating a PVC with the correct specifications to bind to the existing PV
2. Applying the MariaDB deployment to use this PVC, ensuring it can access the existing data
3. Verifying that the deployment starts successfully, indicating that the data was properly recovered
