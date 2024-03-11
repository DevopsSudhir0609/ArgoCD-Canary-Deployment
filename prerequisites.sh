#!/bin/bash

# Function to print error message and exit
handle_error() {
    echo "Error: $1"
    exit 1
}

# 1. Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh || handle_error "Failed to download Docker"
sudo sh get-docker.sh || handle_error "Failed to install Docker"
sudo rm -rf get-docker.sh
sudo usermod -aG docker $USER
sudo service docker start

# 2. Install Minikube
echo "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 || handle_error "Failed to download Minikube"
sudo install minikube-linux-amd64 /usr/local/bin/minikube || handle_error "Failed to install Minikube"
sudo rm -rf minikube-linux-amd64
minikube start --driver=docker

# 3. Install kubectl
echo "Installing kubectl..."
curl -LO https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo rm -rf kubectl && kubectl version --client

# 4. Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd || handle_error "Failed to create argocd namespace"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml || handle_error "Failed to install ArgoCD"

# 5. Install ArgoCD Rollout Controller
echo "Installing ArgoCD Rollout Controller..."
kubectl create namespace argo-rollouts || handle_error "Failed to create argo-rollouts namespace"
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml || handle_error "Failed to install ArgoCD Rollout Controller"

# 6. Install ArgoCD Rollouts Plugin
echo "Installing ArgoCD Rollouts Plugin..."
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64 || handle_error "Failed to download ArgoCD Rollouts Plugin"
sudo chmod +x ./kubectl-argo-rollouts-linux-amd64 || handle_error "Failed to set execute permission on ArgoCD Rollouts Plugin"
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts || handle_error "Failed to install ArgoCD Rollouts Plugin"
kubectl argo rollouts version || handle_error "Failed to verify ArgoCD Rollouts Plugin version"

# 7. Install ArgoCD CLI (Optional)
# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 || handle_error "Failed to download argocd cli"
# sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd || handle_error "Failed to give premissions to argocd-linux-amd64"
# rm argocd-linux-amd64 || handle_error "Failed to remove argocd-linux-amd64"

echo "All installations completed successfully!"
