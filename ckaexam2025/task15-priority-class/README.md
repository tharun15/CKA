# Configure PriorityClass for Critical Workloads

## Task Overview
In this task, you will create a new PriorityClass with a specific priority value and patch an existing Deployment to use this new priority class. This will demonstrate how Kubernetes uses priority to make scheduling and eviction decisions when resources are constrained.

## Setup Instructions

1. First, execute the setup script to create the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `priority`
   - Create two PriorityClasses: `system-priority` and `low-priority`
   - Deploy a `busybox-logger` Deployment without a priority class
   - Deploy a `resource-consumer` Deployment with the `low-priority` class
   - Apply resource quotas to the namespace to create resource constraints

2. Verify the current state of the environment:
   ```bash
   kubectl -n priority get pods
   kubectl get priorityclasses
   kubectl -n priority describe resourcequota
   ```

## Task Requirements

Your task is to:

1. Create a new PriorityClass named `high-priority` for user workloads with a value that is one less than the highest existing user-defined priority class value.

2. Patch the existing `busybox-logger` Deployment running in the `priority` namespace to use the `high-priority` priority class.

3. Ensure that the `busybox-logger` Deployment rolls out successfully with the new priority class set.

It is expected that pods from the `resource-consumer` Deployment running in the `priority` namespace will be evicted to make room for the higher-priority pods. Do not modify the `resource-consumer` Deployment directly.

Follow these steps to complete the task:

### Step 1: Identify the highest existing user-defined priority class value

```bash
kubectl get priorityclasses -o custom-columns=NAME:.metadata.name,VALUE:.value
```

Look at the output and identify the highest priority value among user-defined priority classes. Note that Kubernetes system priority classes typically have values greater than 1000000000.

### Step 2: Create a new PriorityClass

Create a YAML file for the new priority class (e.g., `high-priority.yaml`):

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
spec:
  # Set this value to one less than the highest existing user-defined priority class
  # In our case, system-priority has value 1000000, so high-priority should be 999999
  value: 999999
  globalDefault: false
  description: "This priority class is for high-priority user workloads"
```

Apply the new PriorityClass:

```bash
kubectl apply -f high-priority.yaml
```

### Step 3: Patch the busybox-logger Deployment

You can patch the Deployment using either of these methods:

**Option 1: Using kubectl patch command**
```bash
kubectl -n priority patch deployment busybox-logger --patch '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
```

**Option 2: Using kubectl edit command**
```bash
kubectl -n priority edit deployment busybox-logger
```
Then add the `priorityClassName: high-priority` field at the appropriate location in the spec.template.spec section.

### Step 4: Verify the results

1. Check that the Deployment has been updated:
   ```bash
   kubectl -n priority get deployment busybox-logger -o yaml | grep priorityClassName
   ```

2. Monitor the rollout of the Deployment:
   ```bash
   kubectl -n priority rollout status deployment/busybox-logger
   ```

3. Observe the pod status in the namespace:
   ```bash
   kubectl -n priority get pods
   ```
   You should see that the `busybox-logger` pods are Running, while some or all of the `resource-consumer` pods may be in a Pending state or have been evicted due to resource constraints.

4. Check the events in the namespace to see the eviction process:
   ```bash
   kubectl -n priority get events --sort-by='.lastTimestamp'
   ```

## Success Criteria
- A new PriorityClass named `high-priority` is created with the correct value
- The `busybox-logger` Deployment is successfully patched to use the new priority class
- The `busybox-logger` pods are running with the high-priority setting
- Pods from the `resource-consumer` Deployment are evicted to make room for the higher-priority pods
- The `resource-consumer` Deployment itself is not modified

## Troubleshooting
If you encounter issues, check:
- Priority class values: `kubectl get priorityclasses`
- Deployment patch status: `kubectl -n priority describe deployment busybox-logger`
- Pod scheduling events: `kubectl -n priority get events | grep scheduling`
- Resource usage: `kubectl -n priority describe resourcequota`
- Pod status with priority information: `kubectl -n priority get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,PRIORITY:.spec.priority`

## Understanding PriorityClasses and Preemption

### How PriorityClasses Work

When you assign a PriorityClass to a Pod (via the Deployment's pod template), Kubernetes does the following:

1. **Pod Priority Assignment**: The pod's `priority` field is set to the value defined in the PriorityClass.

2. **Scheduling**: When the scheduler decides which pods to place on nodes, it considers pods with higher priority first.

3. **Preemption**: If a high-priority pod cannot be scheduled due to resource constraints, the scheduler may evict (preempt) lower-priority pods to make room.

4. **Eviction Decision**: The eviction decision considers:
   - Pod priority values
   - Resource usage
   - Pod disruption budgets
   - Node constraints

### Impact on Resource-Constrained Environments

In resource-constrained environments (like our task with tight ResourceQuota limits):

- High-priority workloads will get resources first
- When resources are fully utilized, the scheduler will evict lower-priority pods
- If no resources can be freed, even high-priority pods may remain in a Pending state
- System critical pods (typically with priority > 1000000000) can preempt almost any other pod

This prioritization mechanism ensures that the most important workloads continue to run even when resources are scarce.
