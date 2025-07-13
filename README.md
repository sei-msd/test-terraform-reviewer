# Terraform Reviewer Demo Project

This is a sample project demonstrating how to use the [terraform-reviewer](https://github.com/seii-saintway/terraform-reviewer) GitHub Action for automated Terraform code reviews.

## Project Structure

```
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example variables file
├── .github/
│   └── workflows/
│       └── terraform-review.yml  # GitHub Actions workflow
└── README.md                  # This file
```

## Infrastructure Overview

This project creates a basic AWS infrastructure including:

- **VPC** with public and private subnets across multiple AZs
- **Internet Gateway** for public internet access
- **Application Load Balancer** for distributing traffic
- **Security Groups** with appropriate ingress/egress rules
- **S3 Bucket** with encryption and versioning enabled
- **Route Tables** and associations for network routing

## Prerequisites

Before using this project, ensure you have:

1. **AWS Account** with Amazon Bedrock access in Tokyo region (ap-northeast-1)
2. **IAM Role** configured for OIDC Federation
3. **GitHub Repository** with Actions enabled
4. **Terraform** installed locally (optional, for local development)

## Setup Instructions

### 1. AWS IAM Role Configuration

Create an IAM role for GitHub Actions OIDC with the following trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR-ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:YOUR-ORG/YOUR-REPO:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

Attach the following policies to the role:
- `AmazonBedrockFullAccess` (or create a custom policy with minimal required permissions)
- Custom policy for Terraform operations (EC2, VPC, S3, etc.)

### 2. Enable Amazon Bedrock Models

1. Navigate to Amazon Bedrock in AWS Console
2. Go to "Model access" in the left sidebar
3. Request access to Claude 3 Haiku model
4. Wait for approval (usually instantaneous for Claude 3 Haiku)

### 3. Configure GitHub Secrets

Add the following secret to your GitHub repository:

- `AWS_ROLE_ARN`: Your IAM role ARN (e.g., `arn:aws:iam::123456789012:role/GitHubActionsRole`)

### 4. Configure Variables

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Customize the variables according to your needs:

```hcl
aws_region     = "ap-northeast-1"
project_name   = "my-terraform-project"
environment    = "dev"
vpc_cidr       = "10.0.0.0/16"

availability_zones = [
  "ap-northeast-1a",
  "ap-northeast-1c"
]

enable_deletion_protection = false
```

## How It Works

### Automated Review Process

1. **Trigger**: When you create a pull request with Terraform changes
2. **Validation**: GitHub Actions runs terraform fmt, init, validate, and plan
3. **AI Review**: terraform-reviewer analyzes the plan using Amazon Bedrock
4. **Feedback**: AI-generated review comments are posted to your PR

### Review Features

The terraform-reviewer provides:

- **Security Analysis**: Identifies potential security issues
- **Best Practices**: Suggests improvements following AWS best practices
- **Cost Impact**: Estimates cost changes from the proposed infrastructure
- **Compliance**: Checks for compliance with organizational policies

## Local Development

### Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Create execution plan
terraform plan

# Apply changes (be careful!)
terraform apply
```

### Clean Up

```bash
# Destroy infrastructure
terraform destroy
```

## Customization

### Changing AI Model

You can use different Bedrock models by modifying the workflow:

```yaml
- name: Review Terraform Changes
  uses: seii-saintway/terraform-reviewer@main
  with:
    model_id: cohere.command-r-plus-v1:0  # Alternative model
    # ... other parameters
```

Available models:
- `anthropic.claude-3-haiku-20240307-v1:0` (default, fast and cost-effective)
- `cohere.command-r-plus-v1:0` (alternative model)

### Adding More Resources

To extend this example:

1. Add new resources to `main.tf`
2. Define any new variables in `variables.tf`
3. Add outputs in `outputs.tf`
4. Update documentation

## Troubleshooting

### Common Issues

**Issue**: "AWS credentials not configured"
- **Solution**: Verify OIDC setup and IAM role permissions
- **Check**: Role trust policy includes your repository

**Issue**: "Bedrock model access denied"  
- **Solution**: Enable the model in Amazon Bedrock console
- **Check**: Model is available in ap-northeast-1 region

**Issue**: "Plan file not found"
- **Solution**: Ensure terraform plan generates plan.out file
- **Check**: Terraform init and validate steps succeed

**Issue**: "GitHub token permissions insufficient"
- **Solution**: Verify workflow has `pull-requests: write` permission
- **Check**: Repository settings allow Actions to comment on PRs

## Contributing

Feel free to modify this example project to suit your needs. Some ideas for improvements:

- Add RDS database configuration
- Include ECS/EKS for container orchestration
- Add CloudWatch monitoring and alerting
- Implement multi-environment setup
- Add automated testing with terraform-compliance

## License

This example project is provided as-is for demonstration purposes.