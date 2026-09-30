# Static Infrastructure Review Report: AWS Static Website Hosting

## 1. Executive Summary

This report presents a static infrastructure review of the Terraform AWS static website hosting configuration located in the workspace. The architecture implements a secure, private Amazon S3 storage backend accessed exclusively via Amazon CloudFront using Origin Access Control (OAC), satisfying modern cloud security and least-privilege principles. 

While the core security design (blocking public S3 access, enforcing OAC with condition-based IAM policies, and enforcing HTTPS redirect) is well-architected and aligns with industry best practices, the static inspection revealed several critical deployment hurdles and configuration gaps. Notably, the S3 backend block contains a placeholder bucket name, the local `website` directory referenced by `aws_s3_object` is missing from the repository workspace, and older provider constructs (`forwarded_values`) are utilized. This report categorizes these findings, details their evidence and impact, and provides actionable recommendations to prepare the codebase for professional review and deployment.

---

## 2. Scope and Evidence Reviewed

The review is strictly bounded to static inspection of the following four files present in the workspace:
1. **`README.md`**: Project overview, architecture summary, prerequisites (Terraform v1.10+), and state bucket bootstrap instructions.
2. **`main.tf`**: Core infrastructure definitions including provider configuration, S3 backend state, S3 website bucket, public access block, OAC, IAM policy document, CloudFront distribution, S3 object synchronization, and MIME type locals.
3. **`variables.tf`**: Input variable definitions (`bucket_name`).
4. **`outputs.tf`**: Output definitions (`cloudfront_domain`, `s3_bucket_name`, `website_url`).

No live AWS validation, cloud API calls, or execution of `terraform` commands were performed. All findings are derived solely from static analysis of the supplied source code and documentation.

---

## 3. Architecture Understanding

The provisioned architecture follows a secure serverless static hosting pattern:
- **State Management**: Uses an S3 remote backend with encryption enabled (`encrypt = true`) and S3 native state locking (`use_lockfile = true`), leveraging Terraform v1.10+ capabilities.
- **Storage Layer**: An Amazon S3 bucket (`aws_s3_bucket.website_bucket`) with a randomized suffix (`random_id.bucket_suffix`) and `force_destroy = true` enabled for development convenience.
- **Public Access Disabling**: Complete lockdown of the S3 bucket via `aws_s3_bucket_public_access_block` (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets` all set to `true`).
- **Edge Delivery Layer**: Amazon CloudFront distribution (`aws_cloudfront_distribution.website_distribution`) configured with `PriceClass_100`, IPv6 support, and HTTPS redirection (`redirect-to-https`).
- **Authenticated Origin Access**: CloudFront Origin Access Control (`aws_cloudfront_origin_access_control.website_oac`) coupled with an IAM bucket policy (`aws_s3_bucket_policy.bucket_policy`) granting `s3:GetObject` strictly to CloudFront (`cloudfront.amazonaws.com`) restricted by `AWS:SourceArn`.
- **Content Deployment**: Automated asset synchronization from a local `website` directory (`aws_s3_object.website_files`) with dynamic MIME type mapping and MD5-based etags.

---

## 4. Findings Table

| ID | Severity | Category | Finding | Evidence | Recommendation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **SEC-01** | Medium | Security & Compliance | Missing explicit server-side encryption and versioning on website S3 bucket | `aws_s3_bucket.website_bucket` defines bucket and `force_destroy` but lacks explicit `aws_s3_bucket_server_side_encryption_configuration` and `aws_s3_bucket_versioning` blocks. | Add explicit AES-256 or KMS encryption and versioning resource blocks to ensure compliance and audit readiness. |
| **TER-01** | High | Terraform State | Unsubstituted S3 backend bucket placeholder | `main.tf` line 18: `bucket = "REPLACE-WITH-YOUR-UNIQUE-BUCKET-NAME"` | Replace placeholder with the actual unique state bucket name prior to running `terraform init`. |
| **DEP-01** | High | Deployment / Reliability | Missing local `website` directory causing apply failure | `main.tf` line 144: `fileset("${path.module}/website", "**/*")` points to a non-existent `website` directory in the workspace. | Create the `website` directory containing at least `index.html` and `error.html`, or make object synchronization conditional. |
| **AWS-01** | Medium | AWS Resource Configuration | Use of deprecated `forwarded_values` in CloudFront cache behavior | `main.tf` line 99: `forwarded_values` block inside `default_cache_behavior` | Migrate from deprecated `forwarded_values` to modern `cache_policy_id` (e.g., AWS managed caching optimized policy) in AWS provider v5+. |
| **MNT-01** | Low | Maintainability | Variable `bucket_name` lacks validation rules | `variables.tf` defines `bucket_name` without `validation` blocks or regex constraints. | Add a validation condition enforcing valid S3 bucket naming characters (lowercase letters, numbers, hyphens) and length limits. |
| **DOC-01** | Low | Documentation | README state bucket instructions omit locking/encryption requirements | `README.md` shows `aws s3api create-bucket` without versioning or locking configuration that matches backend settings. | Update README instructions to explicitly include bucket versioning and note S3 native lockfile permissions required for Terraform v1.10+. |

---

## 5. Detailed Findings

### SEC-01: Missing Explicit Encryption and Versioning on Website S3 Bucket
- **Severity**: Medium
- **Category**: Security & Compliance / Reliability
- **File & Resource**: `main.tf` (`aws_s3_bucket.website_bucket`)
- **Evidence**: The S3 bucket resource is declared with `bucket = "${var.bucket_name}-${random_id.bucket_suffix.hex}"` and `force_destroy = true`, but there are no corresponding `aws_s3_bucket_server_side_encryption_configuration` or `aws_s3_bucket_versioning` resource blocks.
- **Potential Impact**: While S3 applies default encryption (SSE-S3), regulatory and enterprise compliance standards often mandate explicit configuration of encryption algorithms and bucket versioning for data recovery against accidental deletion or corruption.
- **Recommendation**: Add explicit encryption and versioning resources:
  ```hcl
  resource "aws_s3_bucket_versioning" "website_versioning" {
    bucket = aws_s3_bucket.website_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
  }

  resource "aws_s3_bucket_server_side_encryption_configuration" "website_encryption" {
    bucket = aws_s3_bucket.website_bucket.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  ```
- **Classification**: Confirmed finding (static inspection).

---

### TER-01: Unsubstituted S3 Backend Bucket Placeholder
- **Severity**: High
- **Category**: Terraform State / Configuration
- **File & Resource**: `main.tf` (`terraform { backend "s3" { ... } }`)
- **Evidence**: Line 18 explicitly contains `bucket = "REPLACE-WITH-YOUR-UNIQUE-BUCKET-NAME"`.
- **Potential Impact**: Executing `terraform init` will fail immediately because `"REPLACE-WITH-YOUR-UNIQUE-BUCKET-NAME"` is not a valid or existing S3 bucket name.
- **Recommendation**: Replace the placeholder string with a unique bucket name configured during the bootstrap phase before initializing Terraform.
- **Classification**: Confirmed finding (static inspection).

---

### DEP-01: Missing Local `website` Directory Causing Apply Failure
- **Severity**: High
- **Category**: Deployment / Reliability
- **File & Resource**: `main.tf` (`aws_s3_object.website_files`)
- **Evidence**: `fileset("${path.module}/website", "**/*")` iterates over files in `${path.module}/website`, but no such directory exists in the workspace.
- **Potential Impact**: Executing `terraform apply` will fail with an error stating that the directory does not exist, preventing infrastructure provisioning.
- **Recommendation**: Create the `website` directory with sample `index.html` and `error.html` files, or use a conditional check / count if content deployment is optional.
- **Classification**: Confirmed finding (static inspection).

---

### AWS-01: Use of Deprecated `forwarded_values` in CloudFront Cache Behavior
- **Severity**: Medium
- **Category**: AWS Resource Configuration / Best Practices
- **File & Resource**: `main.tf` (`aws_cloudfront_distribution.website_distribution` -> `default_cache_behavior`)
- **Evidence**: The configuration utilizes the `forwarded_values` block inside `default_cache_behavior` (lines 98-103).
- **Potential Impact**: In Terraform AWS Provider v5+, `forwarded_values` is deprecated in favor of `cache_policy_id` and `origin_request_policy_id`. While functional, it relies on legacy patterns and may trigger deprecation warnings.
- **Recommendation**: Refactor to use AWS managed cache policies (e.g., CachingOptimized `658327ea-f89d-4fab-a63d-7e88639e58f3`):
  ```hcl
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "S3-${aws_s3_bucket.website_bucket.bucket}"
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f3" # CachingOptimized
    viewer_protocol_policy     = "redirect-to-https"
  }
  ```
- **Classification**: Confirmed finding (static inspection).

---

### MNT-01: Variable `bucket_name` Lacks Validation Rules
- **Severity**: Low
- **Category**: Maintainability
- **File & Resource**: `variables.tf` (`variable "bucket_name"`)
- **Evidence**: The variable definition contains only `description` and `type = string` without a `validation` block.
- **Potential Impact**: Users can supply invalid bucket name characters (e.g., uppercase letters or underscores), causing AWS API validation errors during `terraform apply` when combined with the random suffix.
- **Recommendation**: Add a validation block to enforce S3 naming conventions:
  ```hcl
  variable "bucket_name" {
    description = "Base name for the S3 bucket (will have random suffix added)"
    type        = string
    default     = "static-website"

    validation {
      condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
      error_message = "Bucket name must consist of lower case letters, numbers, and hyphens."
    }
  }
  ```
- **Classification**: Confirmed finding (static inspection).

---

### DOC-01: README State Bucket Instructions Omit Locking/Encryption Requirements
- **Severity**: Low
- **Category**: Documentation
- **File & Resource**: `README.md`
- **Evidence**: The README instructs creating the state bucket via `aws s3api create-bucket` and versioning, but does not mention S3 native state locking requirements (`use_lockfile = true` enabled in `main.tf`) or bucket encryption.
- **Potential Impact**: Operators following the README instructions might encounter permission issues or misaligned state locking configurations when initializing Terraform v1.10+.
- **Recommendation**: Update `README.md` to document encryption and state locking permissions required by Terraform v1.10+.
- **Classification**: Confirmed finding (static inspection).

---

## 6. Positive Aspects of the Current Configuration

The Terraform configuration demonstrates strong alignment with modern cloud security and architecture best practices:
1. **Least-Privilege S3 Access Control**: Completely blocks public access on the S3 bucket (`aws_s3_bucket_public_access_block`) and enforces strict access through CloudFront Origin Access Control (OAC) with condition checks on `AWS:SourceArn`.
2. **Modern State Locking**: Utilizes Terraform v1.10+ native S3 state locking (`use_lockfile = true`), eliminating the need for a separate DynamoDB table.
3. **HTTPS Enforcement**: Configures CloudFront viewer protocol policy to `redirect-to-https`, ensuring encrypted transport in transit.
4. **Development Flexibility**: Incorporates `force_destroy = true` on the website bucket and a `random_id` suffix to prevent name collision during iterative testing.
5. **Clean Code Structure**: Clear separation of concerns across `main.tf`, `variables.tf`, and `outputs.tf`, with well-documented comments explaining architectural decisions.

---

## 7. Items Requiring Live AWS Validation

Because this review was conducted via static analysis without an active AWS account, the following items require live validation post-deployment:
1. **OAC IAM Policy Evaluation**: Verify that the S3 bucket policy condition (`AWS:SourceArn` matching the CloudFront distribution ARN) successfully authenticates CloudFront requests without circular dependency issues during initial creation.
2. **State Lockfile Functionality**: Validate that Terraform v1.10+ `use_lockfile = true` correctly acquires and releases locks on the S3 state bucket during concurrent operations.
3. **Custom Error Response Routing**: Confirm that CloudFront correctly catches 404 errors from S3 and serves `/error.html` as intended when S3 website hosting mode is disabled.
4. **MIME Type Mapping**: Verify that `aws_s3_object` correctly resolves content types via the local `mime_types` map for all deployed website assets.

---

## 8. Recommended Next Steps

1. **Populate Missing Assets**: Create a `website/` directory containing `index.html` and `error.html` to satisfy `aws_s3_object`.
2. **Configure Backend Bucket**: Update `main.tf` with the provisioned S3 remote state bucket name.
3. **Run Terraform Initialization & Validation**: Execute `terraform init` and `terraform validate` in an authenticated environment.
4. **Implement Security Enhancements**: Add explicit encryption and versioning resource blocks (`SEC-01`) and variable validation (`MNT-01`).
5. **Modernize CloudFront Cache Behavior**: Replace `forwarded_values` with managed cache policies (`AWS-01`).

---

## 9. Review Limitations

- **No Live Environment**: Inspection was restricted to static source code analysis.
- **Excluded Content**: Website implementation files were excluded as per review scope.
- **Environment Constraints**: Verification of AWS IAM policy evaluation semantics and provider compatibility was performed theoretically rather than empirically.
