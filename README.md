markdown
Copy
Download
# Terraform AWS Static Website Hosting

This project provisions AWS infrastructure for hosting a static website using S3, CloudFront, and Terraform.

## Architecture Diagram

![arch diagram](https://github.com/user-attachments/assets/1bd861ae-f836-4e27-a58c-de771aaf6674)

## Screenshot of Deployed Website

![Screenshot 2025-04-23 at 15 48 02](https://github.com/user-attachments/assets/c5cd1c4d-de68-489e-be7f-c409e789678d)

*Welcome page of our startup website hosted on AWS*

## How to Run This Project

### Prerequisites
- Terraform v1.0+ installed
- AWS account with credentials configured
- AWS CLI configured with proper permissions

### Deployment Steps

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/static-website-iac.git
   cd static-website-iac
Initialize Terraform:
bash
Copy
Download
terraform init
Review the execution plan:
bash
Copy
Download
terraform plan
Deploy the infrastructure:
bash
Copy
Download
terraform apply
Type yes when prompted to confirm.
Access your website:
bash
Copy
Download
curl $(terraform output -raw website_url)
Or open the URL in your browser.
Clean Up

To destroy all created resources:

bash
Copy
Download
terraform destroy
Resource Overview

Resource	Purpose	Key Features
AWS S3 Bucket	Hosts static website files	- Public read access
- Website configuration
- Stores HTML/CSS/JS files
CloudFront Distribution	Content delivery network	- HTTPS encryption
- Global edge caching
- Default SSL certificate
S3 Bucket Policy	Controls access to S3	- Allows public read access
- Restricts to GET requests only
Terraform Config	Infrastructure as Code	- Automated provisioning
- Version controlled setup
- Repeatable deployments
Key Components Explained

S3 Website Hosting:
Stores all static assets (HTML, CSS, JS, images)
Configured with index.html and error.html documents
Public access enabled through bucket policy
CloudFront CDN:
Provides HTTPS encryption automatically
Caches content at edge locations worldwide
Serves content faster to global users
Uses default *.cloudfront.net SSL certificate
Terraform Automation:
Creates all resources in a single command
Manages dependencies between resources
Outputs the CloudFront URL when complete
Customization Options

To change the website content:
Modify files in the website/ directory
Re-run terraform apply
To add a custom domain:
Uncomment the ACM certificate resource
Add Route 53 DNS records
Update CloudFront aliases
Troubleshooting

If you encounter:

403 Forbidden errors: Verify the S3 bucket policy was applied correctly
SSL warnings: Ensure you're accessing via the CloudFront URL (https://)
Timeout errors: CloudFront deployments can take 15-30 minutes
