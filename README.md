# CI/CD Pipeline Assignment

This assignment demonstrates a complete CI/CD pipeline using GitHub Actions, Docker, AWS ECR, and Terraform Infrastructure as Code.

---

## Repository Structure
```
CICD/
└── Assignment/
    ├── app.py               # Python application
    ├── Dockerfile           # Container definition
    ├── Terraform/           # Infrastructure as Code
    │   ├── main.tf          # ECR repository resource
    │   ├── variables.tf     # Input variables
    │   ├── outputs.tf       # Output values
    │   └── versions.tf      # Provider and backend config
    └── README.md
.github/
└── workflows/
    ├── image.yaml           # Build, scan and push Docker image to ECR
    ├── tf-plan.yaml         # Terraform plan with security scanning
    ├── tf-apply.yaml        # Terraform apply (main branch only)
    └── tf-destroy.yaml      # Terraform destroy (manual trigger only)
```

---

## Task 1: CI Pipeline

### `tf-plan.yaml`
Triggers on every push to any branch. Acts as the continuous integration gate for infrastructure changes.

**Steps:**
1. Checkout code
2. Configure AWS credentials via OIDC
3. Install tflint — lints Terraform code for best practices
4. Install checkov — scans for security misconfigurations
5. Terraform Init
6. Run tflint
7. Run checkov (fails pipeline if security issues found)
8. Terraform Plan — shows what changes would be made without applying them

---

## Task 2: CD Pipelines

### `image.yaml` — Docker Build, Scan and Push to ECR
Triggers on every push. Builds the Docker image, scans it for vulnerabilities, and pushes to AWS ECR.

**Steps:**
1. Checkout code
2. Configure AWS credentials via OIDC
3. Log in to Amazon ECR
4. Build Docker image
5. Run Trivy vulnerability scan — fails if CRITICAL vulnerabilities found
6. Tag image with `latest` and git commit SHA
7. Push to ECR

**Why two tags?** The `latest` tag gives the most recent image. The commit SHA tag lets you trace exactly which version of the code produced which image — essential for debugging and rollbacks.

### `tf-apply.yaml` — Terraform Apply
Triggers only on pushes to `main`. Creates or updates AWS infrastructure after all checks pass.

### `tf-destroy.yaml` — Terraform Destroy
Triggered **manually only** via `workflow_dispatch`. Infrastructure should never be destroyed automatically on a code push.

---

## Infrastructure (Terraform)

The Terraform code defines an AWS ECR repository with security best practices:

- `image_tag_mutability = "IMMUTABLE"` — prevents existing image tags from being overwritten
- `scan_on_push = true` — AWS automatically scans images for vulnerabilities on push
- `encryption_type = "KMS"` — encrypts stored images using AWS Key Management Service

---

## Security Decisions

### OIDC Authentication vs Access Keys
The pipeline authenticates to AWS using OpenID Connect (OIDC) rather than storing long-lived AWS access keys as GitHub secrets.

- No credentials stored anywhere — GitHub requests a short-lived token from AWS at runtime
- Tokens expire automatically after each job
- Access keys, if leaked, remain valid until manually rotated

### Trivy as a Pipeline Gate
Trivy runs before the push to ECR. If any CRITICAL vulnerabilities are found, the pipeline fails and nothing is pushed. No vulnerable images can ever reach the registry.

### Checkov as an IaC Gate
Checkov caught two real issues during development before any infrastructure was created:

- **CKV_AWS_51** — ECR image tags were MUTABLE, allowing images to be overwritten
- **CKV_AWS_136** — ECR repository had no KMS encryption

Both were fixed in code before apply ran.

---

## AWS Resources

| Resource | Name | Region |
|---|---|---|
| ECR Repository | hello-app | eu-west-2 |
| IAM Role | github-actions-ecr-role | eu-west-2 |
| OIDC Provider | token.actions.githubusercontent.com | eu-west-2 |