# Terraform AWS Static Website Hosting

This project provisions AWS infrastructure for hosting a static website using S3, CloudFront, and Terraform.

## Architecture Diagram

![arch diagram](https://github.com/user-attachments/assets/1bd861ae-f836-4e27-a58c-de771aaf6674)

## Screenshot of Deployed Website

![Screenshot 2025-04-23 at 15 48 02](https://github.com/user-attachments/assets/c5cd1c4d-de68-489e-be7f-c409e789678d)

*Welcome page of our startup website hosted on AWS*

## How to Run This Project

### Prerequisites
- Terraform v1.10+ installed (needed for native S3 state locking)
- AWS account with credentials configured
- AWS CLI configured with proper permissions

### One-time setup: create the state bucket

Terraform's state file has to live somewhere before Terraform can manage anything else, so this one bucket is created by hand, once:

```bash
aws s3api create-bucket --bucket YOUR-UNIQUE-STATE-BUCKET-NAME --region us-east-1
aws s3api put-bucket-versioning --bucket YOUR-UNIQUE-STATE-BUCKET-NAME --versioning-configuration Status=Enabled
```

Then put that same bucket name into the `backend "s3"` block in `main.tf`.

### Deployment Steps

1. Clone this repository:
   ```bash
   git clone https://github.com/kingshadie/Terraform-Static-Website-Infra.git
   cd Terraform-Static-Website-Infra
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the execution plan:
   ```bash
   terraform plan
   ```
4. Deploy the infrastructure:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted to confirm.
5. Access your website:
   ```bash
   curl $(terraform output -raw website_url)
   ```
   Or open the URL in your browser.

### Clean Up

To destroy all created resources:
```bash
terraform destroy
```

## Resource Overview

| Resource | Purpose | Key Features |
|---|---|---|
| AWS S3 Bucket | Stores static website files | Fully private - no direct public access |
| CloudFront Origin Access Control | Lets CloudFront read the private bucket | Only this distribution can use it |
| CloudFront Distribution | Content delivery network | HTTPS encryption, global edge caching |
| S3 Bucket Policy | Controls access to S3 | Allows reads only from this CloudFront distribution |
| Terraform Config | Infrastructure as Code | Remote state in S3, automated provisioning |

## Key Components Explained

**S3 bucket (private):**
- Stores all static assets (HTML, CSS, JS, images)
- All public access is blocked at the bucket level
- The only reader allowed is this specific CloudFront distribution, via Origin Access Control

**CloudFront CDN:**
- Provides HTTPS encryption automatically
- Caches content at edge locations worldwide
- Authenticates to S3 using Origin Access Control instead of a public bucket
- Serves `error.html` on a 404

**Terraform automation:**
- State is stored remotely in S3, with locking, instead of only on one machine
- Creates all resources in a single command
- Outputs the CloudFront URL when complete

## Customization Options

To change the website content:
- Modify files in the `website/` directory
- Re-run `terraform apply`

To add a custom domain:
- Uncomment the ACM certificate resource
- Add Route 53 DNS records
- Update CloudFront aliases

## Troubleshooting

- **403 Forbidden errors:** verify the bucket policy and Origin Access Control were both applied - a private bucket with no OAC returns 403 on everything.
- **SSL warnings:** make sure you're accessing via the CloudFront URL (`https://...cloudfront.net`), not the S3 URL directly.
- **Timeout errors:** CloudFront deployments can take 15-30 minutes.

## What I Learned

S3 public-read bucket policies and CloudFront don't propagate in sync. A policy change applies to S3 immediately, but CloudFront can keep serving a cached 403 or stale response for several minutes after `terraform apply` finishes. That gap between "Terraform says done" and "the world actually sees it" is the real operational lesson. Infrastructure-as-code guarantees the resource state, not the propagation timeline.

I also moved this project off a public S3 bucket and onto CloudFront Origin Access Control - the earlier version granted `s3:GetObject` to everyone (`principal = "*"`), which technically worked but broke the least-privilege standard I'd want to hold any change to in review. Least privilege applies to your own infrastructure, not just the changes you're reviewing for someone else.
