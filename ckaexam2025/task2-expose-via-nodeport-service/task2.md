Task: Expose Nginx Web Server via NodePort Service
Background
In this task, you'll be exposing an Nginx web server outside the Kubernetes cluster using a NodePort service. NodePort services make an application accessible from outside the cluster by allocating a specific port on all nodes.

Objective
Configure a NodePort service to expose the Nginx web server, allowing access to it from outside the Kubernetes cluster.

Resources
The Kubernetes resources are provided in the task2/resources.yaml file, which includes:
- A Deployment running the Nginx container
