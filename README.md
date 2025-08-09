# Kubernetes Exam Practice Tasks

Welcome to the Kubernetes Exam Practice repository! This repository contains a collection of hands-on tasks designed to help you prepare for the Certified Kubernetes Administrator (CKA) and similar Kubernetes certification exams.

## Repository Overview

This repository contains multiple task directories, each focusing on a specific Kubernetes concept or scenario. The tasks are designed to simulate real-world problems and challenges that you might encounter in a Kubernetes environment, similar to what you would see in certification exams.

## Environment Options

You have several options for running these tasks:

1. **KillerCoda Playground (Recommended)**: 
   - Use the free KillerCoda Kubernetes playground at [killercoda.com](https://killercoda.com/kubernetes)
   - Provides a real Kubernetes environment with a 1-hour session limit
   - No setup required - everything is preconfigured and ready to use
   - Perfect for quick practice sessions

2. **Local Kubernetes Cluster**:
   - Use tools like Minikube, kind, or k3d to set up a local Kubernetes cluster
   - Great for longer practice sessions without time limits
   - Requires more setup but gives you full control

3. **Cloud Provider Kubernetes**:
   - Use a managed Kubernetes service from cloud providers (GKE, EKS, AKS)
   - Most similar to production environments
   - May incur costs

## How to Use This Repository

1. **Choose a task**: Browse through the available tasks and select one that focuses on the Kubernetes concept you want to practice.

2. **Read the task description**: Each task directory contains a `taskX.md` file (where X is the task number) that describes the scenario, background, and objectives.

3. **Set up the task environment**: Run the `execute.sh` script in the task directory to set up the necessary environment:
   ```bash
   cd task<number>-<task-name>
   chmod +x execute.sh
   ./execute.sh
   ```

4. **Complete the task**: Follow the instructions in the README.md file within each task directory to complete the task.

5. **Verify your solution**: Each task includes verification steps or success criteria to help you determine if you've successfully completed the task.

## Available Tasks

| Task | Description | Key Concepts |
|------|-------------|-------------|
| 1 | Configure Nginx with TLS 1.3 Only | ConfigMaps, TLS, Nginx |
| 2 | Expose Application via NodePort Service | Services, NodePort |
| 3 | Install Calico CNI | Container Network Interface, Calico |
| 4 | Configure Ingress | Ingress, Networking |
| 5 | Migrate Ingress to Gateway API | Gateway API, Networking |
| 6 | Create Horizontal Pod Autoscaler | HPA, Scaling |
| 7 | Create Default Storage Class | Storage, StorageClass |
| 8 | List and Document CRDs | Custom Resource Definitions |
| 9 | Install Argo CD with Helm | Helm, Argo CD |
| 10 | Add Sidecar Log Container | Pods, Containers, Logging |
| 11 | Install Package Using dpkg | Linux, dpkg, System Configuration |
| 12 | Configure Network Policies | Network Policies, Security |
| 13 | Adjust Node Resources in Deployment | Resource Management, Deployments |
| 14 | Configure Storage with PV and PVC | Persistent Volumes, Storage |
| 15 | Configure Priority Classes | Pod Priority, Scheduling |
| 16 | Troubleshoot Control Plane Components | Troubleshooting, Control Plane |

## Task Structure

Each task directory contains the following files:

- **execute.sh**: A script to set up the task environment
- **README.md**: Detailed instructions for completing the task
- **taskX.md**: A description of the task, including background and objectives
- **resources.yaml** (if applicable): Kubernetes resource definitions needed for the task

## Grading Your Work

A grading script (`grade.sh`) is included to help you evaluate your progress:

```bash
chmod +x grade.sh
./grade.sh            # Grade all tasks
./grade.sh 1,3,5,7    # Grade only specific tasks
```

The grading script:
- Checks 3-5 specific requirements for each task
- Calculates a percentage score based on your completed checks
- Provides a PASS/FAIL result (passing requires ≥66%)
- Gives detailed feedback on what passed and what needs improvement

The script can grade any combination of tasks you specify, making it flexible for focused practice.

### Creating Your Own Grading Checks

You can modify `grade.sh` to add your own checks or change the passing criteria. Here's how the grading works:

1. Each task has 3-5 checks (e.g., "namespace exists", "deployment is running")
2. The script counts total checks and passed checks
3. It calculates: score = (passed_checks / total_checks) * 100
4. If score ≥ 66%, you pass; otherwise, more practice is needed

## Prerequisites

To complete these tasks, you should have:

1. A Kubernetes environment (KillerCoda playground, local cluster, or cloud provider)
2. kubectl CLI installed and configured
3. Basic knowledge of Kubernetes concepts
4. Additional tools required for specific tasks (e.g., Helm, dpkg)

## Using KillerCoda Playgrounds

For the best experience with these tasks, we recommend using KillerCoda:

1. Go to [killercoda.com/kubernetes](https://killercoda.com/kubernetes)
2. Start a new Kubernetes playground scenario
3. Clone this repository: `git clone https://github.com/username/ckaexam2025.git`
4. Navigate to the task directory and run the execute.sh script
5. Complete the task within the 1-hour session limit
6. If your session expires, simply start a new playground

## Learning Path

If you're new to Kubernetes, we recommend following the tasks in numerical order, as they generally progress from basic to more advanced concepts. However, if you're focusing on specific areas, feel free to jump to the relevant tasks.

## Tips for Success

1. **Read the task carefully**: Make sure you understand the requirements before starting.
2. **Check the logs**: If something isn't working, check the logs for clues.
3. **Use kubectl explain**: This command is invaluable for understanding resource fields and requirements.
4. **Refer to documentation**: Use the official Kubernetes documentation when needed.
5. **Practice time management**: Set a time limit for each task to simulate exam conditions.

## Feedback and Contributions

If you find issues with any task or want to suggest improvements, please submit a pull request or create an issue. Contributions to enhance the tasks or add new ones are welcome!

## License

This repository is available under the MIT License. See the LICENSE file for more details.

---

Happy learning and good luck with your Kubernetes certification journey!
