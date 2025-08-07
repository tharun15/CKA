Task: Configure Priority Classes for Pod Scheduling
Background
In this task, you'll be working with Kubernetes PriorityClasses, which influence the scheduling and eviction order of Pods. Pods with higher priority are scheduled before pods with lower priority, and in resource-constrained environments, lower-priority pods may be evicted to make room for higher-priority pods.

Objective
Create a new PriorityClass with a carefully chosen priority value and apply it to an existing Deployment, causing resource reallocation within the cluster that results in eviction of lower-priority pods.

Resources
The Kubernetes resources are provided in the task15/resources.yaml file, which includes:
- A namespace called "priority" for this demonstration
- Two PriorityClasses: "system-priority" (very high value) and "low-priority" (lower value)
- Two Deployments in the "priority" namespace:
  - "busybox-logger": A deployment that needs to be patched with a new priority class
  - "resource-consumer": A deployment using the "low-priority" priority class
- A ResourceQuota limiting the total resources in the namespace, creating competition for resources

Key PriorityClass Concepts
1. Priority Value: Determines the relative importance of pods during scheduling and eviction
2. Global Default: Whether this priority class is the default for pods without a specified class
3. Preemption Policy: Controls whether pods of this priority can cause eviction of lower priority pods
4. System Priority Classes: Kubernetes reserves priority values over 1000000000 for system-critical pods

Pod Priority and Preemption Process
1. When resources are constrained, the scheduler will evict lower-priority pods to make room for higher-priority pods
2. Pods with no priority class are treated as having priority 0
3. Priority affects both initial scheduling and eviction decisions
4. The scheduler considers node constraints, affinity rules, and priority together when making decisions

Task Challenge
The challenge in this task lies in:
1. Correctly identifying the highest existing user-defined priority value
2. Creating a new priority class with an appropriate value
3. Properly patching the existing Deployment to use the new priority class
4. Verifying that the expected evictions occur due to the new priority settings
