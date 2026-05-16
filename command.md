# Step-by-Step Command Guide

This guide provides all the commands used to transform the project, migrate to Amazon ECR, and deploy to Kubernetes.

## Phase 1: Setup and Discovery
```bash
# 1. Clone the repository
git clone https://github.com/Kanhaiya-Tiwari/github-actions-kubernetes-masterclass.git
cd github-actions-kubernetes-masterclass

# 2. Identify AWS Account Details
aws sts get-caller-identity
aws configure get region
```

## Phase 2: ECR Repository Creation
```bash
# 3. Create ECR Repositories (Replace Account ID and Region if different)
aws ecr create-repository --repository-name skillpulse-backend --region eu-west-1
aws ecr create-repository --repository-name skillpulse-frontend --region eu-west-1
aws ecr create-repository --repository-name skillpulse-db --region eu-west-1
```

## Phase 3: Build and Push to Amazon ECR
```bash
# 4. Authenticate Docker to ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 815210276744.dkr.ecr.eu-west-1.amazonaws.com

# 5. Build and Tag Backend
docker build -t 815210276744.dkr.ecr.eu-west-1.amazonaws.com/skillpulse-backend:latest ./backend

# 6. Build and Tag Frontend
docker build -t 815210276744.dkr.ecr.eu-west-1.amazonaws.com/skillpulse-frontend:latest ./frontend

# 7. Build and Tag Database
docker build -t 815210276744.dkr.ecr.eu-west-1.amazonaws.com/skillpulse-db:latest ./mysql

# 8. Push Images to ECR
docker push 815210276744.dkr.ecr.eu-west-1.amazonaws.com/skillpulse-backend:latest
docker push 815210276744.dkr.ecr.eu-west-1.amazonaws.com/skillpulse-frontend:latest
docker push 815210276744.dkr.ecr.eu-west-1.amazonaws.com/skillpulse-db:latest
```

## Phase 4: Kubernetes Deployment
```bash
# 9. Apply core resources (Namespace)
kubectl apply -f k8s/core/

# 10. Apply Database resources (Secrets, Service, StatefulSet)
kubectl apply -f k8s/mysql/

# 11. Apply Application resources (ConfigMap, Deployments, Services)
kubectl apply -f k8s/skillpulse/

# 12. Verify status
kubectl get all -n skillpulse

## Phase 5: Infrastructure Provisioning (Terraform)

### Step 5a: Backend Setup (One-time)
```bash
# 13. Create S3 Bucket and DynamoDB Table for remote state
aws s3 mb s3://skillpulse-terraform-state-815210276744 --region eu-west-1
aws dynamodb create-table \
    --table-name skillpulse-terraform-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region eu-west-1
```

### Step 5b: Deployment
```bash
# 14. Navigate to terraform directory
cd terraform

# 15. Initialize Terraform (Migrate state to S3 if prompted)
terraform init

# 16. Plan and Apply
terraform plan
terraform apply --auto-approve

# 17. Verify Monitoring Stack
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# 18. Access Grafana (get password)
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

## Phase 6: GitOps Orchestration (App-of-Apps)
```bash
# 19. Bootstrap the Root Application
# This will automatically trigger the deployment of Core, MySQL, and SkillPulse apps
kubectl apply -f k8s/bootstrap/root.yaml

# 20. Access ArgoCD UI (get password)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
```
```

## Shortcuts (Using Makefile)
If you have `make` installed and configured the `Makefile` correctly:
```bash
# Build all images
make build

# Deploy all manifests
make apply

# Check logs for all components
make logs
```
