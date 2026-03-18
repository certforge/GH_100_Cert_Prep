# GH-100 Lab Verification Framework

This repo includes a reusable lab verification framework designed for **forked repositories only**.

## Why Fork-Only

The upstream study repo should remain content-focused. Lab verification is intended for:
- personal practice in your own fork
- cohort training forks
- internal sandbox copies of this repository

The workflow checks `github.event.repository.fork`. If the repository is not a fork, it exits without doing verification work.

## Components

- Issue form: `.github/ISSUE_TEMPLATE/lab-exercise.yml`
- PR template: `.github/pull_request_template.md`
- Workflow: `.github/workflows/lab-verification.yml`
- Verifier script: `scripts/lab/verify-pr.sh`
- Submission folder: `lab-submissions/`

## Submission Rules

Every lab PR in a fork should include:

1. `Lab-ID: <official-lab-id>` in the PR body
2. `Issue: #<number>` in the PR body
3. `Validation-Evidence: <value>` in the PR body
4. One markdown submission file under `lab-submissions/<lab-id>/`

## Official Lab IDs

- `domain-1-enterprise-support`
- `domain-2-identity-authentication`
- `domain-3-deployment-licensing`
- `domain-4-access-permissions`
- `domain-5-security-compliance`
- `domain-6-github-actions`

## What the Workflow Verifies

- PR metadata contains the expected fields
- a submission file was changed in the correct lab directory
- the submission file contains standard evidence sections
- the submission contains domain-appropriate keywords or artifacts

## What It Does Not Fully Automate

- org-level or enterprise-level settings verification
- live SAML or SCIM integrations
- actual GitHub Enterprise Cloud or GHES administration outside the repo
- audit log stream delivery to external systems

Those still require screenshots, exports, and reviewer judgment in the fork PR.
