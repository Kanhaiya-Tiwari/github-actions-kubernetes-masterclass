# Project Transformation Steps

This file documents all the changes and optimizations made to the SkillPulse project.

## Completed Steps

### 1. Repository Analysis
- Identified three core services: Backend (Go), Frontend (Static/Nginx), and Database (MySQL).
- Reviewed existing Dockerfiles and deployment manifests.

### 2. Implementation Planning
- Created a comprehensive [Optimization Plan](file:///Users/kanha/.gemini/antigravity/brain/3bb10925-1696-48f4-b2e4-3242654b71fb/docker_optimization_plan.md).
- Strategy: Use multi-stage builds, minimal base images (Alpine Slim, Distroless), and bake initialization scripts into images.

### 3. Backend Optimization (`backend/Dockerfile`)
- Implemented multi-stage build.
- **Stage 1 (Build)**: Used `golang:1.23-alpine`.
- **Stage 2 (Run)**: Used `gcr.io/distroless/static-debian12` for minimum footprint and security.
- Enforced static binary compilation with `CGO_ENABLED=0`.
- Added non-root user execution for security hardening.

### 4. Frontend Optimization (`frontend/Dockerfile`)
- Implemented multi-stage build.
- **Base Image**: Switched to `nginx:mainline-alpine-slim`.
- Optimized asset copying and configuration injection.

### 5. Database Containerization (`mysql/Dockerfile`)
- Created a dedicated Dockerfile for the MySQL service.
- Baked `init.sql` directly into the image (`/docker-entrypoint-initdb.d/`).
- This eliminates the need for external volume mounts for schema initialization.

### 6. Local Development Sync (`docker-compose.yml`)
- Updated the `db` service to use `build: ./mysql` instead of a generic image.
- Removed the manual volume mount for `init.sql` as it's now internal to the image.

### 7. Automation & Tooling Updates (`Makefile`)
- Updated `BACKEND_IMAGE`, `FRONTEND_IMAGE`, and added `DB_IMAGE` variables.
- Modified `build`, `load`, and `restart` targets to include the database service.
- Enabled full stack rebuilds and Kind cluster loading for the new custom images.

### 8. Continuous Integration Updates (`.github/workflows/ci.yml`)
- Added a new job step to build and push the custom MySQL database image to Docker Hub.
- Ensures all three components are versioned and pushed simultaneously.

### 9. Kubernetes Orchestration (`k8s/10-mysql.yaml`)
- Updated the StatefulSet to use the new custom `skillpulse-db:latest` image.
- Removed the `ConfigMap` and volume mounts for initialization scripts, simplifying the manifest.
- Improved resource limits and probes for the database.

### 10. Deployment Synchronization (`docker-compose.yml`)
- Added `image: ${DOCKERHUB_USERNAME}/skillpulse-db:latest` to the database service.
- This ensures that `docker compose pull` can fetch the optimized image from Docker Hub during CD.

### 12. Kubernetes Directory Restructuring (Ref: CloudKart)
- Reorganized the `k8s/` directory into a modular structure.
- **`k8s/core/`**: Infrastructure components (Namespace).
- **`k8s/mysql/`**: Database-specific resources (Secrets, Service, StatefulSet).
- **`k8s/skillpulse/`**: Application-specific resources (ConfigMap, Deployments, Services).
- **`k8s/apps/`**: ArgoCD Application definitions for GitOps deployment.
- Added descriptive headers and comments to all YAML manifests.
- Updated `Makefile` to support recursive directory application.

### 13. Manifest Comment Simplification
- Refactored all Kubernetes YAML files to use a single-line descriptive comment at the top for better readability.
- Removed redundant multi-line headers while preserving essential description of each resource.

### 14. Amazon ECR Migration
- Provisioned three new ECR repositories on AWS: `skillpulse-backend`, `skillpulse-frontend`, and `skillpulse-db`.
- Migrated all Kubernetes manifests (`k8s/mysql/`, `k8s/skillpulse/`) to use the new ECR image URLs: `815210276744.dkr.ecr.eu-west-1.amazonaws.com/...`
- Updated the `Makefile` to sync image build and load targets with the ECR registry.
- Refactored the CI workflow (`.github/workflows/ci.yml`) to use `aws-actions/amazon-ecr-login` for automated pushes.

### 15. Terraform Infrastructure Provisioning
- Created a comprehensive Terraform suite in the `terraform/` directory.
- **`vpc.tf`**: Automated provisioning of a production-grade VPC with NAT gateways.
- **`eks.tf`**: Configured a managed Amazon EKS cluster with auto-scaling node groups.
- **`argocd.tf`**: Integrated ArgoCD installation via Helm for automated GitOps.
- **`variables.tf` & `outputs.tf`**: Standardized configuration and exposure of cluster endpoints.
- Provided a dedicated README for infrastructure lifecycle management.

### 16. Terraform Remote Backend & Locking
- Provisioned an S3 bucket (`skillpulse-terraform-state-815210276744`) for remote state storage.
- Provisioned a DynamoDB table (`skillpulse-terraform-lock`) for state locking to prevent concurrent modifications.
- Configured the `backend "s3"` block in `provider.tf` to enable collaborative and secure infrastructure management.

### 17. Monitoring & Observability Stack
- Integrated the **Prometheus Community Stack** via Helm for cluster-wide metrics and Grafana dashboards.
- Installed **Grafana Loki Stack** for centralized log aggregation and analysis.
- Deployed the **OpenTelemetry Operator** to enable distributed tracing and advanced metrics collection.
- Standardized all observability tools within the `monitoring` namespace for isolation.

### 18. ArgoCD App-of-Apps Pattern
- Implemented the professional **App-of-Apps** pattern for GitOps orchestration.
- **`k8s/bootstrap/root.yaml`**: Created the master application that governs all other services.
- **`k8s/argocd/`**: Established a dedicated directory for child applications (`core`, `mysql`, `skillpulse`).
- Enabled centralized management, allowing a single manual apply of the `root-app` to trigger the deployment of the entire stack.

### 19. Comprehensive Documentation
- Integrated the **5-Step DevOps Strategy** into `docs/skillpulse-cicd-guide.md`.
- Established a professional manifesto covering Containerization, IaC, Configuration Isolation, CI/CD Automation, and Observability.
- Provided a clear technical roadmap for maintaining production-grade cloud environments.

### 20. Implementation of the 5-Step DevOps Strategy
- **Step 2 (IaC Segregation)**: Restructured the `terraform/` directory to separate `environments/dev` and `environments/prod` from the `modules/core` logic.
- **Step 4 (CI/CD Automation)**: Replaced monolithic workflows with a modular **Orchestrator-based pipeline** (`devsecops-pipeline.yml`).
- **Step 5 (Monitoring & Logging)**: Updated `monitoring.tf` to inject environment-specific tags into Promtail (`env=prod`, `env=dev`) and established strict Prometheus alerting thresholds.

### 21. Modular DevSecOps Pipeline
- Refactored CI/CD into 5+ reusable workflows: `security-scan.yml`, `iac-scan.yml`, `build-and-push.yml`, `gitops-update.yml`, `notify.yml`.
- Integrated **Gitleaks** (Secrets), **GoSec** (SAST), **GoVulnCheck** (SCA), **Hadolint** (Lint), and **Trivy** (Container Security).
- Switched notifications from Slack to **Gmail** for broader accessibility.

### 22. Terraform & EKS Stability Fixes
- Resolved `read: no route to host` IPv6 connectivity issues during `terraform init`.
- Fixed "couldn't find resource" errors by refactoring `provider.tf` to use direct module outputs instead of `data` sources during initial cluster creation.

### 23. High Availability (HA) & Reliability
- **Horizontal Pod Autoscalers (HPA)**: Configured `12-hpa.yaml` to dynamically scale pods (2 to 5 replicas) based on CPU utilization, ensuring the app handles traffic spikes automatically.
- **Pod Disruption Budgets (PDB)**: Implemented `13-pdb.yaml` with `minAvailable: 1`. This acts as a "Service Level Guarantee" during voluntary disruptions (like node upgrades or maintenance), ensuring that Kubernetes never shuts down all pods at once and always keeps at least one instance live for **Zero Downtime**.
- **Modern Compute**: Updated all environment nodes to **`c7i-flex.large`** for state-of-the-art performance and reliability.

### 24. Automatic Promotion Logic (Dev ➔ Prod)
- Implemented a "Safe Release" gate: Any push to `main` branch first deploys to **Dev**, runs a **Health/Integrity Check**, and only promotes to **Prod** if the checks pass.

### 25. Automated Backups & Disaster Recovery
- Created a production-ready **`backup.sh`** script that exports manifests and database states to an immutable S3 vault.
- Scheduled a daily **GitHub Actions CronJob** to automate the backup lifecycle.

### 26. GitOps Communication Model (CI/CD to EKS)
- **Decoupled Architecture**: GitHub Actions does not push directly to the EKS cluster. Instead, it follows the **Pull-based GitOps model**.
- **The Flow**: GitHub Actions (CI) builds the image ➔ Pushes to Amazon ECR ➔ Updates the Kubernetes manifests in the Git repository.
- **ArgoCD's Role**: ArgoCD, running inside the EKS cluster, acts as a "Controller" that continuously reconciles the state. It detects the manifest change in Git and pulls the new image from ECR into the cluster.

### 27. Automated Health Verification & Environment Promotion
- **Gated Deployment**: Implemented an automated "Promotion" logic between environments to ensure production stability.
- **Health Verification**: Before promoting to Production, the pipeline executes `argocd app wait` and `observability-check` on the Dev environment.
- **Promotion Trigger**: The `deploy-prod` job is configured with a strict `needs: [check-dev-health]` dependency.
### 28. One-Command Full Stack Automation
- Developed `deploy.sh`, a unified orchestration script that manages the entire lifecycle from Terraform infrastructure to Kubernetes app deployment.
- Integrated the script into Terraform using a `null_resource` and `local-exec` provisioner, making `terraform apply` a true "one-command" setup.

### 29. Terraform Provider Hardening (Exec Auth)
- Migrated from `aws_eks_cluster_auth` data source to the **AWS CLI Exec Plugin** for Kubernetes and Helm providers.
- This ensures real-time, zero-failure token generation, eliminating the persistent `Unauthorized` errors during long-running deployments.

### 30. Dynamic VPC Subnet Calculation
- Refactored `vpc.tf` to use the `cidrsubnet()` function.
- This allows the VPC to automatically calculate valid subnet ranges regardless of the environment's base CIDR (e.g., `10.0.0.0/16` vs `10.1.0.0/16`), preventing `InvalidSubnet.Range` errors.

### 31. EKS Admin Access (Cluster Creator Permissions)
- Enabled `enable_cluster_creator_admin_permissions = true` in the EKS module.
- This ensures that the IAM user/entity running Terraform is automatically granted `system:masters` cluster-wide permissions, enabling the automated creation of namespaces and Helm releases.

### 32. Unified Monitoring & Observability Integration
- Configured **Grafana** to automatically discover and attach **Prometheus** and **Loki** as data sources.
### 33. Production Ingress Architecture (Single LoadBalancer)
- Migrated from multiple expensive AWS LoadBalancers to a centralized **Nginx Ingress Controller** (`ingress.tf`).
- Provisioned a single Application-level entry point for the entire cluster, reducing costs and complexity.

### 34. Path-Based Unified Routing
- Implemented **Sub-path Routing** logic across all namespaces.
- Configured ArgoCD and Grafana to serve from `/argocd` and `/grafana` respectively.
- Deployed a unified Ingress resource (`k8s/skillpulse/ingress.yaml`) to map traffic from the single DNS to internal services.
