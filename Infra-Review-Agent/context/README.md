# Terraform AWS Static Website Hostingq

This project provisions AWS infrastructure for hosting a static website using S3, CloudFront, and Terraform.

## Architecture

The infrastructure consists of:

- Amazon S3 for private static website storage
- Amazon CloudFront for content delivery
- CloudFront Origin Access Control (OAC) for authenticated access to the S3 bucket
- S3 bucket policy restricting object access to the CloudFront distribution
- Terraform for infrastructure provisioning
- Amazon S3 remote Terraform state with state locking

## How to Run This Project

### Prerequisites

- Terraform v1.10+ installed
- AWS account with credentials configured
- AWS CLI configured with appropriate permissions

### One-time setup: Create the state bucket

The Terraform state bucket must exist before Terraform can use it as a backend.

```bash
aws s3api create-bucket --bucket YOUR-UNIQUE-STATE-BUCKET-NAME --region us-east-1

aws s3api put-bucket-versioning --bucket YOUR-UNIQUE-STATE-BUCKET-NAME --versioning-configuration Status=Enabled
