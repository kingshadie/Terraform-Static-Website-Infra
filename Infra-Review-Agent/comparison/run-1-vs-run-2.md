# Run 1 vs Run 2 Comparison

## 1. Project and Task

The capstone task was to direct an AI agent to perform a realistic infrastructure review of an existing Terraform project for AWS static website hosting.

The agent was instructed to:

* inspect the supplied Terraform and documentation;
* identify infrastructure, security, reliability, maintainability, and Terraform issues;
* produce a structured infrastructure review report;
* document its work trail;
* avoid modifying the Terraform configuration;
* avoid live AWS validation because no AWS account was available.

The review artifact was a Markdown infrastructure review report.

---

## 2. Run 1

### Context Provided

Run 1 supplied four files:

* `README.md`
* `main.tf`
* `variables.tf`
* `outputs.tf`

The website files were deliberately excluded because the initial review scope focused on infrastructure configuration.

### What Run 1 Did Well

The agent:

* inspected all supplied files;
* identified the main S3 and CloudFront architecture;
* understood the CloudFront Origin Access Control and S3 bucket policy relationship;
* respected the restriction against live AWS validation;
* produced a structured review report;
* documented its work trail and uncertainties.

### Problems Identified

#### Problem 1 — False missing-directory finding

The agent reported that the `website/` directory was missing because Terraform referenced:

`fileset("${path.module}/website", "**/*")`

The actual project contained that directory, but it had been deliberately excluded from the agent's context.

**Diagnosis:** Context.

#### Problem 2 — Dependency analysis needed tighter evidence

The first prompt asked the agent to assess dependencies and potential deployment failure points but did not require dependency claims to be demonstrated from actual Terraform references.

**Diagnosis:** Instructions.

#### Problem 3 — Evidence classification was not strict enough

The first prompt required static analysis but did not impose a clear classification system separating confirmed findings from validation-dependent conclusions.

**Diagnosis:** Instructions.

---

## 3. Deliberate Changes Before Run 2

Three deliberate changes were made.

### Context Change

The following files were added:

* `website/index.html`
* `website/error.html`

This allowed the agent to verify that the directory referenced by Terraform actually existed.

The review scope remained focused on infrastructure rather than website content.

### Instruction Change — Dependency Analysis

The Run 2 prompt required the agent to:

* identify the resources involved;
* cite Terraform references;
* distinguish direct dependencies from general AWS relationships;
* avoid calling a relationship circular unless the references actually created a cycle.

### Instruction Change — Evidence Classification

The Run 2 prompt required every potential issue to be classified as:

* Confirmed by supplied files
* Requires additional validation
* Assumption / insufficient evidence

Only the first two categories were permitted in the findings.

---

## 4. Run 2

### Context Provided

Run 2 supplied:

* `README.md`
* `main.tf`
* `variables.tf`
* `outputs.tf`
* `website/index.html`
* `website/error.html`

### Improvements Observed

The agent verified that the `website/` directory and its files existed.

The previous missing-directory finding was removed.

The agent also performed a more explicit Terraform dependency analysis and concluded that the supplied resource references did not establish a circular dependency.

The second run identified additional concrete findings, including:

* the unsubstituted S3 backend bucket placeholder;
* the CloudFront `forwarded_values` configuration;
* missing explicit website-bucket versioning/encryption resource blocks;
* missing variable validation;
* incomplete state-backend documentation.

The agent also kept its review within the stated no-AWS environment limitation.

---

## 5. Problems Discovered During Run 2

Run 2 exposed additional issues with agent control and output quality.

### Problem 1 — Previous report remained in the workspace

The Run 2 trajectory shows that Gemini read `infrastructure-review.md`, which was the preserved Run 1 report still present in the active workspace.

The Run 2 instructions had stated that the previous report was not being supplied as evidence.

**Diagnosis:** Workspace control.

This demonstrates that excluding information through instructions is weaker than physically removing that information from the agent's workspace.

### Problem 2 — Output filenames were not followed

The prompt requested:

* `infrastructure-review-run-2.md`
* `trajectory-run-2.md`

The agent instead created:

* `infrastructure-review.md`
* `work-trail.md`

The generated files were subsequently preserved outside the agent workspace using the required evidence filenames.

**Diagnosis:** Instructions / workspace ambiguity.

### Problem 3 — One security finding was too strongly classified

The agent classified the absence of explicit S3 encryption and versioning resources as a confirmed Medium security/compliance finding.

The files establish that those Terraform resource blocks are absent. They do not, by themselves, establish that the project has a compliance requirement for those controls.

**Diagnosis:** Instructions.

The agent needed a stronger distinction between:

* factual configuration observations;
* project-specific requirements;
* recommended best practices;
* runtime validation.

### Problem 4 — A potential output issue was missed

The agent inspected `outputs.tf` but did not identify the malformed-looking `website_url` output expression.

This demonstrates that adding context and improving instructions did not eliminate omissions from the agent's review.

**Diagnosis:** Instructions / review coverage.

---

## 6. Run Comparison

| Review Area                  | Run 1                               | Run 2                                     | Observation                           |
| ---------------------------- | ----------------------------------- | ----------------------------------------- | ------------------------------------- |
| Context completeness         | Website directory excluded          | Website directory included                | Run 2 had better evidence             |
| Website reference validation | False missing-directory finding     | Files verified                            | Targeted improvement succeeded        |
| Dependency analysis          | Some uncertainty                    | Explicit Terraform references examined    | Targeted improvement succeeded        |
| Evidence classification      | Less structured                     | Explicit classifications required         | Improved                              |
| Backend configuration        | Not identified                      | Placeholder identified                    | Additional finding                    |
| Static AWS review            | Performed                           | Performed                                 | Maintained                            |
| Live validation boundary     | Respected                           | Respected                                 | Maintained                            |
| Workspace isolation          | No previous report issue identified | Previous report was read                  | New workspace-control problem exposed |
| Output naming                | Not applicable                      | Requested names not followed              | Still needs improvement               |
| Finding accuracy             | Some overreach                      | Better overall, but SEC-01 was too strong | Further instruction refinement needed |
| Review completeness          | Missed some issues                  | Still missed `website_url` concern        | Agent remains imperfect               |

---

## 7. What the Iteration Demonstrated

The iteration showed that changing the agent's context and instructions changed its behaviour.

The Run 1 context omission directly caused a false finding about the website directory. Supplying the missing files in Run 2 allowed the agent to verify the directory and remove that finding.

The Run 2 dependency instructions also produced a more explicit analysis based on actual Terraform references rather than loosely describing resource relationships.

The stricter evidence-classification instructions improved the structure of the findings, although the agent still over-classified the S3 encryption/versioning issue.

The workspace issue showed that agent control depends on both instructions and the actual files available to the agent. Leaving the previous report in the workspace gave the agent access to information that the prompt intended to exclude.

---

## 8. Evidence Chain

The capstone evidence chain is:

1. **Real project**
   Existing Terraform AWS static website infrastructure project.

2. **Context package**
   Selected Terraform, documentation, and website files assembled for agent review.

3. **Run 1**
   Agent produced an infrastructure review and work trail.

4. **Independent review**
   Run 1 output was reviewed and specific problems were identified.

5. **Diagnosis**
   Each problem was mapped to Context, Instructions, or Workspace.

6. **Deliberate iteration**
   Website files were added and the review instructions were strengthened.

7. **Run 2**
   Agent performed the review again.

8. **Comparison**
   Run 1 and Run 2 were compared to identify improvements and remaining problems.

This provides a traceable connection between the task, agent behaviour, human review, diagnosis, intervention, and subsequent result.

---

## 9. Final Assessment

Run 2 was stronger than Run 1 in context completeness, dependency analysis, and evidence classification.

It was not treated as perfect. The review exposed additional weaknesses in workspace control, instruction following, finding classification, and review completeness.

The main lesson from the exercise is that directing an agent is an iterative process. A useful result depends on the quality of the source material, workspace boundaries, instructions, and human review of both the final artifact and the agent's work trajectory.

No Terraform files were modified and no live AWS deployment was performed during the capstone work.

