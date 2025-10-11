# 🚀 usm-gitops-infra – AWS EKS Infrastructure Module

A Terraform module to provision a complete GitOps-ready **EKS platform on AWS**, including:

- 🌐 **VPC** with private & public subnets, NAT Gateway, and flow logs  
- ☸️ **EKS** cluster with managed node groups and core addons  
- 📦 **ECR** repositories for application images and Helm charts  
- 🔐 **GitHub OIDC** provider and IAM role for secure CI/CD deployments

---

## 📁 Project Structure

```
usm-gitops-infra/
├── .github/
│   └── workflows/       # CI/CD automation (optional)
├── env/
│   └── dev/             # Environment-specific tfvars or configs
├── modules/
│   └── eks-infra/       # Main Terraform module code
├── main.tf             # Entry point to call modules
├── variables.tf        # Input variables
├── outputs.tf          # Module outputs
├── terraform.tfvars.example # Sample variables file
└── README.md           # 📘 You are here
```

---

## 🧰 Prerequisites

- [Terraform ≥ 1.3](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with credentials
- IAM permissions to create VPC, EKS, IAM, and ECR resources

---

## ⚙️ Usage

### 1️⃣ Clone the repository

```bash
git clone https://github.com/zsayed1/usm-gitops-infra.git
cd usm-gitops-infra
```

---

### 2️⃣ Create your `terraform.tfvars`

```hcl
##############################
# Global Settings
##############################
region    = "us-east-1"
namespace = "test"
stage     = "dev"
env       = "dev"

tags = {
  Application = "gitops-platform"
  Owner       = "usmobile-devops"
  Terraform   = "true"
}

##############################
# VPC Settings
##############################
vpc_cidr        = "10.60.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]
private_subnets = ["10.60.1.0/24", "10.60.2.0/24"]
public_subnets  = ["10.60.101.0/24", "10.60.102.0/24"]
flow_log_retention_days = 14

##############################
# EKS Settings
##############################
cluster_version     = "1.32"
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
node_capacity_type  = "ON_DEMAND"

##############################
# ECR Settings
##############################
ecr_app_name  = "test-app-repo"
ecr_helm_name = "test-helm-repo"

##############################
# GitHub OIDC Settings
##############################
github_oidc_url         = "https://token.actions.githubusercontent.com"
github_oidc_thumbprint = "<your-latest-thumbprint-here>"
github_repo_filter      = "repo:usmobile/gitops-platform:ref:refs/heads/main"
```

---

### 3️⃣ Change Dir
```bash
cd env/dev/
```

### 3️⃣ Initialize Terraform

```bash
terraform init
```

---

### 4️⃣ Review the plan

```bash
terraform plan 
```

---

### 5️⃣ Apply the configuration

```bash
terraform apply
```

This will:

- 🚀 Create a VPC with subnets and NAT  
- ☸️ Deploy an EKS cluster with managed node groups  
- 📦 Create ECR repositories  
- 🔐 Configure GitHub OIDC provider and IAM role

---

## ☸️ Connect to Your EKS Cluster

Once created, update your `kubeconfig`:

```bash
aws eks update-kubeconfig --region us-east-1 --name test-dev-eks-new
```

Check nodes:

```bash
kubectl get nodes
```

---

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy 
```

---

## 📤 Use as a Remote Module (Optional)

Once tagged (e.g., `v1.0.0`), this module can be used directly in another project:

```hcl
module "eks_infra" {
  source = "github.com/zsayed1/usm-gitops-infra//modules/eks-infra?ref=v2.0.0"

  region           = "us-east-1"
  namespace        = "test"
  stage            = "dev"
  vpc_cidr         = "10.60.0.0/16"
  azs              = ["us-east-1a", "us-east-1b"]
  private_subnets  = ["10.60.1.0/24", "10.60.2.0/24"]
  public_subnets   = ["10.60.101.0/24", "10.60.102.0/24"]
  cluster_version  = "1.32"
}
```

---

## 📊 Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the created VPC |
| `private_subnets` | List of private subnet IDs |
| `public_subnets` | List of public subnet IDs |
| `eks_cluster_name` | Name of the EKS cluster |
| `eks_cluster_arn` | ARN of the EKS cluster |
| `eks_cluster_endpoint` | API endpoint of the EKS cluster |
| `ecr_app_repo_url` | ECR repo URL for app images |
| `ecr_helm_repo_url` | ECR repo URL for Helm charts |
| `github_oidc_provider_arn` | ARN of the GitHub OIDC provider |
| `github_actions_role_arn` | ARN of the IAM role for GitHub Actions |

---

## 🏷️ Versioning & Releases

Follow [Semantic Versioning](https://semver.org/):

```bash
git tag v2.0.0
git push origin v2.0.0
```

Then use it like:

```hcl
source = "github.com/zsayed1/usm-gitops-infra?ref=v2.0.0"
```

---

## 🔬 GitHub Actions CI Tests for Terraform Module

This repository uses **GitHub Actions** to automatically test, validate, and secure every pull request and push to the `main` branch. The CI pipeline ensures that the Terraform code in this module is always production-ready before it’s merged or released.

---

## 🧪 What We Test in CI

### 1. ✅ Terraform Formatting (`terraform fmt`)
We enforce consistent Terraform code style using `terraform fmt`.  
This helps ensure readability and prevents formatting-related diffs in pull requests.

```yaml
- name: Terraform Format
  run: terraform fmt -check -recursive
```

---

### 2. 🧰 Validation (`terraform validate`)
We run `terraform validate` to confirm the configuration is syntactically correct and all variables, types, and references are valid.  
This step catches many issues before they ever reach AWS.

```yaml
- name: Terraform Validate
  run: terraform validate
```

---

### 3. 🔐 Security Scanning (`tfsec`)
We run [tfsec](https://aquasecurity.github.io/tfsec/) to perform static analysis and detect potential security misconfigurations, such as:

- Publicly exposed security groups  
- Unencrypted storage buckets or volumes  
- Missing IAM policies or overly permissive roles  

```yaml
- name: Run tfsec Security Scan
  uses: aquasecurity/tfsec-action@v1.0.0
```

---

### 4. 📊 Terraform Plan (Dry Run)
We run a `terraform plan` against sample variable files (like `terraform.tfvars.example` or `env/dev/terraform.tfvars`) to ensure the module successfully generates an execution plan without errors.

This simulates a real deployment **without creating resources** — ideal for verifying correctness and reviewing infrastructure changes during pull requests.

```yaml
- name: Terraform Plan
  run: terraform plan -var-file=terraform.tfvars.example -out=plan.out
```

---

### 5. 🧪 (Optional) Sandbox Apply & Destroy
In advanced setups, the CI workflow can deploy resources into a **temporary sandbox AWS account**, validate the deployment (e.g., `kubectl get nodes` on EKS), and then destroy them.  
This is typically reserved for nightly builds or pre-release pipelines.

---

## 📈 Why These Tests Matter

✅ **Prevent Errors Early:** Validate syntax and logic before anything reaches AWS.  
🔐 **Secure by Default:** Automatically scan for misconfigurations and security risks.  
📊 **Predictable Deployments:** Use `terraform plan` to verify changes before merging.  
🤖 **Continuous Confidence:** Every pull request and commit is tested automatically.

---

## 📦 Example CI Workflow

Here’s a simplified version of the CI workflow (`.github/workflows/ci.yml`):

```yaml
name: Terraform Module CI

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.13.3

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init -backend=false

      - name: Terraform Validate
        run: terraform validate

      - name: Run tfsec Security Scan
        uses: aquasecurity/tfsec-action@v1.0.0

      - name: Terraform Plan
        run: terraform plan -var-file=terraform.tfvars.example -out=plan.out
```

---

## 🚀 Outcome

With this pipeline in place, every change to your Terraform codebase is:

- Formatted consistently  
- Validated for syntax and structure  
- Scanned for security risks  
- Verified to generate a valid execution plan  

This ensures the module is always **safe, stable, and production-ready** before being deployed or released.


---

## 🤝 Contributing

Contributions and PRs are welcome! Please open an issue if you find a bug or need a new feature.

---

## 📜 License

MIT License © 2025 [Zeshan Sayed](https://github.com/zsayed1)
