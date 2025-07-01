#!/bin/bash
set -ex

# Update system packages
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to the docker group so they can run docker commands without sudo
# This change takes effect after the user logs in again, or if a new shell is started.
sudo usermod -a -G docker ec2-user

# Install Kind (Kubernetes in Docker)
# Using v0.20.0, check kind.sigs.k8s.io for the absolute latest stable version if needed.
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-arm64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
rm -f ./kind # Clean up the downloaded binary

# Install Kubectl (Kubernetes command-line tool)
# Using the latest stable version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f ./kubectl # Clean up the downloaded binary

# --- Create the Kind cluster configuration file on the EC2 instance ---
# This ensures kind.yaml is present when 'kind create cluster' is called.
# The file will be created in the current user's home directory (/home/ec2-user/)
cat <<EOF > /home/ec2-user/kind.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000 # Map port 30000 from the container to the host for NodePort
    hostPort: 30000
    listenAddress: "0.0.0.0"
    protocol: tcp
EOF

# Create the Kind cluster using the generated config file
# This command will be run as root by the user-data script.
kind create cluster --name clo835-cluster --config /home/ec2-user/kind.yaml

# Optional: Set kubectl context (useful if you log in interactively later)
# kubectl cluster-info --context kind-clo85-cluster # Uncomment if you want to set context automatically

