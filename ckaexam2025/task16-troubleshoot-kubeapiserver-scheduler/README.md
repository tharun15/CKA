# Troubleshoot Kubernetes Control Plane Components

## Task Overview
In this task, you will troubleshoot and fix several issues with Kubernetes control plane components: kube-apiserver, kube-scheduler, and kubelet. These components are critical for the proper functioning of a Kubernetes cluster, and their failure can cause cluster-wide outages.

## Setup Instructions

1. First, execute the setup script to prepare the environment:
   ```bash
   chmod +x execute.sh
   ./execute.sh
   ```
   This will create sample log files and configuration files that simulate various control plane issues.

## Task Requirements

You need to identify and fix the following issues in the Kubernetes control plane components:

1. **kube-apiserver port configuration issue**:
   - The kube-apiserver is configured to connect to etcd on the wrong port (2380 instead of 2379)
   - Identify the incorrect port configuration and fix it

2. **kubelet service stopped**:
   - The kubelet service is stopped on node01
   - Restart the kubelet service

3. **kube-scheduler unknown flag error**:
   - The kube-scheduler is failing to start due to an unknown flag
   - Identify and remove the invalid flag

4. **kube-apiserver certificate path issue**:
   - The kube-apiserver is failing to start due to a missing certificate file
   - Identify the certificate path issue and correct it

## Analysis and Troubleshooting

### 1. kube-apiserver etcd port issue

Check the kube-apiserver connection errors in the logs:
```bash
cat logs/apiserver-port-error.log
```

Examine the kube-apiserver configuration:
```bash
cat logs/apiserver-config.yaml
```

Notice that the kube-apiserver is configured to connect to etcd on port 2380 instead of the correct port 2379:
```yaml
- --etcd-servers=https://127.0.0.1:2380
```

To fix this issue, update the kube-apiserver configuration to use the correct etcd port (2379):
```bash
# In a real environment, you would edit the file directly:
# sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml

# For this task, create a fixed version:
sed 's/--etcd-servers=https:\/\/127.0.0.1:2380/--etcd-servers=https:\/\/127.0.0.1:2379/g' logs/apiserver-config.yaml > logs/apiserver-config-fixed.yaml
```

### 2. kubelet service stopped

Check the kubelet service status:
```bash
cat logs/kubelet-stopped.log
```

The logs show that the kubelet service has been stopped:
```
The unit kubelet.service has successfully entered the 'dead' state.
```

To fix this issue, restart the kubelet service:
```bash
# In a real environment, you would run:
# sudo systemctl start kubelet

# For this task, simulate the restart:
echo "Restarting kubelet service..." > logs/kubelet-restart.log
echo "kubelet.service: Started successfully." >> logs/kubelet-restart.log
```

### 3. kube-scheduler unknown flag error

Check the kube-scheduler error logs:
```bash
cat logs/scheduler-flag-error.log
```

The logs show an error with an unknown flag:
```
Error: unknown flag: --author
```

Examine the kube-scheduler configuration:
```bash
cat logs/scheduler-config.yaml
```

Notice the invalid flag in the command arguments:
```yaml
- --author=JohnDoe
```

To fix this issue, remove the invalid flag from the kube-scheduler configuration:
```bash
# In a real environment, you would edit the file directly:
# sudo vi /etc/kubernetes/manifests/kube-scheduler.yaml

# For this task, create a fixed version:
grep -v "\- --author=JohnDoe" logs/scheduler-config.yaml > logs/scheduler-config-fixed.yaml
```

### 4. kube-apiserver certificate path issue

Check the kube-apiserver certificate error logs:
```bash
cat logs/apiserver-cert-error.log
```

The logs show an error with a missing certificate file:
```
err="open /etc/k8s/pki/ca.crt: no such file or directory"
```

The issue is that the certificate file is being looked for in `/etc/k8s/pki/ca.crt`, but the standard path is `/etc/kubernetes/pki/ca.crt`.

To fix this issue, you would either need to update the configuration to use the correct path or create a symbolic link:
```bash
# In a real environment, you would run:
# sudo mkdir -p /etc/k8s/pki
# sudo ln -s /etc/kubernetes/pki/ca.crt /etc/k8s/pki/ca.crt

# For this task, simulate the fix:
echo "Creating symbolic link from /etc/kubernetes/pki/ca.crt to /etc/k8s/pki/ca.crt" > logs/cert-fix.log
```

## Verification

To verify that your fixes have resolved the issues, you would typically:

1. Check the status of the control plane components:
   ```bash
   kubectl get pods -n kube-system
   ```

2. Verify the kube-apiserver is connecting to etcd:
   ```bash
   kubectl logs -n kube-system kube-apiserver-<node-name>
   ```

3. Check the kubelet service status:
   ```bash
   systemctl status kubelet
   ```

4. Verify the kube-scheduler is running without errors:
   ```bash
   kubectl logs -n kube-system kube-scheduler-<node-name>
   ```

## Success Criteria
- The kube-apiserver is configured to connect to etcd on port 2379
- The kubelet service is running
- The kube-scheduler is running without the invalid flag
- The kube-apiserver can find the certificate files in the correct path

## Troubleshooting Tips

1. **Log analysis**: Always start by examining the logs for error messages
   ```bash
   journalctl -u kube-apiserver
   journalctl -u kubelet
   kubectl logs -n kube-system kube-scheduler-<node-name>
   ```

2. **Configuration validation**: Check the configuration files for syntax errors or misconfigurations
   ```bash
   kubectl -n kube-system get pod kube-apiserver-<node-name> -o yaml
   ```

3. **Service status**: Check the status of systemd services
   ```bash
   systemctl status kubelet
   ```

4. **Certificate paths**: Verify that certificates exist in the expected locations
   ```bash
   ls -la /etc/kubernetes/pki/
   ```

5. **Port verification**: Confirm that services are listening on the expected ports
   ```bash
   netstat -tuln | grep <port>
