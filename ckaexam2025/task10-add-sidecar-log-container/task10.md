Task: Add a Sidecar Container for Log Processing
Background
In this task, you'll be working with Kubernetes sidecar containers, which are helper containers that run alongside the main application container in a Pod. Sidecar containers extend and enhance the functionality of the main container without changing it. This pattern is commonly used for logging, monitoring, proxying, and other auxiliary functions.

Objective
Add a sidecar container to an existing deployment that will process log files produced by the main application container. The sidecar and main container will share a volume to access the same log files.

Resources
The Kubernetes resources are provided in the task10/resources.yaml file, which includes:
- A Deployment with a main container that writes logs to a file
- The main container has two environment variables: APP_ENV and LOG_LEVEL
- A shared volume definition using emptyDir
- The main container mounts this volume at /var/log/app

Key Sidecar Container Concepts
1. Multi-Container Pods: Kubernetes pods can contain multiple containers that share the same network namespace, IPC namespace, and volumes
2. Volume Sharing: Containers in the same pod can share data through mounted volumes
3. Separation of Concerns: The main container focuses on its primary function while sidecars handle auxiliary tasks
4. Common Sidecar Uses:
   - Log collection and forwarding
   - Metrics collection
   - Content synchronization
   - Proxy/API gateway

Benefits of Sidecar Containers:
- Modular application architecture
- Separation of concerns between application logic and supporting functions
- Ability to update logging or monitoring without changing the application
- Reusable components that can be applied to different applications
- Consistent logging and monitoring across diverse applications
