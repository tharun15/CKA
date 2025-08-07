# Configure Horizontal Pod Autoscaler (HPA) with Custom Behavior

## Task Overview
In this task, you will configure a Horizontal Pod Autoscaler (HPA) for a Nginx deployment, setting specific scaling behavior parameters including a 5-minute stabilization window for scale-down operations.

## Setup Instructions

1. First, execute the setup script to create the namespace and ensure metrics-server is installed:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create a namespace called `task6` and set it as your current working namespace
   - Check if the metrics-server is installed, and install it if needed
     (The metrics-server is required for HPA to collect resource metrics from pods)

2. Apply the provided resources:
   ```bash
   kubectl apply -f resources.yaml
   ```
   This will create:
   - A Deployment running an Nginx container with resource requests and limits defined
   - A Service that exposes the Deployment within the cluster

3. Verify the resources are running:
   ```bash
   kubectl get pods
   kubectl get services
   ```

## Task Requirements

Your task is to create a Horizontal Pod Autoscaler (HPA) for the Nginx deployment with the following specifications:

- Set minimum replicas to 1
- Set maximum replicas to 3
- Scale based on CPU utilization (target: 50%)
- Configure a 5-minute (300 seconds) stabilization window for scale-down operations

Follow these steps to complete the task:

1. Create an HPA resource file (e.g., `nginx-hpa.yaml`):
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: nginx-hpa
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: nginx-deployment
     minReplicas: 1
     maxReplicas: 3
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 50
     behavior:
       scaleDown:
         stabilizationWindowSeconds: 300
   ```

2. Apply the HPA resource:
   ```bash
   kubectl apply -f nginx-hpa.yaml
   ```

3. Verify the HPA was created correctly:
   ```bash
   kubectl get hpa
   kubectl describe hpa nginx-hpa
   ```

## Testing the HPA

To test the HPA, you can generate load on the Nginx deployment:

1. Get the pod name:
   ```bash
   NGINX_POD=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
   ```

2. Create a temporary pod to generate load:
   ```bash
   kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://nginx-service; done"
   ```

3. In another terminal, monitor the HPA:
   ```bash
   kubectl get hpa nginx-hpa --watch
   ```

4. Observe the scaling behavior:
   ```bash
   kubectl get pods -w
   ```

5. To stop the load test, press Ctrl+C in the terminal running the load-generator.

## Success Criteria
- An HPA named `nginx-hpa` is created and properly targeting the nginx-deployment
- The HPA has minReplicas set to 1 and maxReplicas set to 3
- The HPA is configured to scale based on CPU utilization with a target of 50%
- The scaleDown behavior includes a stabilizationWindowSeconds value of 300
- When tested with load, the HPA correctly scales the deployment based on CPU utilization
- When load is removed, the HPA respects the 5-minute stabilization window before scaling down

## Troubleshooting
If you encounter issues, check:
- Metrics server status: `kubectl get deployment metrics-server -n kube-system`
- HPA status: `kubectl describe hpa nginx-hpa`
- Check if metrics are being collected: `kubectl top pods`
- Nginx pod resource settings: `kubectl describe pod <nginx-pod-name>`
- HPA events: `kubectl get events | grep HorizontalPodAutoscaler`

## Understanding Stabilization Window

The stabilization window is a crucial feature in HPA behavior configuration (available from Kubernetes v1.18+) that addresses a common problem in autoscaling: **thrashing** - the rapid, unnecessary scaling up and down of pods that can occur when load fluctuates around the threshold.

### What the 5-minute (300 seconds) stabilization window does:

- **Prevents premature scale-down**: When CPU utilization drops below the target threshold, the HPA won't immediately remove pods. Instead, it will wait for the full 300-second period to ensure that the drop in utilization is persistent and not just a temporary fluctuation.

- **Considers historical metrics**: During the stabilization window, the HPA continuously monitors the metrics. If at any point within the 300-second window the metrics suggest scaling up is needed again, the scale-down operation is canceled.

- **Smooths out workload transitions**: For applications with variable load patterns (e.g., web services with periodic spikes), the stabilization window ensures resources remain available for the next potential spike, rather than being removed and then quickly added again.

- **Reduces pod churn**: Frequent creation and termination of pods can impact application availability and performance. The stabilization window minimizes unnecessary pod creation/termination cycles.

- **Optimizes cluster resource utilization**: By preventing overreaction to short-lived metric changes, the stabilization window helps maintain a balance between resource efficiency and application responsiveness.

Without a stabilization window (or with a very short one), the following problems could occur:
- Pods might be terminated prematurely only to be created again moments later
- Application performance might degrade during the scaling operations
- Excessive pod churn could put unnecessary load on the cluster

The 5-minute stabilization window for scale-down operations specified in this task represents a balanced approach - long enough to avoid reacting to temporary fluctuations but not so long that resources are wasted during genuine periods of low demand.

## HPA Behavior Configuration Options

```yaml
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300  # Wait 5 minutes before scaling down
    policies:
    - type: Percent
      value: 10
      periodSeconds: 60  # Remove at most 10% of current pods every minute
  scaleUp:
    stabilizationWindowSeconds: 0    # Scale up immediately when needed
    policies:
    - type: Percent
      value: 100
      periodSeconds: 15  # Double the number of pods every 15 seconds
    - type: Pods
      value: 4
      periodSeconds: 15  # Or add 4 pods every 15 seconds, whichever is greater
    selectPolicy: Max    # Use the policy that allows the highest increase
```

The above example shows additional behavior settings that can be used for fine-tuning your HPA, but for this task, you only need to configure the `stabilizationWindowSeconds` for `scaleDown`.
