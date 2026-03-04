# Domain 5 — Enable Secure Software Development and Ensure Compliance

**Exam Weight: 36%**
**Approximate Questions: 29-36**
**Priority: CRITICAL — This domain alone determines pass/fail**

---

## Domain Overview

Domain 5 is the most heavily weighted domain in the GH-100 exam at 36%. Nearly every third question on the exam tests security and compliance knowledge. This document covers:

- GitHub Advanced Security (GHAS) licensing and enablement
- Secret scanning (alerts + push protection)
- Dependabot (alerts, security updates, version updates)
- Code scanning (CodeQL, default setup, SARIF)
- Branch protection rules and rulesets for security
- Dependency review
- Security policies and private vulnerability reporting
- Audit log and compliance
- IP allow lists
- Supply chain security (SBOM, Dependency Graph)
- Security at scale (enterprise-wide enablement)

**Study this domain twice. Know it deeply.**

---

## 5.1 GitHub Advanced Security (GHAS)

### What Is GHAS?

GitHub Advanced Security is a licensed suite of security features. It includes:

1. **Code scanning** — automated vulnerability detection in code
2. **Secret scanning** (including push protection) — detect and block secrets
3. **Dependency review** — view vulnerable dependency changes in PRs

### Licensing Model

| Repo Type | GHAS Required? |
|-----------|---------------|
| Public repos on GitHub.com | No — GHAS features free for public repos |
| Private repos on GitHub.com | Yes — GHAS license required |
| Internal repos on GHEC | Yes — GHAS license required |
| Private repos on GHES | Yes — GHAS license required |

GHAS is licensed **per active committer**. An active committer is defined as a user who has committed to at least one private/internal repository in the past 90 days.

### Enabling GHAS

**Repository level**: `Repo Settings > Security > GitHub Advanced Security > Enable`

**Organization level** (all current repos):
`Org Settings > Code security and analysis > GitHub Advanced Security > Enable all`

**Enterprise level** (all orgs):
`Enterprise Settings > Code security > GitHub Advanced Security > Enable all`

**Via API**:
```bash
# Enable GHAS for a repo
gh api repos/ORG/REPO -X PATCH -f security_and_analysis='{"advanced_security":{"status":"enabled"}}'
```

### GHAS Enablement at Scale

For large enterprises with many repos, use the REST API to enable GHAS programmatically:

```bash
# List repos with GHAS disabled
gh api orgs/ORG/repos --paginate --jq '.[] | select(.security_and_analysis.advanced_security.status == "disabled") | .full_name'

# Enable GHAS on all repos in org
gh api orgs/ORG/repos --paginate --jq '.[].name' | xargs -I REPO \
  gh api repos/ORG/REPO -X PATCH \
  -f security_and_analysis='{"advanced_security":{"status":"enabled"}}'
```

---

## 5.2 Secret Scanning

### Overview

Secret scanning automatically detects secrets (API keys, tokens, passwords, certificates) that have been committed to a repository. There are two distinct components:

| Component | What It Does | When It Triggers |
|-----------|-------------|-----------------|
| Secret scanning alerts | Detects secrets in existing code and new commits | After the push is accepted |
| Push protection | Blocks the push if secrets are detected | Before the push is accepted |

### How Secret Scanning Works

GitHub maintains a database of secret patterns provided by partners (the **GitHub Partner Program**). Currently 100+ providers (AWS, Google, Stripe, Twilio, Azure, etc.) have contributed patterns.

When a commit is made:
1. GitHub scans the content against all known patterns
2. If a match is found, an alert is created (or the push is blocked with push protection)
3. The credential provider is optionally notified (Partner Program partners receive automatic alerts)

### Secret Scanning Alerts

**Enabling**:
- Repository: `Repo Settings > Security > Secret scanning > Enable`
- Organization: `Org Settings > Code security and analysis > Secret scanning > Enable all`
- Enterprise: `Enterprise Settings > Code security > Secret scanning > Enable all`

**Alert States**:

| State | Meaning |
|-------|---------|
| Open | Active, unresolved alert |
| Resolved: Revoked | The secret has been revoked at the provider |
| Resolved: False positive | Not an actual secret |
| Resolved: Used in tests | The secret is a test credential |
| Resolved: Won't fix | Acknowledged but not addressing |

**Accessing Alerts**:
- Repository: `Security tab > Secret scanning`
- Organization: `Security tab > Secret scanning` (org-level security overview)
- Enterprise: `Enterprise Settings > Security > Secret scanning`

**Via API**:
```bash
# List all open secret scanning alerts for a repo
gh api repos/ORG/REPO/secret-scanning/alerts \
  --jq '.[] | {number: .number, type: .secret_type, state: .state}'

# Dismiss an alert
gh api repos/ORG/REPO/secret-scanning/alerts/ALERT_NUMBER -X PATCH \
  -f state="resolved" \
  -f resolution="false_positive"
```

### Push Protection

Push protection blocks pushes containing secrets **before they reach the repository**. This is the preventative control; secret scanning alerts are the detective control.

**Key Behaviors**:
- The push is blocked with an error message indicating which secret was detected
- The user must remove the secret and re-commit, or bypass with a justification
- Bypass is logged in the audit log
- Push protection supports a configurable bypass reason requirement

**Enabling Push Protection**:

Repository level:
```
Repo Settings > Security > Secret scanning > Push protection > Enable
```

Organization level (all repos):
```
Org Settings > Code security and analysis > Push protection > Enable all
```

Enterprise level:
```
Enterprise Settings > Code security > Push protection > Enable all
```

**Push Protection Bypass**:
When a user needs to bypass (e.g., pushing a test token):
1. The push is blocked with a link to bypass
2. User must provide a bypass reason
3. Bypass is logged in the audit log with the reason

Admins can review bypass events in the audit log:
```bash
gh api enterprises/ENTERPRISE/audit-log \
  --jq '.[] | select(.action == "repository.secret_scanning_push_protection_bypass")'
```

### Custom Secret Scanning Patterns

Organizations and enterprises can define custom regex patterns for secrets specific to their environment.

**Creating a custom pattern**:
1. `Org Settings > Code security and analysis > Custom patterns > New pattern`
2. Define:
   - Pattern name
   - Secret format (regex)
   - Test string (to validate the pattern)
   - Before secret / after secret context patterns (optional)
3. Click "Publish" to start scanning

**Pattern example** (AWS-style custom token):
```
CUSTOMAPP-[A-Z]{3}-[0-9]{8}-[a-z0-9]{32}
```

**Via API**:
```bash
# Create a custom pattern at org level
gh api orgs/ORG/secret-scanning/custom-patterns -X POST \
  -f name="My Custom Token" \
  -f pattern="MYAPP-[A-Z]{3}-[0-9]{32}"
```

### Secret Scanning with Validity Checks

For some secret types, GitHub can check whether the detected secret is still valid (active) at the provider. Validity status:
- **Active** — Secret is confirmed still valid
- **Inactive** — Secret has been revoked or expired
- **Unknown** — Validity cannot be determined

This helps prioritize alert remediation.

---

## 5.3 Dependabot

### Three Dependabot Features

These are three distinct features — do NOT conflate them on the exam:

| Feature | Trigger | Output | Config Required? |
|---------|---------|--------|-----------------|
| Dependabot alerts | New CVE added to GitHub Advisory Database | Alert notification | No (enabled at repo/org/enterprise level) |
| Dependabot security updates | Dependabot alert created | Auto-PR to fix vulnerable dep | No (enabled alongside alerts) |
| Dependabot version updates | Schedule (cron) | Auto-PR to update dep to latest | Yes (`dependabot.yml` required) |

### Dependabot Alerts

- Triggered when a new vulnerability (CVE or GHSA) is found in the GitHub Advisory Database
- Also triggered when the Advisory Database is updated with new affected versions
- Requires the **Dependency Graph** to be enabled first

**Enabling Dependabot alerts**:
```
Repo Settings > Security > Dependabot alerts > Enable
# OR
Org Settings > Code security and analysis > Dependabot alerts > Enable all
# OR
Enterprise Settings > Code security > Dependabot alerts > Enable all
```

**Alert severity levels**: Critical, High, Medium, Low (based on CVSS score)

**Dismissing alerts**:
```bash
gh api repos/ORG/REPO/dependabot/alerts/ALERT_NUMBER -X PATCH \
  -f state="dismissed" \
  -f dismissed_reason="tolerable_risk" \
  -f dismissed_comment="Mitigated by WAF controls"
```

### Dependabot Security Updates

Automatically creates pull requests to update vulnerable dependencies to patched versions.

**Requirements**:
- Dependabot alerts enabled
- Dependency Graph enabled

**Enabling**:
```
Repo Settings > Security > Dependabot security updates > Enable
# OR
Org Settings > Code security and analysis > Dependabot security updates > Enable all
```

The auto-PR:
- Targets the minimum version update that resolves the vulnerability
- Includes a summary of the CVE
- Includes a compatibility score (likelihood of tests passing)
- Runs your existing CI workflows

### Dependabot Version Updates

Configured via `.github/dependabot.yml`. Keeps dependencies up to date on a schedule.

**`dependabot.yml` example**:
```yaml
version: 2
updates:
  # npm / Node.js
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "America/New_York"
    reviewers:
      - "platform-team"
    labels:
      - "dependencies"
      - "automated"
    open-pull-requests-limit: 10
    ignore:
      - dependency-name: "lodash"
        versions: ["4.x"]
    groups:
      dev-dependencies:
        patterns:
          - "*"
        dependency-type: "development"

  # Docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Supported Ecosystems

| Ecosystem | `package-ecosystem` value |
|-----------|--------------------------|
| npm / Node.js | `npm` |
| Python pip | `pip` |
| Maven | `maven` |
| Gradle | `gradle` |
| Cargo (Rust) | `cargo` |
| Ruby Gems | `bundler` |
| Go modules | `gomod` |
| NuGet (.NET) | `nuget` |
| Composer (PHP) | `composer` |
| Docker | `docker` |
| GitHub Actions | `github-actions` |
| Terraform | `terraform` |
| Hex (Elixir) | `mix` |

### Private Registries with Dependabot

When dependencies are in private registries, configure credentials in `dependabot.yml`:

```yaml
version: 2
registries:
  my-private-npm:
    type: npm-registry
    url: https://npm.pkg.github.com
    token: ${{secrets.MY_NPM_TOKEN}}
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    registries:
      - my-private-npm
```

### Grouping Dependabot Updates

Reduce PR noise by grouping related updates:

```yaml
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      # Group all AWS SDK updates together
      aws-sdk:
        patterns:
          - "@aws-sdk/*"
      # Group all dev dependency updates
      dev-deps:
        dependency-type: "development"
```

---

## 5.4 Code Scanning

### What Is Code Scanning?

Code scanning analyzes your code for security vulnerabilities and coding errors. It uses **CodeQL** (GitHub's semantic analysis engine) by default, but also accepts results from third-party tools via SARIF format.

### CodeQL

CodeQL works by:
1. Extracting code into a semantic database
2. Running queries against the database to find vulnerability patterns
3. Reporting results as code scanning alerts

**Supported languages**: C/C++, C#, Go, Java/Kotlin, JavaScript/TypeScript, Python, Ruby, Swift

### Setup Methods

| Method | How | When to Use |
|--------|-----|------------|
| Default setup | One-click in Repo Settings or via org-level rollout | Most repos; no custom config needed |
| Advanced setup | Add `.github/workflows/codeql.yml` workflow manually | Custom configs, scheduled scans, custom queries |

### Default Setup (Recommended Starting Point)

```
Repo Settings > Security > Code scanning > Set up > Default
```

GitHub automatically:
- Detects languages in the repo
- Configures CodeQL for those languages
- Runs on push and PR events
- Results appear in the Security tab

**Enabling default setup at organization level**:
```
Org Settings > Code security and analysis > Code scanning > Default setup > Enable all
```

### Advanced Setup (Workflow-Based)

Create `.github/workflows/codeql.yml`:

```yaml
name: CodeQL Advanced Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 6 * * 1'  # Weekly, Monday 6am UTC

jobs:
  analyze:
    name: Analyze (${{ matrix.language }})
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write   # Required for uploading results

    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript', 'python' ]

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          # Optional: specify query suites
          queries: security-extended

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      # OR for compiled languages (Java, C++), replace autobuild with actual build steps

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
```

### Third-Party SAST with SARIF

Any static analysis tool that outputs SARIF format can integrate with GitHub code scanning:

```yaml
- name: Upload SARIF results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results.sarif
    category: "my-sast-tool"
```

Tools with GitHub SARIF support: Semgrep, Snyk, SonarCloud, Checkmarx, Veracode, and many more.

### Managing Code Scanning Alerts

**Alert states**: Open, Dismissed, Auto-dismissed, Fixed

**Dismissal reasons**: False positive, Won't fix, Used in tests

```bash
# List open code scanning alerts
gh api repos/ORG/REPO/code-scanning/alerts \
  --jq '.[] | select(.state == "open") | {number: .number, rule: .rule.id, severity: .rule.severity}'

# Dismiss an alert
gh api repos/ORG/REPO/code-scanning/alerts/ALERT_NUMBER -X PATCH \
  -f state="dismissed" \
  -f dismissed_reason="false_positive" \
  -f dismissed_comment="This pattern is safe in our context"
```

### Requiring Code Scanning Results

To enforce code scanning on PRs, add the code scanning check as a required status check in branch protection rules or rulesets.

The check name follows the format: `CodeQL / Analyze (LANGUAGE)` (for default setup) or whatever the workflow job name is.

---

## 5.5 Dependency Review

### What Is Dependency Review?

Dependency review shows you the dependency changes introduced in a pull request. It highlights:
- New dependencies being added
- Existing dependencies being updated
- Whether any changed dependencies have known vulnerabilities

### The `dependency-review-action`

Add this workflow to enforce dependency review on PRs:

```yaml
name: Dependency Review

on:
  pull_request:
    branches: [ main ]

permissions:
  contents: read
  pull-requests: write   # For posting review comments

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          # Fail if any vulnerable dependency is introduced
          fail-on-severity: high
          # Or fail on specific CVSS score
          # fail-on-scopes: runtime
          # Deny specific licenses
          deny-licenses: GPL-3.0, LGPL-2.0
          # Allow specific advisory IDs to be bypassed
          # allow-ghsas: GHSA-xxxx-xxxx-xxxx
```

### Dependency Review Requirements

- **GHAS license** required for private and internal repositories
- **Dependency Graph** must be enabled
- The action runs in a workflow on `pull_request` events

### Making Dependency Review Required

Add the dependency review check as a required status check:
1. Ensure the workflow is set up and running
2. In branch protection / ruleset, add `Dependency Review` as a required status check

---

## 5.6 Branch Protection Rules for Security

### Security-Focused Branch Protection Settings

For `main` or production branches, recommended security settings:

```
Branch: main
Required settings:
- [x] Require a pull request before merging
  - Required approvals: 2
  - [x] Dismiss stale pull request approvals when new commits are pushed
  - [x] Require review from Code Owners
- [x] Require status checks to pass before merging
  - [x] Require branches to be up to date before merging
  - Required checks:
    - CodeQL / Analyze (javascript)
    - ci/test
    - dependency-review
- [x] Require signed commits
- [x] Do not allow bypassing the above settings
- [x] Restrict who can push to matching branches
  - Allow: @release-team
```

### Signed Commits

Requiring signed commits ensures every commit can be cryptographically attributed:

**GPG Signing**:
```bash
# Generate GPG key
gpg --gen-key

# List keys
gpg --list-secret-keys --keyid-format LONG

# Export public key and add to GitHub
gpg --armor --export KEY_ID

# Configure git to sign commits
git config --global user.signingkey KEY_ID
git config --global commit.gpgsign true
```

**SSH Signing (Newer)**:
```bash
# Configure git to sign with SSH key
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

---

## 5.7 Repository Rulesets for Security

### Security-Focused Ruleset Configuration

Enterprise-level ruleset example (via UI or API):

```json
{
  "name": "enterprise-security-baseline",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main", "refs/heads/release/**"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "required_signatures" },
    { "type": "required_pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true
      }
    },
    { "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "required_status_checks": [
          { "context": "CodeQL / Analyze (javascript)" },
          { "context": "ci/test" }
        ]
      }
    },
    { "type": "required_workflows",
      "parameters": {
        "required_workflows": [
          {
            "repository_id": 12345678,
            "path": ".github/workflows/security-scan.yml",
            "ref": "main"
          }
        ]
      }
    },
    { "type": "non_fast_forward" },
    { "type": "deletion" }
  ],
  "bypass_actors": [
    { "actor_id": 1, "actor_type": "OrganizationAdmin", "bypass_mode": "pull_request" }
  ]
}
```

### Ruleset "Evaluate" Mode (Dry Run)

Before enforcing a new ruleset, set it to **Evaluate** mode:
- Rules are evaluated and violations are logged
- Pushes/merges are NOT blocked
- Review the "Insights" tab to see what would have been blocked
- Switch to "Active" when confident the ruleset is correct

---

## 5.8 Security Policies and Private Vulnerability Reporting

### SECURITY.md

A `SECURITY.md` file documents how to report security vulnerabilities:

```markdown
# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2.x.x   | Yes       |
| 1.x.x   | No        |

## Reporting a Vulnerability

Please do not report security vulnerabilities through public GitHub issues.

Instead, use GitHub's private vulnerability reporting:
1. Go to the Security tab of this repository
2. Click "Report a vulnerability"
3. Fill in the vulnerability details

Or email us at: security@company.com

We will acknowledge receipt within 48 hours and provide a detailed response within 5 business days.
```

### Private Vulnerability Reporting

GitHub provides a built-in mechanism for responsible disclosure:

**Enabling for a repository**:
`Repo Settings > Security > Private vulnerability reporting > Enable`

**Enabling for an organization** (all repos):
`Org Settings > Code security and analysis > Private vulnerability reporting > Enable all`

**How it works**:
1. A researcher finds a vulnerability
2. They click "Report a vulnerability" on the repo's Security tab
3. They fill in a form with vulnerability details
4. A private draft security advisory is created
5. Maintainers are notified
6. Maintainers can collaborate with the researcher privately
7. When the fix is ready, the advisory is published (coordinated disclosure)

### Security Advisories

When a vulnerability is discovered and fixed, the maintainer can:
1. Create a security advisory in the repo's Security tab
2. Draft the advisory with CVE details, affected versions, patches
3. Request a CVE ID from GitHub (GitHub is a CVE Numbering Authority)
4. Publish the advisory to the GitHub Advisory Database

---

## 5.9 Security Overview Dashboard

### What Is Security Overview?

The Security Overview provides a centralized view of security posture across all repositories in an organization or enterprise.

**Organization-level**:
`Org > Security tab > Overview`

**Enterprise-level**:
`Enterprise > Security tab > Overview`

### Key Views in Security Overview

| View | What It Shows |
|------|-------------|
| Overview | Summary: repos with/without security features enabled |
| Alerts | All open alerts by type (secret scanning, code scanning, Dependabot) |
| Coverage | Which repos have each security feature enabled |
| Risk | Repos with the most critical/high alerts |

### Using Security Overview for Bulk Feature Enablement

From the Coverage view:
1. Filter to repos where a feature is disabled
2. Select repositories
3. Click "Enable feature" to turn on GHAS, secret scanning, or Dependabot across all selected repos

---

## 5.10 Audit Log and Compliance

### Compliance-Relevant Audit Events

| Event Type | Example Actions | Compliance Use |
|------------|----------------|----------------|
| `repo` | Create, delete, visibility change | Change management |
| `org` | Member add/remove, settings changes | Access governance |
| `team` | Team permissions, member changes | Role-based access control |
| `protected_branch` | Rule create/update/delete | Security control changes |
| `secret_scanning` | Alert dismissed, push protection bypass | Security incident tracking |
| `dependabot` | Alert dismissed, auto-fix PR merged | Vulnerability management |
| `authentication` | Login, 2FA, SAML auth | Authentication audit |

### Audit Log API for Compliance Reporting

```bash
# Export all secret scanning alert dismissals in the last 30 days
gh api enterprises/ENTERPRISE/audit-log \
  --jq '.[] | select(.action | startswith("secret_scanning"))' \
  --paginate

# Find all repository deletions
gh api enterprises/ENTERPRISE/audit-log \
  --jq '.[] | select(.action == "repo.destroy")' \
  --paginate

# Find SAML SSO bypasses
gh api enterprises/ENTERPRISE/audit-log \
  --jq '.[] | select(.action == "org.sso_response")' \
  --paginate
```

### Audit Log Streaming Setup

```bash
# Set up streaming to Amazon S3 (via UI or API)
gh api enterprises/ENTERPRISE/audit-log/streaming-configuration -X PUT \
  -f enabled=true \
  -f vendor_name="amazon_s3" \
  -f s3_access_key_id="AKIAIOSFODNN7EXAMPLE" \
  -f s3_secret_access_key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  -f s3_bucket="my-audit-log-bucket" \
  -f s3_region="us-east-1"
```

### IP Allow Lists

IP allow lists restrict access to specific IP ranges:

**Organization level**:
`Org Settings > Security > Allowed IP addresses`

**Enterprise level**:
`Enterprise Settings > Security > Allowed IP addresses`

**Adding an IP range**:
```bash
gh api orgs/ORG/ip-allow-list-entries -X POST \
  -f allow_list_value="203.0.113.0/24" \
  -f name="Office CIDR" \
  -f is_active=true
```

**Note**: When IP allow lists are enabled, ALL access (web, API, Git) is restricted to the listed ranges. Ensure you add all CI/CD runner IPs, VPN ranges, and office ranges before enabling.

---

## 5.11 Supply Chain Security

### Dependency Graph

The Dependency Graph maps a repository's dependencies based on manifest files. It is the foundation of Dependabot alerts and SBOM generation.

**Enabling**:
- Public repos: Always enabled
- Private repos: `Repo Settings > Security > Dependency graph > Enable`
- Organization: `Org Settings > Code security and analysis > Dependency graph > Enable all`

### Software Bill of Materials (SBOM)

An SBOM is a formal record of all components and dependencies in a software artifact.

**Downloading an SBOM**:
```bash
# Download repo SBOM in SPDX format
gh api repos/ORG/REPO/dependency-graph/sbom --jq '.sbom' > sbom.json

# Download in CycloneDX format
gh api repos/ORG/REPO/dependency-graph/sbom?format=cyclonedx > sbom-cyclonedx.json
```

**Via UI**: `Repo > Insights > Dependency graph > Export SBOM`

### Dependency Submission API

Allows CI/CD pipelines to submit dependency information directly to GitHub:

```yaml
- name: Submit dependency snapshot
  uses: actions/dependency-review-action@v4
  # OR use a package-manager-specific action:
- name: Submit Maven dependencies
  uses: advanced-security/maven-dependency-submission-action@v4
```

---

## 5.12 Managing Security at Scale

### Enterprise Security Enablement Workflow

For a new enterprise or large migration:

1. **Audit current state**: Use Security Overview to assess current alert volumes and feature gaps
2. **Enable Dependency Graph org-wide**: Foundation for everything else
3. **Enable Dependabot alerts org-wide**: Low-noise, high-value (no PRs yet)
4. **Assess GHAS license consumption**: Check committer count before enabling GHAS features
5. **Enable secret scanning org-wide**: Can run on all repos regardless of GHAS for public repos
6. **Enable push protection**: Coordinate with developers; provide training on bypass workflow
7. **Roll out code scanning with default setup**: Start with high-risk repos, then expand
8. **Enable Dependabot security updates**: After alert backlog is manageable
9. **Configure Dependabot version updates**: Via `dependabot.yml` for active repos
10. **Set up security overview dashboards**: Track progress and open alert counts

### Programmatic Security Enablement

```bash
#!/bin/bash
# Enable key security features for all repos in an org

ORG="my-organization"

# Get all repos
repos=$(gh api orgs/$ORG/repos --paginate --jq '.[].name')

for repo in $repos; do
  echo "Enabling security features for $ORG/$repo..."

  # Enable Dependency Graph (for private repos)
  gh api repos/$ORG/$repo -X PATCH \
    -f security_and_analysis='{"dependency_graph":{"status":"enabled"}}' \
    2>/dev/null

  # Enable Dependabot alerts
  gh api repos/$ORG/$repo/vulnerability-alerts -X PUT 2>/dev/null

  # Enable GHAS (requires license)
  gh api repos/$ORG/$repo -X PATCH \
    -f security_and_analysis='{"advanced_security":{"status":"enabled"}}' \
    2>/dev/null

  # Enable secret scanning
  gh api repos/$ORG/$repo -X PATCH \
    -f security_and_analysis='{"secret_scanning":{"status":"enabled"}}' \
    2>/dev/null

  # Enable push protection
  gh api repos/$ORG/$repo -X PATCH \
    -f security_and_analysis='{"secret_scanning_push_protection":{"status":"enabled"}}' \
    2>/dev/null

done
echo "Done."
```

---

## Gotchas and Exam Tips

1. **Push protection vs secret scanning alerts are separate features**. You can have alerts without push protection. Push protection is the preventative control; alerts are the detective control. Both require GHAS for private repos.

2. **GHAS is free for PUBLIC repos on GitHub.com**. The license is only required for private and internal repositories. This is frequently tested.

3. **Dependabot alerts ≠ security updates ≠ version updates**. Three different things. Dependabot alerts are passive notifications. Security updates create PRs to fix vulnerabilities. Version updates create PRs to keep packages current (even without CVEs).

4. **Dependency Graph must be enabled first**. Both Dependabot alerts and dependency review require the Dependency Graph to be enabled. It's a prerequisite.

5. **SCIM is not related to security scanning**. SCIM is user provisioning. A common trick question pairs SCIM with security features.

6. **Push protection can be bypassed**. It is not an absolute block — users with repository write access can bypass push protection with a reason. This is by design (to avoid workflow disruption) but the bypass is logged.

7. **Code scanning with "default setup" vs "advanced setup"**. Default setup is one-click; advanced setup uses a custom workflow YAML. Both produce code scanning alerts. Advanced setup is needed for custom queries or build processes.

8. **SARIF is the format for third-party code scanning results**. If a question mentions uploading results from a third-party tool, the answer involves SARIF.

9. **Security Manager is an org role, not a GHAS feature**. The Security Manager role grants access to manage security alerts — it is not enabled by GHAS.

10. **Enterprise rulesets can require specific workflows**. This is a powerful governance feature: an enterprise ruleset can require a specific `.github/workflows/security-scan.yml` to pass on all repos.

11. **IP allow lists block ALL traffic, including Actions runners**. If you enable an IP allow list and have self-hosted runners on IP ranges not in the list, those runners will be blocked. Add runner IPs first.

12. **Private vulnerability reporting ≠ security advisories**. Private vulnerability reporting is the intake mechanism (how reporters submit). Security advisories are the output (how maintainers disclose).

---

## Practice Questions

### Question 1
**Domain**: Domain 5 — Security & Compliance
**Topic**: GHAS licensing
**Difficulty**: Beginner

A company has a GitHub Enterprise Cloud account. They want to enable code scanning, secret scanning, and dependency review on their private repositories. What is required?

A. These features are included in all GitHub Enterprise Cloud subscriptions at no additional cost
B. A GitHub Advanced Security (GHAS) license is required for private repositories
C. Only code scanning requires GHAS; secret scanning and dependency review are free
D. GHAS features are only available for GitHub Enterprise Server, not Enterprise Cloud

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: **GitHub Advanced Security (GHAS) requires a separate license for private and internal repositories**, even on GitHub Enterprise Cloud. The GHAS license is billed per active committer (users who commit to private/internal repos). Code scanning, secret scanning (including push protection), and dependency review all require GHAS for private/internal repos. However, all GHAS features are FREE for public repositories on GitHub.com. Option C is incorrect — all three features require GHAS for private repos. Option D is incorrect — GHAS is available for both GHEC and GHES.

**Reference**: https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security

</details>

---

### Question 2
**Domain**: Domain 5 — Security & Compliance
**Topic**: Secret scanning vs push protection
**Difficulty**: Intermediate

A developer accidentally committed an AWS access key to a private repository 3 days ago. Secret scanning is enabled but push protection is NOT enabled. What is the current state of the situation?

A. The commit is blocked and the developer cannot push it
B. An alert has been created in the repository's Security tab; the commit is in the repo
C. The AWS access key has been automatically revoked by GitHub
D. No alert is generated because push protection is disabled

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Secret scanning alerts detect secrets **after** they have been committed (detective control). Since the commit was 3 days ago and secret scanning is enabled, a secret scanning alert should have been created in the Security tab. The commit IS in the repository — secret scanning does not block or remove commits; it only generates alerts. Push protection would have blocked the push BEFORE it was committed, but since push protection was not enabled, the commit went through. Option A is incorrect — push protection was not enabled, so nothing was blocked. Option C is incorrect — GitHub does not automatically revoke credentials (some partners are notified, but revocation is the owner's responsibility). Option D is incorrect — secret scanning alerts are generated regardless of push protection.

**Reference**: https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning

</details>

---

### Question 3
**Domain**: Domain 5 — Security & Compliance
**Topic**: Dependabot features
**Difficulty**: Intermediate

A repository has Dependabot alerts enabled. The security team wants to also automatically receive pull requests that fix vulnerable dependencies without any manual configuration per vulnerability. What feature should be enabled?

A. Dependabot version updates (configured via `dependabot.yml`)
B. Dependabot security updates
C. Code scanning with CodeQL security queries
D. The dependency-review-action workflow

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: **Dependabot security updates** automatically creates pull requests to update vulnerable dependencies to patched versions whenever a Dependabot alert is triggered. No per-vulnerability configuration is needed — enabling the feature is sufficient. Dependabot version updates (option A) would also create PRs, but they require a `dependabot.yml` file and update dependencies to their latest versions on a schedule, not specifically in response to security alerts. Code scanning (option C) analyzes code for vulnerabilities but does not manage dependencies. The dependency-review-action (option D) blocks PRs that introduce vulnerabilities but does not create fix PRs.

**Reference**: https://docs.github.com/en/code-security/dependabot/dependabot-security-updates/about-dependabot-security-updates

</details>

---

### Question 4
**Domain**: Domain 5 — Security & Compliance
**Topic**: Dependency review
**Difficulty**: Intermediate

A team wants to ensure that no pull request to `main` can introduce a dependency with a HIGH or CRITICAL severity vulnerability. They already have GHAS and Dependency Graph enabled. What is the correct implementation?

A. Enable Dependabot alerts and configure an alert threshold in branch protection rules
B. Add the `actions/dependency-review-action` workflow with `fail-on-severity: high` and add the workflow as a required status check
C. Enable code scanning to scan dependency files for vulnerabilities
D. Configure Dependabot security updates to block PRs from merging

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: The **dependency-review-action** is specifically designed to check dependency changes in pull requests and can be configured to fail (preventing merge) if new dependencies with vulnerabilities above a certain severity are introduced. Setting `fail-on-severity: high` causes the action to fail when HIGH or CRITICAL vulnerabilities are detected. Adding this workflow check as a **required status check** in branch protection rules prevents merging until the check passes. Option A is incorrect — Dependabot alerts don't block PRs. Option C is incorrect — code scanning analyzes code logic, not dependency changelists specifically. Option D is incorrect — Dependabot security updates create fix PRs; they don't block existing PRs.

**Reference**: https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-dependency-review

</details>

---

### Question 5
**Domain**: Domain 5 — Security & Compliance
**Topic**: Push protection bypass
**Difficulty**: Advanced

An enterprise has enabled push protection at the enterprise level for all repositories. A developer is running integration tests and needs to push a test file that contains a fake API key used only for testing. What should happen when the developer tries to push this file?

A. The push is permanently blocked; the file cannot be pushed under any circumstances
B. The developer can bypass push protection by providing a reason, and the bypass is logged in the audit log
C. The developer must contact an enterprise admin to allowlist their specific token format
D. The developer must use a GitHub App token instead of a personal access token to bypass push protection

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Push protection is designed to prevent accidental secret exposure, not to be an absolute block. When a push is blocked, the user receives a message with the option to **bypass** the protection by providing a reason (e.g., "Used in tests"). This bypass is recorded in the audit log with the reason provided, allowing security teams to review. This is the correct flow for a legitimate test credential scenario. Option A is incorrect — bypass is always available for users with push access. Option C is incorrect — allowlisting specific patterns requires custom patterns management, but it's not the mechanism described; bypass is per-push, not per-pattern. Option D is incorrect — the type of token used for pushing is unrelated to push protection bypass.

**Reference**: https://docs.github.com/en/code-security/secret-scanning/protecting-pushes-with-secret-scanning

</details>

---

### Question 6
**Domain**: Domain 5 — Security & Compliance
**Topic**: Security overview
**Difficulty**: Intermediate

An enterprise security administrator needs to identify all repositories in the enterprise that have secret scanning disabled. What is the most efficient way to find this information?

A. Check each repository's settings individually
B. Use the GitHub Audit Log and filter for secret_scanning disable events
C. Use the Security Overview's Coverage view at the enterprise level
D. Run a GraphQL query against the GitHub API

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: The **Security Overview Coverage view** at the enterprise level is specifically designed to show which repositories have each security feature enabled or disabled. Administrators can filter to show only repos with secret scanning disabled, then select them and enable the feature in bulk. This is far more efficient than checking repositories individually (option A) or constructing complex API queries (option D). The Audit Log (option B) shows events (when something was disabled) but not the current state of all repos — and many repos may have had secret scanning disabled since creation, not as a logged event.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/code-security/security-overview/about-security-overview

</details>

---

### Question 7
**Domain**: Domain 5 — Security & Compliance
**Topic**: IP allow lists
**Difficulty**: Intermediate

An organization enables an IP allow list configured with only the company's office IP ranges. After enabling, developers report that GitHub Actions workflows are failing because the Actions runners cannot reach the GitHub API. What is the most likely cause?

A. IP allow lists do not apply to GitHub Actions
B. The self-hosted runner IPs were not added to the IP allow list
C. GitHub-hosted runner IP ranges were not added to the IP allow list
D. Actions workflows must be re-triggered after enabling an IP allow list

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: When an organization enables an IP allow list, ALL traffic to GitHub's APIs is restricted to the allowed IP ranges — including traffic from GitHub-hosted runners. GitHub-hosted runners use IP addresses from GitHub's published IP ranges, which are not the company's office IP ranges. To fix this, the administrator must add GitHub's Actions runner IP ranges to the allow list (these are published in GitHub's meta API endpoint: `api.github.com/meta`). Option B (self-hosted runners) could also apply if they were using self-hosted runners on non-allowed IPs, but the scenario implies GitHub-hosted runners since "GitHub Actions workflows" are failing without mention of self-hosted runners. Option A is incorrect — IP allow lists DO apply to all GitHub traffic.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-allowed-ip-addresses-for-your-organization

</details>

---

### Question 8
**Domain**: Domain 5 — Security & Compliance
**Topic**: Code scanning setup
**Difficulty**: Beginner

A security engineer wants to enable code scanning across all repositories in an organization using the simplest approach without requiring each repository team to configure workflow files. What should the engineer do?

A. Provide each team with a CodeQL workflow template file and ask them to add it
B. Enable "Code scanning — default setup" at the organization level in Code security and analysis settings
C. Create a repository ruleset that requires the CodeQL workflow to run
D. Configure Dependabot to scan for code vulnerabilities

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: The **default setup for code scanning** can be enabled at the organization level, which automatically configures CodeQL for all repositories in the organization without requiring teams to create or manage workflow files. GitHub automatically detects the programming languages in each repository and configures appropriate CodeQL analysis. This is the simplest approach with no per-team action required. Option A requires team action (not scalable). Option C (rulesets requiring a workflow) would require the workflow to exist in each repo first, which brings back the per-team effort. Option D is incorrect — Dependabot analyzes dependencies, not code logic; it cannot replace code scanning.

**Reference**: https://docs.github.com/en/code-security/code-scanning/enabling-code-scanning/configuring-default-setup-for-code-scanning-at-scale

</details>

---

### Question 9
**Domain**: Domain 5 — Security & Compliance
**Topic**: Private vulnerability reporting
**Difficulty**: Beginner

A security researcher has found a SQL injection vulnerability in your public open-source repository and wants to report it without creating a public GitHub issue. What GitHub feature allows this?

A. GitHub Security Advisories (create an advisory yourself and share it privately)
B. Private vulnerability reporting (the researcher submits via the Security tab)
C. A private fork with a security patch submitted as a PR
D. Contact via the repository's SECURITY.md email address only

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: **Private vulnerability reporting** is a GitHub feature specifically designed for this scenario. When enabled on a repository, there is a "Report a vulnerability" button on the repository's Security tab. Researchers click this, fill in vulnerability details, and the report is submitted privately — creating a draft security advisory that only maintainers can see. This provides a structured, built-in channel for responsible disclosure without requiring email or external tools. Option A is partially correct in concept (advisories are the output) but the researcher would need write access to create an advisory themselves. Option C is a workaround, not the designed mechanism. Option D is a valid fallback but not the GitHub-native feature being tested.

**Reference**: https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/about-coordinated-disclosure-of-security-vulnerabilities

</details>

---

### Question 10
**Domain**: Domain 5 — Security & Compliance
**Topic**: Custom secret scanning patterns
**Difficulty**: Advanced

An enterprise uses an internal credential format for their proprietary API gateway: `GWAY-[A-Z]{4}-[0-9]{12}`. Developers have been accidentally committing these tokens. What is the correct approach to detect these tokens with secret scanning?

A. Update GitHub's partner program configuration to include the custom format
B. Create a custom secret scanning pattern at the organization or enterprise level using a regex that matches the format
C. Configure CodeQL to detect the token format as a code scanning alert
D. Set up a webhook that monitors all push events and checks commits for the pattern

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: **Custom secret scanning patterns** allow organizations and enterprises to define their own regex patterns for proprietary secret formats. A regex like `GWAY-[A-Z]{4}-[0-9]{12}` would be entered in Org/Enterprise Settings > Code security and analysis > Custom patterns. Once published, secret scanning will detect this pattern in all scanned repositories and generate alerts. Option A is incorrect — the GitHub partner program is for external credential providers, not internal patterns. Option C is incorrect — CodeQL is a semantic code analysis tool for finding code vulnerabilities, not for detecting credential formats in committed text. Option D is technically possible but is a custom implementation that bypasses GitHub's built-in secret scanning infrastructure — not the recommended approach.

**Reference**: https://docs.github.com/en/code-security/secret-scanning/defining-custom-patterns-for-secret-scanning

</details>

---

## Official Documentation Links

- [About GitHub Advanced Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
- [About secret scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
- [About push protection](https://docs.github.com/en/code-security/secret-scanning/protecting-pushes-with-secret-scanning)
- [Custom secret scanning patterns](https://docs.github.com/en/code-security/secret-scanning/defining-custom-patterns-for-secret-scanning)
- [About Dependabot alerts](https://docs.github.com/en/code-security/dependabot/dependabot-alerts/about-dependabot-alerts)
- [Dependabot security updates](https://docs.github.com/en/code-security/dependabot/dependabot-security-updates/about-dependabot-security-updates)
- [Configuration options for dependabot.yml](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)
- [About code scanning](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning)
- [About dependency review](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-dependency-review)
- [About security overview](https://docs.github.com/en/enterprise-cloud@latest/code-security/security-overview/about-security-overview)
- [Managing branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)
- [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [Private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/about-coordinated-disclosure-of-security-vulnerabilities)
- [IP allow lists](https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-allowed-ip-addresses-for-your-organization)
- [About dependency graph](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-the-dependency-graph)
- [Exporting an SBOM](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/exporting-a-software-bill-of-materials-for-your-repository)
