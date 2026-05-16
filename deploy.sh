#!/bin/bash

# Default environment is dev
ENV=${1:-dev}
POST_ONLY=$2

if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "Invalid environment: $ENV. Use 'dev' or 'prod'."
  exit 1
fi

PROJECT_NAME="skillpulse-${ENV}"
REGION="eu-west-1"

# Skip Terraform if --post-only is provided
if [[ "$POST_ONLY" != "--post-only" ]]; then
    echo "========================================="
    echo "Starting full automated deployment for environment: $ENV"
    echo "Project/Cluster Name: $PROJECT_NAME"
    echo "========================================="

    # 1. Deploy Infrastructure with Terraform
    echo "==> Step 1: Deploying Infrastructure via Terraform..."
    cd "terraform/environments/${ENV}" || exit 1

    terraform init
    if [ $? -ne 0 ]; then
      echo "Terraform init failed!"
      exit 1
    fi

    terraform apply -auto-approve
    if [ $? -ne 0 ]; then
      echo "Terraform apply failed!"
      exit 1
    fi
    echo "==> Terraform deployment successful!"
else
    echo "========================================="
    echo "Running Post-Deployment Automation for: $ENV"
    echo "========================================="
fi

# 2. Update Kubeconfig
echo "==> Step 2: Updating kubeconfig for cluster $PROJECT_NAME..."
aws eks update-kubeconfig --region "$REGION" --name "$PROJECT_NAME"
if [ $? -ne 0 ]; then
  echo "Failed to update kubeconfig. Ensure AWS CLI is configured and cluster exists."
  exit 1
fi

# Wait for ArgoCD to be ready (Terraform just installed it)
echo "==> Waiting for ArgoCD pods to be fully ready before deploying project..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# 3. Apply ArgoCD Applications to deploy the project
echo "==> Step 3: Deploying the project via ArgoCD..."

# Check where we are. If called from Terraform, we might already be in environments/dev
if [[ -d "../../../k8s/argocd" ]]; then
    cd ../../../k8s/argocd/ || exit 1
elif [[ -d "k8s/argocd" ]]; then
    cd k8s/argocd/ || exit 1
else
    echo "Error: Could not find k8s/argocd directory"
    exit 1
fi

kubectl apply -f .

# 4. Fetch LoadBalancer URL
echo "==> Step 4: Fetching External Ingress URL..."
sleep 15 # Give AWS a moment to assign DNS

# Get the single Nginx LoadBalancer URL
LB_URL=$(kubectl get svc ingress-nginx-controller -n kube-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "-----------------------------------------"
echo "🚀 ACCESS YOUR SERVICES (SINGLE LOADBALANCER):"
echo "-----------------------------------------"
echo "Main App URL: http://$LB_URL/"
echo "Grafana URL:  http://$LB_URL/grafana"
echo "ArgoCD URL:   http://$LB_URL/argocd"
echo "-----------------------------------------"

echo "========================================="
echo "Automation Complete!"
echo "Your project is now live on the URLs above."
echo "You can check the status using: kubectl get pods -A"
echo "========================================="
