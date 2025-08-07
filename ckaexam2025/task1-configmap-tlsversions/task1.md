Task: Secure Nginx Web Server with TLS 1.3 Only
Background
In this task, you'll be enhancing the security of an Nginx web server by enforcing TLS 1.3 only, disabling support for the older TLS 1.2 protocol. This will improve the security posture of your application by requiring clients to use the latest TLS protocol version.

Objective
Configure the Nginx web server to accept connections only using TLS 1.3 and reject any connections attempting to use TLS 1.2 or older protocols.

Resources
The Kubernetes resources are provided in the task1/resources.yaml file, which includes:

A ConfigMap containing the Nginx configuration
A TLS Secret with certificate and key
A Deployment running the Nginx container
A Service exposing the Nginx deployment