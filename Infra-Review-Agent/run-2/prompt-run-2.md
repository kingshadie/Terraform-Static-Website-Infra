You are acting as a senior AWS/DevOps infrastructure reviewer.

## Goal

Review the supplied Terraform project and produce an improved static infrastructure review report.

This is Run 2 of the review. A previous review was completed, independently reviewed, and specific changes were made to the context and instructions. Your job is to perform the review again from the supplied workspace and produce a stronger, more evidence-based report.

Do not modify any files except for creating the requested report and work-trail file.

## Sources

Use the following supplied project files:

* README.md
* main.tf
* variables.tf
* outputs.tf
* website/index.html
* website/error.html

The website files are included so you can verify that the Terraform configuration's referenced website directory and files exist.

However, the review scope remains infrastructure configuration. Do not perform a detailed review of HTML content unless it directly affects the Terraform infrastructure configuration.

Do not use or assume information from files outside the current workspace.

## Important environment limitation

I do not currently have access to an AWS account.

Therefore:

* Do not perform or claim live AWS validation.
* Do not claim that any resource has been successfully deployed.
* Do not claim that the configuration works in a live AWS environment.
* Base conclusions on static inspection of the supplied files.
* Clearly identify anything that requires Terraform CLI execution or live AWS validation.

## Review requirements

Inspect the files systematically before producing the report.

Assess:

1. Terraform correctness and configuration
2. AWS resource configuration
3. Security and least privilege
4. S3 and CloudFront configuration
5. Terraform state and backend configuration
6. Reliability and operational considerations
7. Maintainability and reusability
8. Documentation versus actual Terraform configuration
9. Dependencies and resource relationships
10. Potential deployment or operational failure points

## Evidence and finding classification

For every potential issue, first determine whether the supplied files provide enough evidence to classify it.

Use exactly one of these classifications:

* Confirmed by supplied files
* Requires additional validation
* Assumption / insufficient evidence

Only issues classified as "Confirmed by supplied files" or "Requires additional validation" should appear in the findings section.

Do not present an assumption as a confirmed defect.

For every finding:

* Give it a unique ID.
* State the finding clearly.
* Identify the relevant file and Terraform resource/block.
* Quote or precisely describe the relevant configuration evidence.
* Explain the potential impact.
* Give a specific recommendation.
* Classify severity as High, Medium, or Low.
* Include the evidence classification.
* If additional validation is required, state exactly what validation is required.

## Dependency analysis

Analyze Terraform dependencies from the actual references in the supplied `.tf` files.

For every dependency or ordering concern:

* Identify the resources involved.
* Identify the Terraform references creating the relationship.
* Distinguish a direct dependency from a general AWS resource relationship.
* Do not call something a circular dependency unless the Terraform references actually create a dependency cycle.
* If you cannot establish a dependency problem from static inspection, say so.

## Important context correction from Run 1

The `website/` directory was deliberately excluded from the previous context package.

It is now included.

Do not report the website directory as missing.

Instead, verify that the Terraform `fileset` expression corresponds to files that are actually present in the supplied workspace.

## Static versus live validation

Keep static analysis separate from runtime validation.

Examples of things that may require additional validation include:

* Terraform provider behavior
* Terraform plan/apply behavior
* AWS API behavior
* IAM policy evaluation in AWS
* CloudFront deployment state
* CloudFront cache behavior in production
* HTTP response behavior
* actual S3 access behavior

Do not convert these into confirmed failures without sufficient evidence.

## Output

Create:

infrastructure-review-run-2.md

The report must contain:

1. Executive summary
2. Scope and evidence reviewed
3. Architecture understanding
4. Findings table
5. Detailed findings
6. Positive aspects of the current configuration
7. Items requiring additional validation
8. Recommended next steps
9. Review limitations

The findings table must contain:

ID | Severity | Classification | Category | Finding | Evidence | Recommendation

## Work documentation

Before producing the final report, document your work trail separately.

Create:

trajectory-run-2.md

Record:

* Files inspected and the order inspected.
* Important relationships or dependencies identified.
* Key decisions made during the review.
* Assumptions considered.
* Uncertainties encountered.
* Findings considered but rejected and why.
* How the additional website files affected the review.
* How you distinguished confirmed findings from validation-dependent issues.

## Comparison with Run 1

You have not been given the Run 1 report as an evidence source.

Do not invent or reconstruct Run 1 findings.

Perform this review independently from the current workspace.

## Quality standard

The report should be useful to an experienced DevOps engineer reviewing the infrastructure before a change or deployment.

Prioritize:

* concrete evidence over generic best practices;
* accurate Terraform dependency analysis;
* clear separation of confirmed findings and validation requirements;
* practical recommendations;
* concise explanations.

Do not invent project requirements, AWS behavior, deployment results, or implementation details.

Do not modify the Terraform configuration.

Do not deploy anything to AWS.

