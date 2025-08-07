Task: Configure Horizontal Pod Autoscaler (HPA) with Custom Behavior
Background
In this task, you'll be working with Kubernetes' Horizontal Pod Autoscaler (HPA), which automatically scales the number of pods in a deployment based on observed CPU utilization or other selected metrics. HPA helps ensure that your applications have the resources they need during high demand while conserving resources during periods of low utilization.

Objective
Configure a Horizontal Pod Autoscaler for a Nginx deployment with specific scaling behavior parameters, including a 5-minute (300 seconds) stabilization window for scale-down operations.

Resources
The Kubernetes resources are provided in the task6/resources.yaml file, which includes:
- A Deployment running an Nginx container with resource requests and limits defined
- A Service that exposes the Deployment within the cluster

Additionally, the execute.sh script will:
- Create the task6 namespace
- Check if the metrics-server is installed and install it if needed
  (The metrics-server is required for HPA to collect resource metrics from pods)

Key HPA Concepts
1. Scale Target: The workload resource to scale (typically a Deployment)
2. Metrics: The metrics to monitor (CPU utilization, memory usage, custom metrics)
3. Min/Max Replicas: The lower and upper bounds for the number of replicas
4. Behavior: Controls how the HPA scales pods up or down, including:
   - scaleUp: How quickly to add pods
   - scaleDown: How quickly to remove pods
   - stabilizationWindowSeconds: Time to wait before scaling down to prevent thrashing

Benefits of Using HPA:
- Automatically adjusts resources based on actual demand
- Improves application availability during traffic spikes
- Optimizes resource utilization and costs
- Can be customized with scaling behaviors to prevent rapid fluctuations
