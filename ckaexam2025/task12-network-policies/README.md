# Configure Network Policies for Cross-Namespace Communication

## Task Overview
In this task, you will configure Kubernetes Network Policies to allow communication between frontend pods in the "frontend" namespace and backend pods in the "backend" namespace, while following the principle of least privilege.

## Setup Instructions

1. First, execute the setup script to create the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will:
   - Create two namespaces: "frontend" and "backend"
   - Deploy frontend pods in the "frontend" namespace
   - Deploy backend pods in the "backend" namespace
   - Create services for both deployments
   - Apply a "deny-all" NetworkPolicy to the "backend" namespace
   - Extract network policy options to the networkpolicies directory

2. Verify the current state of the environment:
   ```bash
   kubectl get ns
   kubectl -n frontend get pods,svc
   kubectl -n backend get pods,svc,networkpolicies
   ```

## Task Requirements

Your task is to:

1. Examine the communication requirements between the frontend and backend services.

2. Choose and apply the appropriate NetworkPolicy that:
   - Allows frontend pods to communicate with backend pods
   - Is as restrictive as possible (follows the principle of least privilege)
   - Does not delete or change the existing "deny-all" NetworkPolicy

3. Test and verify that the communication works correctly.

**IMPORTANT**: Do not delete or modify the existing "deny-all" NetworkPolicy. You need to add a new policy that works alongside it.

## Examining Network Policies

The setup script has created three different network policy options in the networkpolicies directory:

1. **deny-all.yaml**: A policy that denies all traffic to and from the backend namespace (already applied)
2. **allow-frontend-to-backend.yaml**: A policy that specifically allows traffic from frontend pods to backend pods
3. **allow-all-in-namespace.yaml**: A policy that allows all traffic within the namespace

You can examine each policy with:
```bash
cat networkpolicies/deny-all.yaml
cat networkpolicies/allow-frontend-to-backend.yaml
cat networkpolicies/allow-all-in-namespace.yaml
```

## Testing Communication

Before applying any new policies, test the current connectivity:
```bash
# Get a frontend pod name
FRONTEND_POD=$(kubectl -n frontend get pods -l app=frontend -o name | head -1)

# Try to access the backend service from the frontend pod
kubectl -n frontend exec $FRONTEND_POD -- curl -s --connect-timeout 5 backend-svc.backend.svc.cluster.local
```

This should fail due to the "deny-all" policy already in place.

## Applying the Network Policy

After examining the options, apply the most appropriate Network Policy:
```bash
kubectl apply -f networkpolicies/allow-frontend-to-backend.yaml
```

## Verifying the Solution

After applying the Network Policy, test the connectivity again:
```bash
# Get a frontend pod name
FRONTEND_POD=$(kubectl -n frontend get pods -l app=frontend -o name | head -1)

# Try to access the backend service from the frontend pod
kubectl -n frontend exec $FRONTEND_POD -- curl -s --connect-timeout 5 backend-svc.backend.svc.cluster.local
```

If your solution is correct, you should see the response from the backend service: "Backend API is running"

Also, verify that the NetworkPolicy is applied:
```bash
kubectl -n backend get networkpolicies
```

You should see both the "deny-all" and the newly applied Network Policy.

## Success Criteria
- The "deny-all" NetworkPolicy remains unchanged
- A new NetworkPolicy is applied that allows communication from frontend pods to backend pods
- The frontend pod can successfully communicate with the backend service
- The policy follows the principle of least privilege (is as restrictive as possible while allowing the required communication)

## Troubleshooting
If you encounter issues, check:
- Network policy definitions: `kubectl -n backend get networkpolicies -o yaml`
- Pod labels match the selectors in the Network Policy: `kubectl get pods --show-labels -n frontend` and `kubectl get pods --show-labels -n backend`
- Namespace labels match the namespace selectors: `kubectl get ns --show-labels`
- Network policy logs (if available in your cluster): `kubectl logs -n kube-system -l k8s-app=cilium-agent` (if using Cilium) or equivalent for your CNI

## Understanding Network Policies

### Network Policy Structure

A typical NetworkPolicy includes:

1. **podSelector**: Specifies which pods the policy applies to within the namespace
2. **policyTypes**: Specifies whether the policy applies to Ingress, Egress, or both
3. **ingress**: Rules for incoming traffic
4. **egress**: Rules for outgoing traffic

Each ingress or egress rule can specify:
- **from/to**: Sources/destinations allowed (pods, namespaces, IP blocks)
- **ports**: Specific ports and protocols allowed

### Cross-Namespace Communication

For cross-namespace communication, you need to understand:

1. **namespaceSelector**: Selects namespaces based on labels
2. **podSelector**: Selects pods within those namespaces based on labels
3. **Combining selectors**: 
   - When used with `from:` items at the same level, they form an OR condition
   - When used within the same `from:` item, they form an AND condition

Example of an AND condition (pods with label X in namespaces with label Y):
```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        role: frontend
    podSelector:
      matchLabels:
        app: frontend
```

Example of an OR condition (pods with label X OR namespaces with label Y):
```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        role: frontend
  - podSelector:
      matchLabels:
        app: different-app
```

Understanding these concepts is crucial for implementing secure and effective network policies in Kubernetes.
