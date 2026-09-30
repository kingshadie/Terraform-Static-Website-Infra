# Run 1 Diagnosis

## Problem 1 — Missing website directory finding

### Diagnosis
Context

### Reason
The actual repository contains the website directory, but the website files were deliberately excluded from the Run 1 context package. Gemini therefore interpreted an incomplete workspace as evidence that the Terraform configuration referenced a missing directory.

### Change for Run 2
Add `website/index.html` and `website/error.html` to the context package.

The infrastructure review scope will remain focused on Terraform and AWS infrastructure. The agent must not review website content unless it is directly relevant to validating the Terraform configuration.

---

## Problem 2 — Dependency relationship interpretation

### Diagnosis
Instructions

### Reason
The Run 1 prompt asked the agent to assess dependencies and potential deployment failure points, but it did not require dependency claims to be demonstrated from the actual Terraform reference graph.

### Change for Run 2
Require the agent to distinguish:
- direct Terraform dependencies,
- indirect resource relationships,
- actual dependency cycles,
- and issues that require validation.

The agent must provide the Terraform references supporting any dependency or ordering claim.

---

## Problem 3 — Confirmed findings versus validation-dependent conclusions

### Diagnosis
Instructions

### Reason
The Run 1 prompt instructed the agent not to claim live AWS validation, but it did not impose a strict classification system for static findings versus issues requiring additional validation.

### Change for Run 2
Require every finding to be classified as one of:
- Confirmed by supplied files
- Requires additional validation
- Assumption / not sufficient to classify as a finding

Only the first two categories may appear as findings in the report.

---

## Run 2 objective

Run 2 will test whether:
1. providing the missing website files removes the false missing-directory finding;
2. tighter dependency instructions produce more evidence-based dependency analysis; and
3. explicit finding classification improves the distinction between confirmed static issues and validation-dependent issues.

No Terraform files will be modified.
No AWS deployment will be performed.
