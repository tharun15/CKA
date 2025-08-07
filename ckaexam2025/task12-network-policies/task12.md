Task: Configure Network Policies for Cross-Namespace Communication
Background
In this task, you'll be working with Kubernetes Network Policies, which are specifications of how groups of pods are allowed to communicate with each other and with other network endpoints. Network policies provide fine-grained control over network traffic flow at the IP address or port level within a cluster.

Objective
Configure the appropriate Network Policy to allow communication between frontend pods in the "frontend" namespace and backend pods in the "backend" namespace, while maintaining the principle of least privilege.

Resources
The Kubernetes resources are provided in the task12/resources.yaml file, which includes:
- Two namespaces: "frontend" and "backend"
- A frontend deployment in the "frontend" namespace
- A backend deployment in the "backend" namespace
- Services exposing both deployments
- A "deny-all" NetworkPolicy already applied to the "backend" namespace
- Two other NetworkPolicy options (not applied)

Key Network Policy Concepts
1. Network Policies are namespace-scoped resources
2. By default, if no policies exist, all traffic is allowed
3. Once any Network Policy is applied to a namespace, all traffic not specifically allowed is denied
4. Policies use label selectors to specify which pods they apply to
5. Ingress rules control incoming traffic, while egress rules control outgoing traffic
6. Policies can select traffic based on:
   - Pod and namespace labels
   - IP CIDR ranges
   - Ports and protocols

Network Policy Selection Process
1. Examine the communication requirements between services
2. Identify the least permissive policy that meets those requirements
3. Apply the policy and test connectivity
4. Adjust as needed while maintaining the principle of least privilege

Task Challenge
The challenge in this task lies in:
1. Understanding the existing network setup with frontend and backend in different namespaces
2. Analyzing the available Network Policy options
3. Selecting the policy that allows the required communication while being as restrictive as possible
4. Testing to verify the policy works as expected
