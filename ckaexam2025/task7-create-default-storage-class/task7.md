Task: Create and Configure Default Storage Class
Background
In this task, you'll be working with Kubernetes StorageClasses, which provide a way to describe the "classes" of storage offered by a cluster administrator. Different classes might map to quality-of-service levels, backup policies, or arbitrary policies determined by the cluster administrators. StorageClasses are essential for dynamic provisioning of Persistent Volumes in Kubernetes.

Objective
Create a high-performance StorageClass with specific parameters and then make it the default StorageClass in the cluster, ensuring that any PersistentVolumeClaim (PVC) that doesn't explicitly specify a StorageClass will use this one.

Resources
The storage class definition is provided in the task7/resources.yaml file, which includes:
- A StorageClass named "low-latency" with specific provisioner, parameters and options
- Initially, the StorageClass is not set as the default

Key StorageClass Concepts
1. Provisioner: Determines what volume plugin is used for provisioning PVs
2. Parameters: Specific to the provisioner, allowing further customization
3. ReclaimPolicy: Controls what happens to a PV when its PVC is deleted
4. Volume Binding Mode: Controls when volume binding and dynamic provisioning occurs
5. Allow Volume Expansion: Whether to allow expanding volumes after creation
6. Mount Options: Options used when mounting the volume

Default StorageClass
A cluster can have multiple StorageClasses, but only one can be marked as the default. When a PVC is created without specifying a StorageClass, the default StorageClass is used automatically. This is controlled by the annotation:
```yaml
storageclass.kubernetes.io/is-default-class: "true"
```

The execute.sh script handles making the StorageClass the default through a two-step process:
1. If there's an existing default StorageClass, it removes its default status using the kubectl patch command
2. It then sets the new StorageClass as the default using another patch command

Benefits of Configuring Default StorageClasses:
- Simplifies PVC creation for users who don't need to specify storage requirements
- Ensures consistent storage provisioning across the cluster
- Allows administrators to control default storage behavior
