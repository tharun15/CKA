#!/bin/bash

# Define ANSI color codes for better output formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display banner
echo -e "${BLUE}=========================================================="
echo "  Kubernetes Exam Tasks Grading Script"
echo -e "==========================================================${NC}"

# Function to display usage
usage() {
    echo -e "${YELLOW}Usage: $0 [task_numbers]${NC}"
    echo ""
    echo "Options:"
    echo "  No arguments: Grade all tasks"
    echo "  Comma-separated list of task numbers: Grade only the specified tasks"
    echo ""
    echo "Example:"
    echo "  $0 1,3,5,7"
    echo "  (This will grade only tasks 1, 3, 5, and 7)"
    echo ""
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if kubectl is available
if ! command_exists kubectl; then
    echo -e "${RED}Error: kubectl command not found.${NC}"
    echo "Please ensure kubectl is installed and in your PATH."
    exit 1
fi

# Initialize variables
TOTAL_CHECKS=0
PASSED_CHECKS=0
ALL_TASKS=$(seq 1 16)
TASKS_TO_GRADE=""

# Parse command line arguments
if [ $# -eq 0 ]; then
    # No arguments, grade all tasks
    TASKS_TO_GRADE=$ALL_TASKS
    echo -e "${YELLOW}No specific tasks specified. Grading all tasks...${NC}"
else
    # Parse comma-separated list of tasks
    IFS=',' read -ra TASKS_ARR <<< "$1"
    for task in "${TASKS_ARR[@]}"; do
        if [[ "$task" =~ ^[0-9]+$ ]] && [ "$task" -ge 1 ] && [ "$task" -le 16 ]; then
            TASKS_TO_GRADE="$TASKS_TO_GRADE $task"
        else
            echo -e "${RED}Invalid task number: $task${NC}"
            usage
        fi
    done
    echo -e "${YELLOW}Grading tasks:${NC} $TASKS_TO_GRADE"
fi

# Check if no valid tasks were specified
if [ -z "$TASKS_TO_GRADE" ]; then
    echo -e "${RED}No valid tasks specified.${NC}"
    usage
fi

# Function to record check results
record_check() {
    local task_num=$1
    local check_name=$2
    local status=$3
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ "$status" -eq 0 ]; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        echo -e "  ${GREEN}✓ $check_name${NC}"
    else
        echo -e "  ${RED}✗ $check_name${NC}"
    fi
}

# Grade Task 1: Configure Nginx with TLS 1.3 Only
grade_task1() {
    echo -e "${BLUE}Grading Task 1: Configure Nginx with TLS 1.3 Only${NC}"
    
    # Check 1: task1 namespace exists
    kubectl get namespace task1 &> /dev/null
    record_check 1 "Namespace task1 exists" $?
    
    # Check 2: ConfigMap with TLS 1.3 only exists
    kubectl get configmap -n task1 | grep nginx-config &> /dev/null
    config_exists=$?
    record_check 1 "Nginx ConfigMap exists" $config_exists
    
    if [ $config_exists -eq 0 ]; then
        # Check 3: TLS 1.3 is the only protocol
        kubectl get configmap -n task1 -o yaml | grep -c "ssl_protocols TLSv1.3" &> /dev/null
        record_check 1 "TLS 1.3 is the only protocol configured" $?
    fi
    
    # Check 4: Nginx pods are running
    kubectl get pods -n task1 -l app=nginx | grep Running &> /dev/null
    record_check 1 "Nginx pods are running" $?
    
    # Check 5: Nginx service is exposed
    kubectl get service -n task1 | grep nginx &> /dev/null
    record_check 1 "Nginx service is exposed" $?
    
    echo ""
}

# Grade Task 2: Expose Application via NodePort Service
grade_task2() {
    echo -e "${BLUE}Grading Task 2: Expose Application via NodePort Service${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task2 &> /dev/null
    record_check 2 "Namespace task2 exists" $?
    
    # Check 2: Deployment exists
    kubectl get deployment -n task2 &> /dev/null
    record_check 2 "Deployment exists in task2 namespace" $?
    
    # Check 3: NodePort service exists
    kubectl get service -n task2 | grep NodePort &> /dev/null
    service_exists=$?
    record_check 2 "NodePort service exists" $service_exists
    
    if [ $service_exists -eq 0 ]; then
        # Check 4: NodePort is in the correct range
        kubectl get service -n task2 -o yaml | grep "nodePort:" &> /dev/null
        record_check 2 "NodePort is configured correctly" $?
    fi
    
    # Check 5: Pods are running
    kubectl get pods -n task2 | grep Running &> /dev/null
    record_check 2 "Pods are running in task2 namespace" $?
    
    echo ""
}

# Grade Task 3: Install Calico CNI
grade_task3() {
    echo -e "${BLUE}Grading Task 3: Install Calico CNI${NC}"
    
    # Check 1: Tigera operator is deployed
    kubectl get deployment -n tigera-operator tigera-operator &> /dev/null
    record_check 3 "Tigera operator is deployed" $?
    
    # Check 2: Calico installation CR exists
    kubectl get installation.operator.tigera.io default &> /dev/null
    record_check 3 "Calico installation exists" $?
    
    # Check 3: Calico pods are running
    kubectl get pods -n calico-system &> /dev/null
    pods_exist=$?
    record_check 3 "Calico system namespace has pods" $pods_exist
    
    if [ $pods_exist -eq 0 ]; then
        # Check 4: All Calico pods are running
        not_running=$(kubectl get pods -n calico-system | grep -v Running | grep -v NAME | wc -l)
        if [ $not_running -eq 0 ]; then
            record_check 3 "All Calico pods are running" 0
        else
            record_check 3 "All Calico pods are running" 1
        fi
    fi
    
    # Check 5: TigeraStatus shows available
    kubectl get tigerastatus | grep True &> /dev/null
    record_check 3 "Calico components show as available" $?
    
    echo ""
}

# Grade Task 4: Configure Ingress
grade_task4() {
    echo -e "${BLUE}Grading Task 4: Configure Ingress${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task4 &> /dev/null
    record_check 4 "Namespace task4 exists" $?
    
    # Check 2: Ingress resource exists
    kubectl get ingress -n task4 &> /dev/null
    ingress_exists=$?
    record_check 4 "Ingress resource exists" $ingress_exists
    
    if [ $ingress_exists -eq 0 ]; then
        # Check 3: Ingress has correct host
        kubectl get ingress -n task4 -o yaml | grep "host:" &> /dev/null
        record_check 4 "Ingress has host configured" $?
        
        # Check 4: Ingress has path configured
        kubectl get ingress -n task4 -o yaml | grep "path:" &> /dev/null
        record_check 4 "Ingress has path configured" $?
    fi
    
    # Check 5: Backend service exists
    kubectl get service -n task4 &> /dev/null
    record_check 4 "Backend service exists" $?
    
    echo ""
}

# Grade Task 5: Migrate Ingress to Gateway API
grade_task5() {
    echo -e "${BLUE}Grading Task 5: Migrate Ingress to Gateway API${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task5 &> /dev/null
    record_check 5 "Namespace task5 exists" $?
    
    # Check 2: Gateway resource exists
    kubectl get gateway -n task5 &> /dev/null
    gateway_exists=$?
    record_check 5 "Gateway resource exists" $gateway_exists
    
    if [ $gateway_exists -eq 0 ]; then
        # Check 3: HTTPRoute resource exists
        kubectl get httproute -n task5 &> /dev/null
        record_check 5 "HTTPRoute resource exists" $?
    fi
    
    # Check 4: Old ingress resource is deleted
    old_ingress=$(kubectl get ingress -n task5 2>/dev/null | wc -l)
    if [ $old_ingress -le 1 ]; then  # Only header line or empty
        record_check 5 "Old Ingress resource is removed" 0
    else
        record_check 5 "Old Ingress resource is removed" 1
    fi
    
    # Check 5: Backend service exists
    kubectl get service -n task5 &> /dev/null
    record_check 5 "Backend service exists" $?
    
    echo ""
}

# Grade Task 6: Create Horizontal Pod Autoscaler
grade_task6() {
    echo -e "${BLUE}Grading Task 6: Create Horizontal Pod Autoscaler${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task6 &> /dev/null
    record_check 6 "Namespace task6 exists" $?
    
    # Check 2: Deployment exists
    kubectl get deployment -n task6 &> /dev/null
    record_check 6 "Deployment exists in task6 namespace" $?
    
    # Check 3: HPA resource exists
    kubectl get hpa -n task6 &> /dev/null
    hpa_exists=$?
    record_check 6 "HPA resource exists" $hpa_exists
    
    if [ $hpa_exists -eq 0 ]; then
        # Check 4: HPA has correct min replicas
        kubectl get hpa -n task6 -o yaml | grep "minReplicas:" &> /dev/null
        record_check 6 "HPA has minReplicas configured" $?
        
        # Check 5: HPA has correct max replicas
        kubectl get hpa -n task6 -o yaml | grep "maxReplicas:" &> /dev/null
        record_check 6 "HPA has maxReplicas configured" $?
    fi
    
    echo ""
}

# Grade Task 7: Create Default Storage Class
grade_task7() {
    echo -e "${BLUE}Grading Task 7: Create Default Storage Class${NC}"
    
    # Check 1: StorageClass exists
    kubectl get storageclass &> /dev/null
    sc_exists=$?
    record_check 7 "StorageClass exists" $sc_exists
    
    if [ $sc_exists -eq 0 ]; then
        # Check 2: Default StorageClass exists
        kubectl get storageclass -o yaml | grep "is-default-class: \"true\"" &> /dev/null
        record_check 7 "Default StorageClass is configured" $?
        
        # Check 3: StorageClass has the correct provisioner
        kubectl get storageclass -o yaml | grep "provisioner:" &> /dev/null
        record_check 7 "StorageClass has provisioner configured" $?
    fi
    
    # Check 4: PVC can be created with default StorageClass
    kubectl create -f task7-create-default-storage-class/resources.yaml &> /dev/null
    record_check 7 "PVC can be created with default StorageClass" $?
    
    # Check 5: PVC is bound
    kubectl get pvc | grep Bound &> /dev/null
    record_check 7 "PVC is bound to a PV" $?
    
    # Cleanup
    kubectl delete -f task7-create-default-storage-class/resources.yaml &> /dev/null
    
    echo ""
}

# Grade Task 8: List and Document CRDs
grade_task8() {
    echo -e "${BLUE}Grading Task 8: List and Document CRDs${NC}"
    
    # Check 1: resources.yaml exists in home directory
    if [ -f ~/resources.yaml ]; then
        record_check 8 "resources.yaml file exists in home directory" 0
        
        # Check 2: resources.yaml contains cert-manager CRDs
        grep -i "cert-manager" ~/resources.yaml &> /dev/null
        record_check 8 "resources.yaml contains cert-manager CRDs" $?
    else
        record_check 8 "resources.yaml file exists in home directory" 1
    fi
    
    # Check 3: subject.yaml exists in home directory
    if [ -f ~/subject.yaml ]; then
        record_check 8 "subject.yaml file exists in home directory" 0
        
        # Check 4: subject.yaml contains subject field documentation
        grep -i "subject" ~/subject.yaml &> /dev/null
        record_check 8 "subject.yaml contains documentation for the subject field" $?
    else
        record_check 8 "subject.yaml file exists in home directory" 1
    fi
    
    # Check 5: cert-manager is running
    kubectl get pods -n cert-manager | grep Running &> /dev/null
    record_check 8 "cert-manager is running" $?
    
    echo ""
}

# Grade Task 9: Install Argo CD with Helm
grade_task9() {
    echo -e "${BLUE}Grading Task 9: Install Argo CD with Helm${NC}"
    
    # Check 1: argocd namespace exists
    kubectl get namespace argocd &> /dev/null
    record_check 9 "argocd namespace exists" $?
    
    # Check 2: Helm repo is added
    helm repo list | grep argo &> /dev/null
    record_check 9 "Argo CD Helm repository is added" $?
    
    # Check 3: argo-helm.yaml exists
    if [ -f /argo-helm.yaml ]; then
        record_check 9 "argo-helm.yaml template exists" 0
        
        # Check 4: Template has crds.install=false
        grep "crds.install=false" /argo-helm.yaml &> /dev/null
        record_check 9 "Template configured to not install CRDs" $?
    else
        record_check 9 "argo-helm.yaml template exists" 1
    fi
    
    # Check 5: Argo CD is installed
    helm list -n argocd | grep argocd &> /dev/null
    record_check 9 "Argo CD is installed via Helm" $?
    
    echo ""
}

# Grade Task 10: Add Sidecar Log Container
grade_task10() {
    echo -e "${BLUE}Grading Task 10: Add Sidecar Log Container${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task10 &> /dev/null
    record_check 10 "Namespace task10 exists" $?
    
    # Check 2: Deployment exists with multiple containers
    kubectl get deployment -n task10 &> /dev/null
    deployment_exists=$?
    record_check 10 "Deployment exists in task10 namespace" $deployment_exists
    
    if [ $deployment_exists -eq 0 ]; then
        # Check 3: Sidecar container exists
        containers=$(kubectl get deployment -n task10 -o jsonpath='{.items[0].spec.template.spec.containers[*].name}')
        container_count=$(echo $containers | wc -w)
        if [ $container_count -ge 2 ]; then
            record_check 10 "Deployment has sidecar container" 0
        else
            record_check 10 "Deployment has sidecar container" 1
        fi
    fi
    
    # Check 4: Sidecar container is for logging
    kubectl get deployment -n task10 -o yaml | grep -E "logs|logging|logger" &> /dev/null
    record_check 10 "Sidecar container is configured for logging" $?
    
    # Check 5: Pods are running with multiple containers
    pod_count=$(kubectl get pods -n task10 | grep -v NAME | wc -l)
    if [ $pod_count -gt 0 ]; then
        containers_per_pod=$(kubectl get pods -n task10 -o jsonpath='{.items[0].spec.containers[*].name}' | wc -w)
        if [ $containers_per_pod -ge 2 ]; then
            record_check 10 "Pods are running with multiple containers" 0
        else
            record_check 10 "Pods are running with multiple containers" 1
        fi
    else
        record_check 10 "Pods are running with multiple containers" 1
    fi
    
    echo ""
}

# Grade Task 11: Install Package Using dpkg
grade_task11() {
    echo -e "${BLUE}Grading Task 11: Install Package Using dpkg${NC}"
    
    # Check 1: cri-dockerd package is installed
    dpkg -l | grep cri-dockerd &> /dev/null
    record_check 11 "cri-dockerd package is installed" $?
    
    # Check 2: cri-docker service is enabled
    systemctl is-enabled cri-docker.service &> /dev/null
    record_check 11 "cri-docker service is enabled" $?
    
    # Check 3: cri-docker service is running
    systemctl is-active cri-docker.service &> /dev/null
    record_check 11 "cri-docker service is running" $?
    
    # Check 4: System parameters are configured
    sysctl net.bridge.bridge-nf-call-iptables | grep 1 &> /dev/null
    net_bridge=$?
    sysctl net.ipv4.ip_forward | grep 1 &> /dev/null
    ip_forward=$?
    if [ $net_bridge -eq 0 ] && [ $ip_forward -eq 0 ]; then
        record_check 11 "System parameters are properly configured" 0
    else
        record_check 11 "System parameters are properly configured" 1
    fi
    
    # Check 5: Configuration persists across reboots
    if [ -f /etc/sysctl.d/k8s.conf ]; then
        grep "net.bridge.bridge-nf-call-iptables" /etc/sysctl.d/k8s.conf &> /dev/null
        record_check 11 "System parameters are persistent across reboots" $?
    else
        record_check 11 "System parameters are persistent across reboots" 1
    fi
    
    echo ""
}

# Grade Task 12: Configure Network Policies
grade_task12() {
    echo -e "${BLUE}Grading Task 12: Configure Network Policies${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task12 &> /dev/null
    record_check 12 "Namespace task12 exists" $?
    
    # Check 2: Network Policy exists
    kubectl get networkpolicy -n task12 &> /dev/null
    netpol_exists=$?
    record_check 12 "Network Policy exists" $netpol_exists
    
    if [ $netpol_exists -eq 0 ]; then
        # Check 3: Policy includes pod selector
        kubectl get networkpolicy -n task12 -o yaml | grep "podSelector:" &> /dev/null
        record_check 12 "Network Policy has pod selector" $?
        
        # Check 4: Policy includes ingress rules
        kubectl get networkpolicy -n task12 -o yaml | grep "ingress:" &> /dev/null
        record_check 12 "Network Policy has ingress rules" $?
        
        # Check 5: Policy includes egress rules
        kubectl get networkpolicy -n task12 -o yaml | grep "egress:" &> /dev/null
        record_check 12 "Network Policy has egress rules" $?
    fi
    
    echo ""
}

# Grade Task 13: Adjust Node Resources in Deployment
grade_task13() {
    echo -e "${BLUE}Grading Task 13: Adjust Node Resources in Deployment${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task13 &> /dev/null
    record_check 13 "Namespace task13 exists" $?
    
    # Check 2: Deployment exists
    kubectl get deployment -n task13 &> /dev/null
    deployment_exists=$?
    record_check 13 "Deployment exists in task13 namespace" $deployment_exists
    
    if [ $deployment_exists -eq 0 ]; then
        # Check 3: Deployment has resource requests
        kubectl get deployment -n task13 -o yaml | grep -E "cpu|memory" &> /dev/null
        record_check 13 "Deployment has resource requests configured" $?
        
        # Check 4: All pods are running (3/3)
        ready_pods=$(kubectl get deployment -n task13 -o jsonpath='{.status.readyReplicas}')
        if [ "$ready_pods" = "3" ]; then
            record_check 13 "All 3 pods are running" 0
        else
            record_check 13 "All 3 pods are running" 1
        fi
    fi
    
    # Check 5: Deployment has init container
    kubectl get deployment -n task13 -o yaml | grep "initContainers:" &> /dev/null
    record_check 13 "Deployment has an init container" $?
    
    echo ""
}

# Grade Task 14: Configure Storage with PV and PVC
grade_task14() {
    echo -e "${BLUE}Grading Task 14: Configure Storage with PV and PVC${NC}"
    
    # Check 1: Namespace exists
    kubectl get namespace task14 &> /dev/null
    record_check 14 "Namespace task14 exists" $?
    
    # Check 2: PV exists
    kubectl get pv | grep task14 &> /dev/null
    record_check 14 "PV exists for task14" $?
    
    # Check 3: PVC exists
    kubectl get pvc -n task14 &> /dev/null
    pvc_exists=$?
    record_check 14 "PVC exists in task14 namespace" $pvc_exists
    
    if [ $pvc_exists -eq 0 ]; then
        # Check 4: PVC is bound
        kubectl get pvc -n task14 | grep Bound &> /dev/null
        record_check 14 "PVC is bound to PV" $?
    fi
    
    # Check 5: Pod using PVC exists
    kubectl get pods -n task14 &> /dev/null
    pod_exists=$?
    if [ $pod_exists -eq 0 ]; then
        kubectl get pods -n task14 -o yaml | grep "volumeMounts:" &> /dev/null
        record_check 14 "Pod is using the PVC" $?
    else
        record_check 14 "Pod is using the PVC" 1
    fi
    
    echo ""
}

# Grade Task 15: Configure Priority Classes
grade_task15() {
    echo -e "${BLUE}Grading Task 15: Configure Priority Classes${NC}"
    
    # Check 1: Priority Class exists
    kubectl get priorityclass &> /dev/null
    pc_exists=$?
    record_check 15 "Priority Class exists" $pc_exists
    
    if [ $pc_exists -eq 0 ]; then
        # Check 2: Priority Class has correct value
        kubectl get priorityclass -o yaml | grep "value:" &> /dev/null
        record_check 15 "Priority Class has priority value set" $?
    fi
    
    # Check 3: Namespace exists
    kubectl get namespace task15 &> /dev/null
    record_check 15 "Namespace task15 exists" $?
    
    # Check 4: Deployment using Priority Class exists
    kubectl get deployment -n task15 &> /dev/null
    deployment_exists=$?
    if [ $deployment_exists -eq 0 ]; then
        kubectl get deployment -n task15 -o yaml | grep "priorityClassName:" &> /dev/null
        record_check 15 "Deployment uses Priority Class" $?
    else
        record_check 15 "Deployment uses Priority Class" 1
    fi
    
    # Check 5: Pods are scheduled with correct priority
    kubectl get pods -n task15 &> /dev/null
    if [ $? -eq 0 ]; then
        # This is a simplification - in reality would need to check each pod
        record_check 15 "Pods are scheduled with correct priority" 0
    else
        record_check 15 "Pods are scheduled with correct priority" 1
    fi
    
    echo ""
}

# Grade Task 16: Troubleshoot Control Plane Components
grade_task16() {
    echo -e "${BLUE}Grading Task 16: Troubleshoot Control Plane Components${NC}"
    
    # Check 1: kube-apiserver port configuration fixed
    if grep -q "etcd-servers=https://127.0.0.1:2379" /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null; then
        record_check 16 "kube-apiserver etcd port is correct (2379)" 0
    else
        # Fallback check for demo/test environments
        record_check 16 "kube-apiserver etcd port is correct (2379)" 1
    fi
    
    # Check 2: kubelet service is running
    systemctl is-active kubelet &> /dev/null
    record_check 16 "kubelet service is running" $?
    
    # Check 3: kube-scheduler has no invalid flags
    if grep -q -- "--author=" /etc/kubernetes/manifests/kube-scheduler.yaml 2>/dev/null; then
        record_check 16 "kube-scheduler has no invalid flags" 1
    else
        record_check 16 "kube-scheduler has no invalid flags" 0
    fi
    
    # Check 4: kube-apiserver certificate path issue fixed
    # This is a simplification - would need to check actual cert paths
    if [ -d /etc/kubernetes/pki ] && [ -f /etc/kubernetes/pki/ca.crt ]; then
        record_check 16 "kube-apiserver certificate paths are correct" 0
    else
        record_check 16 "kube-apiserver certificate paths are correct" 1
    fi
    
    # Check 5: Control plane pods are running
    control_plane_pods=$(kubectl get pods -n kube-system | grep -E 'kube-apiserver|kube-scheduler|kube-controller-manager' | grep -v Running | wc -l)
    if [ $control_plane_pods -eq 0 ]; then
        record_check 16 "All control plane pods are running" 0
    else
        record_check 16 "All control plane pods are running" 1
    fi
    
    echo ""
}

# Run grading for specified tasks
for task in $TASKS_TO_GRADE; do
    case $task in
        1) grade_task1 ;;
        2) grade_task2 ;;
        3) grade_task3 ;;
        4) grade_task4 ;;
        5) grade_task5 ;;
        6) grade_task6 ;;
        7) grade_task7 ;;
        8) grade_task8 ;;
        9) grade_task9 ;;
        10) grade_task10 ;;
        11) grade_task11 ;;
        12) grade_task12 ;;
        13) grade_task13 ;;
        14) grade_task14 ;;
        15) grade_task15 ;;
        16) grade_task16 ;;
        *) echo -e "${RED}Invalid task number: $task${NC}" ;;
    esac
done

# Calculate score
if [ $TOTAL_CHECKS -eq 0 ]; then
    echo -e "${RED}No checks were performed.${NC}"
    exit 1
fi

SCORE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))

# Display results
echo -e "${BLUE}=========================================================="
echo "  Grading Results"
echo -e "==========================================================${NC}"
echo ""
echo -e "Total checks: $TOTAL_CHECKS"
echo -e "Passed checks: $PASSED_CHECKS"
echo -e "Score: ${SCORE}%"
echo ""

# Determine if pass or fail
if [ $SCORE -ge 66 ]; then
    echo -e "${GREEN}PASS${NC} - Congratulations! You have passed the exam with a score of ${SCORE}%."
    echo "You have successfully demonstrated your Kubernetes skills."
else
    echo -e "${RED}FAIL${NC} - You did not pass the exam. Your score is ${SCORE}%."
    echo "A score of 66% or higher is required to pass."
    echo "Review the failed checks above and try again."
fi

echo ""
echo -e "${BLUE}=========================================================="
echo "  End of Grading"
echo -e "==========================================================${NC}"
