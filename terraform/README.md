# SkillPulse Terraform Infrastructure

This directory contains the Terraform configuration to provision the necessary AWS infrastructure for the SkillPulse project.

## Components
- **VPC**: A dedicated VPC with public and private subnets, including a NAT Gateway for private subnet internet access.
- **EKS**: A managed Amazon EKS cluster with a managed node group.
- **ArgoCD**: Automated installation of ArgoCD via Helm for GitOps deployments.

## Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials.
- `kubectl` and `helm` installed.

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan Deployment**:
   ```bash
   terraform plan
   ```

3. **Apply Changes**:
   ```bash
   terraform apply
   ```

4. **Update Kubeconfig**:
   ```bash
   aws eks update-kubeconfig --region eu-west-1 --name skillpulse
   ```
