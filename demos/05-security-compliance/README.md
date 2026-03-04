# Demo Lab 05 — Security and Compliance

**Domain Coverage**: Domain 5 (Security and Compliance) — 36% of exam
**Prerequisites**: GitHub organization with GHAS license (or public repository for free features), Organization owner access
**Estimated Time**: 2-3 hours (most comprehensive lab)

---

## Learning Objectives

After completing this lab, you will be able to:
- Enable and test secret scanning and push protection
- Create custom secret scanning patterns
- Configure Dependabot alerts, security updates, and version updates
- Set up code scanning with default and advanced setup
- Configure the dependency-review-action
- Set up a SECURITY.md and private vulnerability reporting
- Use the Security Overview dashboard
- Configure audit log streaming (conceptual)
- Enable IP allow lists

---

## Lab Setup

For full GHAS features, you need:
- GitHub Advanced Security license (for private repos), OR
- Use public repositories (GHAS features are free for public repos)

Create a **public test repository** for this lab if you don't have GHAS for private repos.

```bash
# Create a public test repo for security lab
gh repo create YOUR_USERNAME/security-lab \
  --public \
  --description "Security features demonstration lab" \
  --clone

cd security-lab
```

---

## Exercise 1 — Secret Scanning

### 1.1 Enable Secret Scanning

For a public repo, secret scanning is already enabled.

For a private repo:
```
Repo Settings > Security > Secret scanning > Enable
```

Or via API:
```bash
gh api repos/YOUR_ORG/security-lab -X PATCH \
  -f security_and_analysis='{"advanced_security":{"status":"enabled"},"secret_scanning":{"status":"enabled"}}'
```

### 1.2 Commit a Fake Secret (Test)

**Important**: Only use GitHub's own test tokens for this exercise. Never use real credentials.

GitHub provides a specific test format for triggering secret scanning in demos:

```bash
# Create a test file with a fake AWS-style token
# Note: This is a fictitious token format used for testing
cat > test-secrets.txt << 'EOF'
# This file is for testing secret scanning detection
# DO NOT commit real credentials

# Fake GitHub PAT (for testing only - matches GitHub's pattern)
FAKE_GITHUB_TOKEN=ghp_EXAMPLE_FAKE_TOKEN_FOR_TESTING_ONLY_1234567890

# Note: GitHub secret scanning will detect real token formats
# This specific fake token may or may not trigger an alert
# depending on whether it matches GitHub's validation patterns
EOF

git add test-secrets.txt
git commit -m "Add test secrets file for lab"
git push
```

### 1.3 View Secret Scanning Alerts

After pushing:
1. Navigate to: `Repo > Security > Secret scanning`
2. If an alert was generated, you'll see it here
3. Review the alert details: secret type, file location, line number

### 1.4 Dismiss an Alert

```bash
# If alerts exist, dismiss one with a reason
ALERT_NUMBER=1  # Replace with actual alert number

gh api repos/YOUR_ORG/security-lab/secret-scanning/alerts/$ALERT_NUMBER -X PATCH \
  -f state="resolved" \
  -f resolution="false_positive"
```

---

## Exercise 2 — Push Protection

### 2.1 Enable Push Protection

```
Repo Settings > Security > Secret scanning > Push protection > Enable
```

Or via API:
```bash
gh api repos/YOUR_ORG/security-lab -X PATCH \
  -f security_and_analysis='{"secret_scanning_push_protection":{"status":"enabled"}}'
```

### 2.2 Test Push Protection Behavior

```bash
# Create a commit with a test pattern
# GitHub's push protection will detect known token patterns
cat > push-protection-test.txt << 'EOF'
Testing push protection - this file should be blocked if it contains a real secret
EOF

git add push-protection-test.txt
git commit -m "Test push protection"
git push
```

### 2.3 Observe the Bypass Flow

If push protection blocks a push:
1. GitHub shows an error message with the detected secret type
2. The error includes a URL to bypass or remediate
3. To bypass: add a justification reason and re-push

```bash
# Bypass push protection (for lab purposes only)
# In reality, you would either remove the secret or provide a bypass reason
GH_PUSH_PROTECTION=bypass git push
```

---

## Exercise 3 — Custom Secret Scanning Patterns

### 3.1 Create a Custom Pattern

Navigate to: `Org Settings > Security analysis > Custom patterns > New pattern`

Or configure at the repository level for this lab:
`Repo Settings > Security > Secret scanning > Custom patterns > New pattern`

Fill in:
- **Pattern name**: `Lab API Key`
- **Secret format** (regex): `LABKEY-[A-Z]{4}-[0-9]{8}-[a-z0-9]{16}`
- **Test string**: `LABKEY-ABCD-12345678-abc123def456ghi7`
- **Before secret**: (leave empty)
- **After secret**: (leave empty)

Click **Save and dry run**, then review which historical commits match.

### 3.2 Test Custom Pattern Detection

```bash
cat > custom-pattern-test.txt << 'EOF'
# This file contains a custom API key for testing
LAB_API_KEY=LABKEY-ABCD-12345678-abc123def456ghi7
EOF

git add custom-pattern-test.txt
git commit -m "Test custom pattern detection"
git push
```

After pushing:
1. Check `Repo > Security > Secret scanning`
2. A new alert should appear for "Lab API Key"

---

## Exercise 4 — Dependabot Configuration

### 4.1 Enable Dependabot Alerts

For public repos, Dependabot alerts may already be enabled.

For private repos:
```bash
gh api repos/YOUR_ORG/security-lab/vulnerability-alerts -X PUT
```

### 4.2 Add a Dependency File

Create a `package.json` with a vulnerable package:

```bash
cat > package.json << 'EOF'
{
  "name": "security-lab",
  "version": "1.0.0",
  "dependencies": {
    "lodash": "4.17.20"
  }
}
EOF

git add package.json
git commit -m "Add package.json with dependencies"
git push
```

Wait a few minutes for Dependabot to analyze the dependency graph.

Check for alerts:
```bash
gh api repos/YOUR_ORG/security-lab/dependabot/alerts \
  --jq '.[] | {number: .number, package: .dependency.package.name, severity: .security_advisory.severity}'
```

### 4.3 Enable Dependabot Security Updates

```
Repo Settings > Security > Dependabot security updates > Enable
```

After enabling, check the **Pull requests** tab — Dependabot may create a PR to update the vulnerable package.

### 4.4 Configure Dependabot Version Updates

Create `.github/dependabot.yml`:

```bash
mkdir -p .github
cat > .github/dependabot.yml << 'EOF'
version: 2
updates:
  # npm packages
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
    reviewers:
      - "YOUR_USERNAME"
    labels:
      - "dependencies"
    open-pull-requests-limit: 5

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
EOF

git add .github/dependabot.yml
git commit -m "Configure Dependabot version updates"
git push
```

---

## Exercise 5 — Code Scanning with Default Setup

### 5.1 Enable Default Setup

For a public repository:
1. Navigate to: `Repo Settings > Security > Code scanning`
2. Click **Set up** > **Default**
3. Review the detected languages
4. Click **Enable CodeQL**

This creates a managed workflow that runs CodeQL automatically.

### 5.2 View Code Scanning Results

After the first workflow run completes (~5-10 minutes):
1. Navigate to: `Repo > Security > Code scanning alerts`
2. Review any alerts found (a new empty repo likely has 0 alerts)

Add some intentionally vulnerable code to trigger findings:

```bash
cat > vulnerable.js << 'EOF'
// SQL injection vulnerability example (for testing only)
const mysql = require('mysql');

function getUserData(userId, callback) {
  const connection = mysql.createConnection({});
  // Intentionally vulnerable query - DO NOT USE IN PRODUCTION
  const query = "SELECT * FROM users WHERE id = " + userId;
  connection.query(query, callback);
}
EOF

git add vulnerable.js
git commit -m "Add JavaScript file for code scanning demo"
git push
```

### 5.3 Enable Code Scanning with Advanced Setup

For custom configuration:

```bash
mkdir -p .github/workflows
cat > .github/workflows/codeql.yml << 'EOF'
name: CodeQL Advanced Analysis

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 6 * * 1'

jobs:
  analyze:
    name: Analyze (${{ matrix.language }})
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript' ]

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-and-quality

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
EOF

git add .github/workflows/codeql.yml
git commit -m "Add advanced CodeQL workflow"
git push
```

---

## Exercise 6 — Dependency Review

### 6.1 Add the Dependency Review Action

```bash
cat > .github/workflows/dependency-review.yml << 'EOF'
name: Dependency Review

on:
  pull_request:
    branches: [ main ]

permissions:
  contents: read
  pull-requests: write

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: high
          comment-summary-in-pr: always
EOF

git add .github/workflows/dependency-review.yml
git commit -m "Add dependency review workflow"
git push
```

### 6.2 Test Dependency Review

Create a PR that introduces a vulnerable dependency:

```bash
git checkout -b test/vulnerable-dep
cat > package.json << 'EOF'
{
  "name": "security-lab",
  "version": "1.0.0",
  "dependencies": {
    "lodash": "4.17.15",
    "express": "4.17.1"
  }
}
EOF
git add package.json
git commit -m "Add vulnerable lodash version"
git push -u origin test/vulnerable-dep
gh pr create --title "Test: Add dependencies" --body "Testing dependency review workflow"
```

Observe:
1. The dependency-review workflow runs on the PR
2. It detects vulnerable versions in the dependency changes
3. If severity >= high, the check fails and the PR cannot be merged

---

## Exercise 7 — Security Policy Setup

### 7.1 Create a SECURITY.md File

```bash
cat > SECURITY.md << 'EOF'
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We use GitHub's private vulnerability reporting feature for security disclosures.

**To report a vulnerability**:
1. Navigate to the [Security tab](../../security) of this repository
2. Click **"Report a vulnerability"**
3. Fill in the vulnerability details
4. Submit the report

We will acknowledge receipt within **48 hours** and provide a status update within **5 business days**.

**Please do NOT open a public GitHub issue for security vulnerabilities.**

For critical vulnerabilities, also email: security@example.com

## What to Include in Your Report

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)
EOF

git add SECURITY.md
git commit -m "Add security policy"
git push
```

### 7.2 Enable Private Vulnerability Reporting

```
Repo Settings > Security > Private vulnerability reporting > Enable
```

After enabling:
1. Navigate to `Repo > Security` as a non-owner
2. You should see the "Report a vulnerability" button

---

## Exercise 8 — Security Overview Dashboard

### 8.1 View Organization Security Overview

1. Navigate to: `Your Org > Security`
2. Explore the tabs:
   - **Overview**: Summary of enabled features and open alerts
   - **Alerts**: Aggregated view of all alerts across repos
   - **Coverage**: Which repos have which features enabled

### 8.2 Enable Features from Security Overview

In the Coverage view:
1. Filter to repos with "Secret scanning" disabled
2. Select multiple repos
3. Click "Enable secret scanning" to enable it for all selected repos at once

This is the scalable way to enable security features across many repositories.

---

## Exercise 9 — IP Allow Lists

### 9.1 Configure an IP Allow List

> Note: Before enabling this, ensure your IP is in the list or you will lock yourself out.

1. Find your current IP address: https://api.ipify.org or `curl ifconfig.me`

2. Navigate to: `Org Settings > Security > Allowed IP addresses`
3. Click **Add an allowed IP address**
4. Enter your IP in CIDR notation: `YOUR_IP/32`
5. Label: `My Work IP`

> Important: If you enable the allow list without including ALL IPs that need access (CI runners, VPN, etc.), those services will be blocked.

### 9.2 Test IP Allow List

```bash
# Verify your access still works (your IP is in the list)
gh api orgs/YOUR_ORG
# Should succeed

# To test blocking: temporarily use a different IP
# (not recommended in production!)
```

---

## Lab Checkpoint Questions

1. What is the difference between secret scanning alerts and push protection?
2. If secret scanning is enabled but push protection is NOT, and a developer commits an AWS access key, what happens?
3. What three Dependabot features exist, and what does each do?
4. What is SARIF, and why is it used with code scanning?
5. What must be in place before dependency review can detect vulnerabilities in a PR?
6. If you create a custom secret scanning pattern at the organization level, which repositories does it apply to?
7. What does the dependency review action's `fail-on-severity: high` setting do?
8. How does private vulnerability reporting differ from creating a public issue?

---

## Key Takeaways

- Secret scanning (detective) and push protection (preventative) are complementary but distinct
- GHAS is free for public repos; requires a license for private/internal repos
- Dependabot has THREE features: alerts (passive), security updates (auto-fix PRs), version updates (configured via dependabot.yml)
- Code scanning supports both default setup (one-click) and advanced setup (custom workflow)
- Any tool that outputs SARIF can integrate with GitHub code scanning
- dependency-review-action blocks PRs that introduce vulnerable dependencies
- Security overview enables bulk feature enablement across repos
- IP allow lists block ALL access (web, API, Git) from non-listed IPs — include runner IPs

---

## Cleanup

```bash
# Remove test workflows (to avoid unused Actions runs)
gh workflow disable "CodeQL Advanced Analysis" --repo YOUR_ORG/security-lab
gh workflow disable "Dependency Review" --repo YOUR_ORG/security-lab

# Optional: delete the test repo entirely
gh repo delete YOUR_ORG/security-lab --yes
```
