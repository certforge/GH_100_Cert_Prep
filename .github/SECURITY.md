# Security Policy

## About This Repository

This repository contains study materials for the GH-100: GitHub Administration certification exam. It is a documentation and educational content repository — it does not contain production code, APIs, or services.

## Scope of Security Reports

Because this is a static content repository, the attack surface is limited. However, we take the following seriously:

- **Malicious content**: Scripts in `scripts/` or workflows in `.github/workflows/` that contain harmful code
- **Credential exposure**: Any actual API keys, tokens, or credentials accidentally committed (if found, they are test/fake — but still report)
- **Workflow security issues**: GitHub Actions workflows that are configured insecurely

## What Is NOT in Scope

- Broken links in documentation (open a regular issue)
- Outdated technical content (open a regular issue or PR)
- Typos and formatting issues (open a PR directly)
- Content accuracy disputes (open an issue for discussion)

## Reporting a Security Issue

If you find a genuine security issue in this repository:

1. **Do not** open a public GitHub issue
2. Use [GitHub's private vulnerability reporting](../../security/advisories/new) to submit a confidential report
3. Or email the repository maintainer directly (check the profile linked from repo owner)

We will acknowledge your report within **72 hours** and provide a response within **7 days**.

## What to Include in Your Report

- Description of the issue
- The file(s) affected
- Potential impact
- Steps to reproduce (if applicable)
- Suggested remediation (if you have one)

## Our Commitment

We will:
- Acknowledge receipt of your report promptly
- Investigate and address legitimate security issues
- Credit you in the commit message or CHANGELOG if you'd like (with your permission)

## GitHub Actions Workflow Security

Our workflows follow these practices:
- Pin action versions to specific SHAs or tags
- Use minimal `permissions` (principle of least privilege)
- Do not use `pull_request_target` trigger unnecessarily
- Validate all external inputs

If you find any of our workflows violating these practices, please report it.
