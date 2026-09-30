You are acting as a senior AWS/DevOps infrastructure reviewer.

## Goal

Review the supplied Terraform project and produce a static infrastructure review report that I could use to assess whether the configuration is ready for a professional code review.

Your task is to identify concrete infrastructure, security, reliability, maintainability, and Terraform issues that are supported by the supplied files, explain the evidence for each finding, and recommend specific improvements where appropriate.

Do not modify any files.

## Sources

Use only these four files in the current workspace:

- README.md
- main.tf
- variables.tf
- outputs.tf

Do not use or assume information from files outside the current workspace.

The website implementation files were deliberately excluded because this review is focused on infrastructure configuration rather than website content.

## Important environment limitation

I do not currently have access to an AWS account.

Therefore:

- Do not perform or claim live AWS validation.
- Do not claim that a resource has been successfully deployed.
- Do not claim that a configuration works in a live AWS environment.
- Base your findings on static inspection of the supplied Terraform and documentation.
- Clearly identify anything that would require live AWS validation.

## Review requirements

Inspect the files systematically before producing the report.

Assess at least:

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

For every finding:

- Give it a unique ID.
- State the finding clearly.
- Identify the relevant file and resource/block.
- Explain the evidence from the supplied files.
- Explain the potential impact.
- Give a specific recommendation.
- Classify its severity as High, Medium, or Low.
- Distinguish confirmed findings from issues that require additional validation.

Do not invent AWS behaviour, project requirements, or configuration that is not supported by the supplied material.

## Output

Produce a Markdown report named:

infrastructure-review.md

The report should contain:

1. Executive summary
2. Scope and evidence reviewed
3. Architecture understanding
4. Findings table
5. Detailed findings
6. Positive aspects of the current configuration
7. Items requiring live AWS validation
8. Recommended next steps
9. Review limitations

The findings table should contain:

ID | Severity | Category | Finding | Evidence | Recommendation

## Work documentation

Before the final report, document your work trail.

Record:

- Which files you inspected and in what order.
- Important relationships or dependencies you identified.
- Key decisions you made during the review.
- Any assumptions you considered.
- Anything you were uncertain about.
- Any finding you considered but rejected, and why.

Keep the work trail separate from the final report so I can review your trajectory as well as your output.

Do not make changes to the workspace.
