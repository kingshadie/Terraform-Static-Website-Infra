# Run 1 Review

## What the agent did well

* The agent inspected all four supplied files before producing the report: `README.md`, `main.tf`, `variables.tf`, and `outputs.tf`.
* It correctly identified the main infrastructure relationships: the S3 bucket is the CloudFront origin, CloudFront uses Origin Access Control (OAC), and the S3 bucket policy restricts access to the CloudFront distribution.
* It respected the instruction not to deploy or perform live AWS validation and identified areas that would require validation in an AWS environment.
* The report was structured and reviewable, with findings, evidence, impact, recommendations, positive aspects, validation requirements, and limitations.
* The work trail was useful because it recorded inspected files, dependencies, assumptions, uncertainties, and a rejected finding.

## Problems identified

### Problem 1

**Finding:**
The agent reported that the `website/` directory was missing and treated this as a confirmed deployment/reliability problem.

**Why I believe this is a problem:**
The actual project contains `website/index.html` and `website/error.html`. These files were deliberately excluded from the Gemini workspace because the review was scoped to infrastructure configuration. Therefore, the agent's observation that the directory was missing was correct only within the supplied workspace. It was not evidence that the actual project was missing the directory.

**Evidence:**
The Terraform configuration contains:

`fileset("${path.module}/website", "**/*")`

The original project also contains the `website/` directory and its HTML files. Those files were intentionally excluded from the context package.

**Diagnosis:** Context

**Why I chose that lever:**
The agent did not have access to the complete project context. The exclusion was intentional for the first run, but it created an input gap that affected the agent's conclusion. For Run 2, I should provide enough context for the agent to know that the directory exists while still telling it that website implementation is outside the infrastructure-review scope.

---

### Problem 2

**Finding:**
The agent described the relationship between the CloudFront distribution and the S3 bucket policy as potentially involving an ordering or circular-dependency concern.

**Why I believe this is a problem:**
The Terraform references should be examined as a dependency graph rather than assuming that two resources referencing each other create a circular dependency. The CloudFront distribution references the S3 bucket, while the bucket policy uses the CloudFront distribution ARN. The bucket policy itself does not appear to be referenced by the CloudFront distribution.

**Evidence:**
In `main.tf`:

* `aws_cloudfront_distribution.website_distribution` references `aws_s3_bucket.website_bucket`.
* `aws_s3_bucket_policy.bucket_policy` references `aws_s3_bucket.website_bucket`.
* `data.aws_iam_policy_document.bucket_policy` references `aws_cloudfront_distribution.website_distribution.arn`.

This should be treated as a Terraform dependency relationship requiring careful review rather than automatically describing it as circular.

**Diagnosis:** Instructions

**Why I chose that lever:**
The initial prompt asked the agent to inspect dependencies and potential deployment failure points, but it did not require the agent to distinguish an actual dependency cycle from an ordinary resource dependency. Run 2 should explicitly require dependency claims to be supported by the Terraform reference graph.

---

### Problem 3

**Finding:**
The agent's review identified some valid configuration concerns, but some recommendations were presented with more certainty than the static evidence justified.

**Why I believe this is a problem:**
The task was limited to static inspection without an AWS account. A static review can identify configuration patterns and likely issues, but provider behaviour, deployment ordering, IAM policy evaluation, and successful resource creation may require `terraform validate`, `terraform plan`, provider documentation, or live AWS testing.

**Evidence:**
The Run 1 report includes findings around CloudFront configuration, Terraform backend behaviour, and AWS policy/dependency behaviour while also acknowledging that no live AWS validation was available.

**Diagnosis:** Instructions

**Why I chose that lever:**
The initial prompt did tell the agent not to claim live validation, but it did not give a sufficiently strict structure for separating confirmed static findings from findings requiring further validation. Run 2 should require every finding to be explicitly classified as confirmed by static evidence, requiring additional validation, or an assumption that must not be treated as a finding.

## Trajectory observations

* The agent followed the requested inspection sequence and created the report only after examining the supplied files.
* The agent maintained a useful work trail and recorded uncertainty instead of hiding it.
* The strongest trajectory issue was the interpretation of incomplete context. The missing `website/` directory was caused by a deliberate context decision rather than a defect in the actual repository.
* The agent was generally able to distinguish static inspection from live AWS validation, but some dependency and configuration conclusions needed tighter evidence requirements.
* The report structure was useful, but the initial instructions could have provided stronger rules for classifying findings and separating confirmed issues from items requiring validation.

## What I will change for Run 2

* Add the relevant `website/` files to the context so the agent knows they exist, while explicitly keeping website implementation outside the infrastructure-review scope.
* Require the agent to distinguish between confirmed static findings, items requiring additional validation, and assumptions.
* Require dependency claims to be supported by the actual Terraform reference relationships rather than inferred from resource relationships alone.
* Require each material finding to include the exact evidence supporting the conclusion.
* Keep the instruction that the agent must not modify files, deploy infrastructure, or claim live AWS validation.
* Compare Run 2 against Run 1 to determine whether the deliberate context and instruction changes improve the quality of the review.

