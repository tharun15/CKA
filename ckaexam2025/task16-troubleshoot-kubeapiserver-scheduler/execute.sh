#!/bin/bash

# Display banner
echo "==================================================="
echo "  Troubleshoot Kubernetes Control Plane Components"
echo "==================================================="

# Create logs directory if it doesn't exist
mkdir -p logs

# Create sample error logs for kube-apiserver port issue
cat > logs/apiserver-port-error.log << 'EOF'
2025-06-28T19:39:59.492331715Z stderr F W0628 19:39:59.492245       1 logging.go:55] [core] [Channel #2 SubChannel #0] addrConn.createTransport failed to connect to {Addr: "127.0.0.1:2359", ServerName: "127.0.0.1:2359", }. Err: connectr: desc = "transport: Error while dialing: dial tcp 127.0.0.1:2359: connect: connection refused"
2025-06-28T19:39:59.492492739Z stderr F W0628 19:39:59.492452       1 logging.go:55] [core] [Channel #1 SubChannel #0] addrConn.createTransport failed to connect to {Addr: "127.0.0.1:2359", ServerName: "127.0.0.1:2359", }. Err: connectr: desc = "transport: Error while dialing: dial tcp 127.0.0.1:2359: connect: connection refused"
2025-06-28T19:39:59.492989595Z stderr F W0628 19:39:59.492939       1 logging.go:55] [core] [Channel #5 SubChannel #0] addrConn.createTransport failed to connect to {Addr: "127.0.0.1:2359", ServerName: "127.0.0.1:2359", }. Err: connectr: desc = "transport: Error while dialing: dial tcp 127.0.0.1:2359: connect: connection refused"
EOF

# Create kubelet service stopped log
cat > logs/kubelet-stopped.log << 'EOF'
The job identifier is 3381.
Jun 28 19:14:04 node01 systemd[1]: kubelet.service: Deactivated successfully.
Subject: Unit succeeded
Defined-By: systemd
Support: http://www.ubuntu.com/support

The unit kubelet.service has successfully entered the 'dead' state.
Jun 28 19:14:04 node01 systemd[1]: Stopped kubelet.service - kubelet: The Kubernetes Node Agent.
Subject: A stop job for unit kubelet.service has finished
Defined-By: systemd
Support: http://www.ubuntu.com/support

A stop job for unit kubelet.service has finished.

The job identifier is 3381 and the job result is done.
Jun 28 19:14:04 node01 systemd[1]: kubelet.service: Consumed 31.716s CPU time.
Subject: Resources consumed by unit runtime
Defined-By: systemd
Support: http://www.ubuntu.com/support
EOF

# Create kube-scheduler unknown flag error log
cat > logs/scheduler-flag-error.log << 'EOF'
--log-flush-frequency duration        Maximum number of seconds between log flushes (default 5s)
--logging-format string               Sets the log format. Permitted formats: "json" (gated by LoggingBetaOptions), "text".
--v Level                             number for the log level verbosity
--vmodule pattern=N,...               comma-separated list of pattern=N settings for file-filtered logging

Global flags:
-h, --help                            help for kube-scheduler
      --version version[=true]        --version, --version=raw prints version information and quits; --version=vX.Y.Z... sets the reported version

Error: unknown flag: --author
controlplane:~$
EOF

# Create kube-apiserver certificate path error log
cat > logs/apiserver-cert-error.log << 'EOF'
controlplane:/var/log/pods/kube-system_kube-apiserver-controlplane_434a76fba36d08f039c4cf00/kube-apiserver/13# cat 9.log
2025-04-01T19:01:09.333725812Z stderr F W0401 19:01:09.333590       1 registry.go:256] can't set both ComponentGlobalsRegistry.AddFlags more than once, the registry will be set by the latest flags
2025-04-01T19:01:09.334557591Z stderr F I0401 19:01:09.334483       1 options.go:238] external host was not specified, using 172.30.1.2
2025-04-01T19:01:09.337778592Z stderr F I0401 19:01:09.337677       1 server.go:143] Version: v1.32.1
2025-04-01T19:01:09.338328354Z stderr F I0401 19:01:09.338153       1 server.go:145] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
2025-04-01T19:01:09.827058401Z stderr F E0401 19:01:09.826942       1 run.go:72] "Command failed" err="open /etc/k8s/pki/ca.crt: no such file or directory"
EOF

# Create kube-apiserver configuration file with wrong etcd port
cat > logs/apiserver-config.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 172.30.1.2:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=172.30.1.2
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=https://127.0.0.1:2380
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --secure-port=6443
    - --service-account-issuer=https://kubernetes.default.svc.cluster.local
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=10.96.0.0/12
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    image: registry.k8s.io/kube-apiserver:v1.32.1
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-apiserver
    resources:
      requests:
        cpu: 250m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/ca-certificates
      name: etc-ca-certificates
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /usr/local/share/ca-certificates
      name: usr-local-share-ca-certificates
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
  hostNetwork: true
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /usr/local/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-local-share-ca-certificates
  - hostPath:
      path: /usr/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-share-ca-certificates
status: {}
EOF

# Create kube-scheduler configuration file with invalid flag
cat > logs/scheduler-config.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-scheduler
    tier: control-plane
  name: kube-scheduler
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-scheduler
    - --authentication-kubeconfig=/etc/kubernetes/scheduler.conf
    - --authorization-kubeconfig=/etc/kubernetes/scheduler.conf
    - --bind-address=127.0.0.1
    - --kubeconfig=/etc/kubernetes/scheduler.conf
    - --leader-elect=true
    - --author=JohnDoe
    image: registry.k8s.io/kube-scheduler:v1.32.1
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10259
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-scheduler
    resources:
      requests:
        cpu: 100m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10259
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/kubernetes/scheduler.conf
      name: kubeconfig
      readOnly: true
  hostNetwork: true
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/kubernetes/scheduler.conf
      type: FileOrCreate
    name: kubeconfig
status: {}
EOF

echo "Task setup complete!"
echo ""
echo "Logs and configuration files have been created in the 'logs' directory."
echo "You can examine them to troubleshoot the Kubernetes control plane issues."
echo ""
echo "To start troubleshooting, check the following files:"
echo "1. logs/apiserver-port-error.log - kube-apiserver connection errors"
echo "2. logs/kubelet-stopped.log - kubelet service status"
echo "3. logs/scheduler-flag-error.log - kube-scheduler flag errors"
echo "4. logs/apiserver-cert-error.log - kube-apiserver certificate errors"
echo "5. logs/apiserver-config.yaml - kube-apiserver configuration"
echo "6. logs/scheduler-config.yaml - kube-scheduler configuration"
echo ""
echo "Follow the instructions in the README.md file to complete the troubleshooting task."
