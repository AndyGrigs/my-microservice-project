# Lesson 5 — Terraform Modules

This lesson demonstrates structuring Terraform code using reusable modules.

## Structure

```
lesson-5/
├── main.tf          # Root module — connects all child modules
├── backend.tf       # S3 + DynamoDB remote state backend
├── variables.tf     # Root-level input variables
├── outputs.tf       # Root-level outputs
├── modules/
│   ├── s3-backend/  # S3 bucket + DynamoDB for Terraform state
│   ├── vpc/         # VPC, subnets, Internet Gateway, route tables
│   └── ecr/         # ECR repository with lifecycle policy
└── README.md
```

## Usage

1. Initialize Terraform (first run — use local backend):

```bash
terraform init
```

2. Create the S3 bucket and DynamoDB table:

```bash
terraform apply -target=module.s3_backend
```

3. Uncomment `backend.tf`, update bucket/table names, then migrate state:

```bash
terraform init -migrate-state
```

4. Apply the rest of the infrastructure:

```bash
terraform apply
```

## Required Variables

| Variable | Description |
|---|---|
| `backend_bucket_name` | Unique S3 bucket name for Terraform state |
| `ecr_repository_name` | Name for the ECR repository |

## Optional Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | AWS region |
| `environment` | `dev` | Environment name |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `backend_dynamodb_table` | `terraform-state-lock` | DynamoDB table name |
