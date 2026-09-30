# Run 2 Diagnosis

## Overall Assessment

Run 2 produced a stronger infrastructure review than Run 1 because the context package was expanded and the instructions required more explicit evidence classification and Terraform dependency analysis.

The run also exposed two agent-control issues: the Run 1 report remained accessible in the workspace, and the agent did not follow the requested output filenames.

---

## Problem 1 — Run 1 report remained accessible to the agent

### Diagnosis

Workspace

### Reason

The Run 2 instructions stated that the agent had not been given the Run 1 report as an evidence source. However, `infrastructure-review.md` from Run 1 remained physically present in the Gemini workspace.

The Run 2 trajectory confirms that Gemini read `infrastructure-review.md` before completing the review.

This means the workspace contained material that the instructions intended to exclude.

### Impact

Run 2 cannot be treated as a completely independent review because the agent had access to the previous report and explicitly read it.

### Change for a future run

Remove or relocate prior run outputs from the active agent workspace before starting a new independent run.

The evidence copies should remain outside the agent workspace.

---

## Problem 2 — Requested output filenames were not followed

### Diagnosis

Instructions / Workspace ambiguity

### Reason

The Run 2 prompt requested:

* `infrastructure-review-run-2.md`
* `trajectory-run-2.md`

The agent instead created:

* `infrastructure-review.md`
* `work-trail.md`

An existing `infrastructure-review.md` was already present in the workspace, which may have contributed to the agent reusing that filename.

### Impact

The required evidence was still preserved manually outside the agent workspace, but the agent did not follow the requested output naming instructions.

### Change for a future run

Use an empty output directory for each run and explicitly state the exact output paths. Do not place previous run artifacts in the active workspace.

---

## Problem 3 — SEC-01 was classified too strongly

### Diagnosis

Instructions

### Reason

Run 2 correctly observed that the website S3 bucket does not contain explicit Terraform resources for versioning or server-side encryption.

However, the report classified the absence as a confirmed Medium security/compliance finding and stated that enterprise or regulatory requirements would mandate these controls.

Those requirements were not established by the supplied project files.

### Impact

The agent moved from a confirmed configuration observation to a stronger security conclusion without project-specific evidence establishing that versioning or a particular encryption configuration was required.

### Change for a future run

Require the agent to distinguish:

1. What the code directly demonstrates.
2. What is a recommended best practice.
3. What depends on project requirements.
4. What requires external or live validation.

Severity should be based on evidence available in the supplied context, not generic enterprise assumptions.

---

## Problem 4 — `website_url` output was not identified

### Diagnosis

Instructions

### Reason

The agent inspected `outputs.tf` but did not identify the malformed-looking `website_url` output expression.

This is relevant to the requested Terraform correctness and output review because the output is intended to provide the website URL.

### Impact

The second run missed a potentially concrete Terraform/output issue despite having the relevant source file.

### Change for a future run

Require a line-by-line review of output definitions and explicit validation of whether output values represent the type and format described by their descriptions.

Where Terraform CLI validation is unavailable, the agent should identify the issue as a static code observation and distinguish it from a runtime failure.

---

## What Run 2 Improved

Run 2 successfully addressed the main Run 1 context problem.

* The `website/` directory was supplied.
* `index.html` and `error.html` were verified.
* The previous missing-directory finding was removed.
* Dependency analysis was tied to explicit Terraform references.
* The agent explicitly classified findings.
* The backend placeholder was identified.
* The final report contained a structured work trail.

---

## What I Would Change Next

If another run were required, I would:

1. Start with a clean agent workspace containing only intended source files.
2. Keep all previous reports and evidence outside that workspace.
3. Specify exact output paths in a clean output directory.
4. Require evidence-based severity rather than generic best-practice assumptions.
5. Require explicit review of every Terraform output and input.
6. Keep static observations separate from requirements and runtime validation.

The main lesson from Run 2 is that improving the prompt helped, but controlling the workspace was also necessary. The agent's available context directly affected its trajectory and conclusions.

