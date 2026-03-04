# Domain 6 — Manage GitHub Actions

**Exam Weight: 16%**
**Approximate Questions: 13-16**
**Priority: High**

---

## Domain Overview

Domain 6 covers the **administrative** aspects of GitHub Actions — not how to write workflows, but how to govern and manage Actions at the organization and enterprise level. This distinction is critical: the exam tests your ability to configure policies, manage runners, control access to secrets, and enforce security controls, not your ability to author complex YAML workflows.

Key themes:
- Who can run Actions? (policies)
- Where do Actions run? (runners and runner groups)
- What can Actions do? (permissions and secrets)
- How do you enforce standards? (required workflows)
- How do you authenticate to cloud? (OIDC)
- How do you manage costs and limits? (usage and spending limits)

---

## Key Concepts

- **Actions policies** — control what Actions can run and for which repos
- **Self-hosted runners** — customer-managed compute for running jobs
- **Runner groups** — access control for self-hosted runners
- **Required workflows** — org-level policies that must pass on all matching repos
- **GITHUB_TOKEN permissions** — default and configurable token scopes
- **Encrypted secrets** — scoped secrets for workflows
- **Environments** — deployment targets with protection rules
- **OIDC** — passwordless cloud authentication for workflows
- **Reusable workflows** — shared workflow definitions
- **Usage limits and billing** — managing Actions costs

---

## 6.1 Actions Policies

### Policy Hierarchy

Actions policies follow the same override hierarchy as all GitHub policies:
```
Enterprise policy (overrides all)
  └── Organization policy (overrides repo-level)
        └── Repository policy
```

If an enterprise policy is set, organizations CANNOT override it.

### Available Policy Options

At each level (enterprise, organization, repository):

| Policy Option | What It Means |
|---------------|--------------|
| Allow all actions and reusable workflows | Any action from anywhere can run |
| Disable Actions for this org/repo | No Actions workflows can run |
| Allow select actions and reusable workflows | Specify allowed actions explicitly |
| Allow GitHub-owned actions only | Only actions in the `actions/` and `github/` orgs can run |

### Configuring "Allow select actions"

When choosing "Allow select actions," you can specify:
- `GitHub-owned actions` (e.g., `actions/checkout`, `actions/upload-artifact`)
- `Verified creator actions` (Marketplace verified publishers)
- Custom allowlist with specific patterns, e.g.:
  ```
  actions/*
  aws-actions/configure-aws-credentials@*
  docker/build-push-action@v5
  myorg/*
  ```

**Configuration path**:
- Enterprise: `Enterprise Settings > Actions > Policies`
- Organization: `Org Settings > Actions > General > Actions permissions`
- Repository: `Repo Settings > Actions > General > Actions permissions`

### Disabling Actions for Specific Repositories

At the organization level, you can allow Actions for all repos, selected repos, or no repos:
```
Org Settings > Actions > General > Actions permissions
> Allow actions for: [All repositories | Selected repositories | No repositories]
```

---

## 6.2 Self-Hosted Runners

### Architecture

Self-hosted runners are VMs, containers, or physical machines that:
1. Have the GitHub Actions runner application installed
2. Are registered with GitHub (repo, org, or enterprise level)
3. Poll GitHub for jobs via long-polling (outbound HTTPS connection)
4. Execute job steps locally
5. Return results to GitHub

**No inbound ports required** — runners initiate outbound connections only.

### Runner Registration Levels

| Level | Registered At | Available To |
|-------|--------------|--------------|
| Repository | Repo Settings > Actions > Runners | That repository only |
| Organization | Org Settings > Actions > Runners | All repos in org (via runner groups) |
| Enterprise | Enterprise Settings > Actions > Runners | All orgs in enterprise (via runner groups) |

### Registering a Self-Hosted Runner

```bash
# 1. Download the runner application
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.319.1.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz

# 2. Configure (token from GitHub Settings > Actions > Runners > New runner)
./config.sh --url https://github.com/ORG \
             --token REGISTRATION_TOKEN \
             --name "my-runner-01" \
             --labels "linux,x64,gpu" \
             --runnergroup "prod-runners"

# 3. Start as a service
sudo ./svc.sh install
sudo ./svc.sh start

# OR run interactively (for testing)
./run.sh
```

### Runner Labels

Labels allow workflows to target specific runners:

```yaml
jobs:
  build:
    runs-on: [self-hosted, linux, x64, gpu]
    # Job will only run on a self-hosted runner with all these labels
```

Common labels to assign:
- OS: `linux`, `windows`, `macos`
- Architecture: `x64`, `arm64`
- Environment: `production`, `staging`
- Special capabilities: `gpu`, `high-memory`, `docker`

### Ephemeral Runners (JIT / Just-in-Time)

Ephemeral runners start fresh for each job and are deleted afterward. This is the recommended security model:

Benefits:
- No job-to-job state persistence (no contamination)
- No risk of secrets leaking between jobs
- Auto-scales naturally (spin up, run job, tear down)
- Particularly important for public repositories

```bash
# Configure ephemeral runner (--ephemeral flag)
./config.sh --url https://github.com/ORG \
             --token REGISTRATION_TOKEN \
             --ephemeral
```

For automated ephemeral runner provisioning, use the **GitHub Actions Runner Controller (ARC)** on Kubernetes or similar orchestration.

### Security Considerations for Self-Hosted Runners

**CRITICAL**: Never use self-hosted runners on public repositories without careful security controls.

Why: Pull requests from forked public repos can trigger Actions workflows that run on self-hosted runners. A malicious PR could execute arbitrary code on the runner.

Security best practices:
1. Use ephemeral runners — each job gets a clean environment
2. Isolate runners in dedicated VMs or containers (not on production hosts)
3. Use minimal permissions on the runner host
4. Do not store persistent secrets on runner machines
5. Network-isolate runners from production systems
6. For public repos, prefer GitHub-hosted runners

---

## 6.3 Runner Groups

### What Are Runner Groups?

Runner groups allow organizations and enterprises to control which repositories and organizations can use specific self-hosted runners.

### Enterprise-Level Runner Groups

Created at: `Enterprise Settings > Actions > Runner groups`

- Can restrict to specific organizations (or all orgs)
- Enterprise owners manage which orgs can use the group
- Useful for: shared production runners, compliance-specific runners

```
Enterprise Runner Group: "prod-runners"
  - Available to: Org A, Org B (not Org C)
  - Runners in group: prod-runner-01, prod-runner-02
```

### Organization-Level Runner Groups

Created at: `Org Settings > Actions > Runner groups`

- Can restrict to specific repositories (or all repos)
- Can also allow self-hosted runners from enterprise groups
- Useful for: team-specific runners, environment-specific runners

```
Org Runner Group: "frontend-runners"
  - Available to: frontend-app repo, design-system repo (not backend repos)
  - Runners in group: frontend-runner-01
```

### Default Runner Group

All new self-hosted runners are added to the **Default** runner group. This group:
- Is available to all repositories in the org/enterprise by default
- Can be reconfigured to restrict access
- Cannot be deleted

### Managing Runner Group Access

```bash
# Add a runner to a specific group (via API)
gh api orgs/ORG/actions/runner-groups/GROUP_ID/runners/RUNNER_ID -X PUT

# List runners in a group
gh api orgs/ORG/actions/runner-groups/GROUP_ID/runners

# Update which repos can access a group
gh api orgs/ORG/actions/runner-groups/GROUP_ID -X PATCH \
  -f visibility="selected" \
  --jq '.selected_repositories_url'
```

---

## 6.4 Required Workflows

### What Are Required Workflows?

Required workflows are organization-level policies that force specific Actions workflows to run (and pass) for all pull requests in matching repositories. They are enforced independent of whether the repository's own workflows include that check.

**Key distinction from required status checks**: Required status checks reference a check name; required workflows reference an actual workflow file from a specific repository.

### Setting Up Required Workflows

1. Create the workflow file in a source repository (e.g., `.github/workflows/org-security-scan.yml`)
2. Navigate to: `Org Settings > Actions > Required workflows`
3. Add the workflow:
   - Repository containing the workflow
   - Path to the workflow file
   - Ref (branch/tag) of the workflow source
   - Target repositories (all repos or selected repos)

**The source workflow must have `workflow_call` as a trigger** — but actually for required workflows, the workflow is called directly, not as a reusable workflow. The workflow must be in a public repository or an internal repository within the enterprise.

### Required Workflow Example

Source: `platform-team/ci-standards/.github/workflows/required-security-scan.yml`

```yaml
# This workflow is required for all repos in the org
name: Required Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run organization security checks
        run: |
          echo "Running org-wide security baseline checks..."
          # Add your security checks here
```

### Required Workflow Behavior

- Required workflows appear as **required status checks** on PRs
- They cannot be disabled by repository owners or admins
- Enterprise owners or org owners can manage required workflows
- Required workflows are associated with the org, not individual repos

---

## 6.5 Workflow Permissions and Secrets

### GITHUB_TOKEN

Every workflow run automatically receives a `GITHUB_TOKEN` secret. This token:
- Is scoped to the repository where the workflow runs
- Expires when the workflow run ends
- Cannot access other repositories or orgs (by default)

**Default permission in 2023+**: Read-only for all permissions

### Configuring GITHUB_TOKEN Permissions

**At the org or enterprise level** (default for all new workflows):
```
Org Settings > Actions > General > Workflow permissions
> Read repository contents and packages permissions (read-only)
> OR Read and write permissions
```

**In individual workflows** using the `permissions` key:
```yaml
permissions:
  contents: read          # Read repository content
  issues: write           # Create/update issues
  pull-requests: write    # Comment on and merge PRs
  security-events: write  # Upload code scanning results
  id-token: write         # Request OIDC token
  actions: read           # Read Actions metadata
  packages: write         # Push to GitHub Packages

# OR set default and override specific:
permissions:
  contents: read
  packages: write

# OR restrict everything:
permissions: {}   # No permissions
```

### Encrypted Secrets

Secrets are encrypted and available to workflows via `${{ secrets.SECRET_NAME }}`.

**Secret Scopes**:

| Scope | Where Created | Available To |
|-------|--------------|-------------|
| Repository secret | Repo Settings > Secrets | All workflows in that repo |
| Organization secret | Org Settings > Secrets | Repos granted access (all or selected) |
| Enterprise secret | Enterprise Settings > Actions | All orgs in enterprise |
| Environment secret | Environment Settings > Secrets | Jobs targeting that environment |

**Creating a repo secret via CLI**:
```bash
# Create a secret
gh secret set MY_SECRET_VALUE --repo ORG/REPO

# Or from a file
gh secret set MY_CERT --repo ORG/REPO --body "$(cat cert.pem)"

# Create org secret
gh secret set MY_SECRET --org ORG --visibility selected \
  --repos "repo1,repo2"
```

**Secret availability rules**:
- Org secrets are only available to repos that have been granted access
- Environment secrets are ONLY available when a job explicitly targets the environment
- Secrets are masked in logs (replaced with `***`)
- Secrets cannot be accessed in workflows triggered by forked PRs (by default — this is a security control)

### Accessing Org Secrets from a Repository

Org secrets can be:
- Available to all repositories
- Available to selected repositories (configured when creating the secret)
- Available to private repositories only

Org admins manage access via: `Org Settings > Secrets > [Secret name] > Repository access`

---

## 6.6 Environments and Deployment Protection

### What Are Environments?

Environments represent deployment targets (production, staging, development). Jobs that target an environment:
- Have access to environment secrets and variables
- Are subject to environment protection rules
- Are recorded in the deployment history

### Creating an Environment

```
Repo Settings > Environments > New environment
```

Or via API:
```bash
gh api repos/ORG/REPO/environments -X PUT --input - <<'EOF'
{
  "deployment_branch_policy": {
    "protected_branches": false,
    "custom_branch_policies": true
  }
}
EOF
```

### Environment Protection Rules

| Rule | Description |
|------|-------------|
| Required reviewers | Specific people/teams must approve before job proceeds (up to 6 reviewers) |
| Wait timer | Delay job execution by N minutes (max 43,200 = 30 days) |
| Deployment branches and tags | Restrict which branches/tags can deploy to this environment |

**Required reviewers workflow**: When a job reaches the environment:
1. Job is paused and reviewers are notified
2. Reviewers approve or reject in the GitHub UI
3. If approved, job proceeds; if rejected, job fails

### Using Environments in Workflows

```yaml
jobs:
  deploy-production:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://myapp.example.com  # Optional: display URL in deployment record
    steps:
      - name: Deploy
        run: ./deploy.sh
        env:
          API_KEY: ${{ secrets.PROD_API_KEY }}  # Environment secret
```

### Deployment Branch Policies

Restrict which branches can deploy to an environment:
- **Protected branches**: Only branches with branch protection rules can deploy
- **Custom policies**: Specify allowed branch name patterns (e.g., `main`, `release/**`)

---

## 6.7 OpenID Connect (OIDC) for Cloud Authentication

### Why OIDC?

Traditional approach: Store cloud credentials (AWS keys, Azure service principal) as GitHub secrets.
- Problem: Long-lived credentials that can be leaked or stolen

OIDC approach: GitHub issues a short-lived token for each workflow run; cloud provider validates the token.
- No stored credentials
- Token expires after the job
- Cloud provider can enforce granular conditions (only `main` branch, only `production` environment, etc.)

### OIDC Token Flow

```
Workflow job starts
     |
     | 1. Request OIDC token
     v
GitHub OIDC Provider (token.actions.githubusercontent.com)
     |
     | 2. Short-lived JWT token (claims: repo, ref, environment, actor, etc.)
     v
Workflow
     |
     | 3. Present token to cloud provider
     v
Cloud Provider (AWS, Azure, GCP)
     |
     | 4. Validate token against GitHub OIDC public keys
     | 5. Check claims match configured conditions
     v
Cloud IAM issues temporary credentials
     |
     v
Workflow uses credentials for cloud operations
```

### Required Workflow Permission

```yaml
permissions:
  id-token: write   # Required to request the OIDC JWT
  contents: read
```

### AWS Example

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789:role/GitHubActionsRole
    aws-region: us-east-1
    # No access key or secret key needed!
```

AWS IAM role trust policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:*"
        }
      }
    }
  ]
}
```

### Azure Example

```yaml
- name: Azure login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    # No secret/password — uses OIDC federated identity
```

---

## 6.8 Reusable Workflows

### What Are Reusable Workflows?

Reusable workflows allow workflow definitions to be shared and called from other workflows. They are defined with the `workflow_call` trigger.

### Defining a Reusable Workflow

`.github/workflows/build-and-test.yml` in `org/shared-workflows` repo:

```yaml
name: Build and Test (Reusable)

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'
      environment:
        required: true
        type: string
    secrets:
      NPM_TOKEN:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
        env:
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
      - run: npm test
```

### Calling a Reusable Workflow

```yaml
name: CI

on:
  push:
    branches: [ main ]

jobs:
  call-build:
    uses: org/shared-workflows/.github/workflows/build-and-test.yml@main
    with:
      node-version: '20'
      environment: staging
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
    # OR: secrets: inherit  (pass all caller secrets to reusable workflow)
```

### Reusable Workflows vs Composite Actions

| Feature | Reusable Workflow | Composite Action |
|---------|-------------------|-----------------|
| Defines | A complete job | A series of steps |
| Called with | `uses: org/repo/.github/workflows/workflow.yml@ref` | `uses: org/repo/action-dir@ref` |
| Has its own runner | Yes (runs as its own job) | No (runs as steps in caller's job) |
| Can have multiple jobs | Yes | No |
| Nesting limit | 4 levels | No explicit limit |
| `secrets: inherit` | Supported | Not applicable |

---

## 6.9 Actions Usage and Billing

### GitHub-Hosted Runner Billing

Billing is per minute of compute time:

| OS | Rate vs Linux |
|----|--------------|
| Ubuntu (Linux) | 1x (base rate) |
| Windows | 2x |
| macOS | 10x |

GitHub-hosted runner minutes included per plan:
| Plan | Minutes/Month |
|------|--------------|
| Free | 2,000 |
| Pro | 3,000 |
| Team | 3,000 |
| Enterprise | 50,000 |

Self-hosted runners: no per-minute billing from GitHub.

### Spending Limits

Spending limits prevent unexpected overages:

```
Enterprise Settings > Billing > Actions > Spending limit
```

- Set a maximum monthly spend in USD
- Default: $0 (no spending above included minutes)
- When limit is reached, jobs are queued/rejected

### Usage Reports

```
Enterprise Settings > Billing > Actions
```

Shows per-organization breakdown of:
- Minutes consumed per OS type
- Minutes vs included minutes
- Estimated overage cost

### Workflow Run Retention

Workflow run logs and artifacts are retained for:
- Default: 90 days (configurable)
- Minimum: 1 day
- Maximum: 400 days

Configure per repository:
```
Repo Settings > Actions > General > Artifact and log retention
```

### Actions Cache

The Actions cache is used by `actions/cache` to store and restore build dependencies:

| Attribute | Value |
|-----------|-------|
| Max cache size | 10 GB per repository |
| Eviction policy | Least recently used; entries not accessed in 7 days are removed |
| Branch behavior | Cache entries from a branch are only accessible to that branch and the base branch |
| Scope | Repository-scoped (cannot share across repos) |

```bash
# List caches for a repository
gh api repos/ORG/REPO/actions/caches

# Delete a specific cache
gh api repos/ORG/REPO/actions/caches/CACHE_ID -X DELETE

# Delete all caches for a repository
gh api repos/ORG/REPO/actions/caches -X DELETE
```

---

## Common Admin Tasks

### Audit Which Actions Are Being Used

```bash
# List all workflow files in an org's repos
gh api orgs/ORG/repos --paginate --jq '.[].name' | xargs -I REPO \
  gh api repos/ORG/REPO/contents/.github/workflows --jq '.[].name' 2>/dev/null
```

### List All Self-Hosted Runners in an Org

```bash
gh api orgs/ORG/actions/runners --paginate \
  --jq '.runners[] | {id: .id, name: .name, status: .status, labels: [.labels[].name]}'
```

### Check Runner Group Configuration

```bash
# List runner groups
gh api orgs/ORG/actions/runner-groups --jq '.runner_groups[] | {id: .id, name: .name, visibility: .visibility}'

# List repos with access to a specific group
gh api orgs/ORG/actions/runner-groups/GROUP_ID/repositories \
  --jq '.repositories[].name'
```

### Force-Cancel a Stuck Workflow Run

```bash
gh run cancel RUN_ID --repo ORG/REPO
```

---

## Gotchas and Exam Tips

1. **Enterprise policy overrides org policy**. If the enterprise restricts Actions to GitHub-owned actions only, org admins CANNOT override this to allow all actions.

2. **GITHUB_TOKEN is read-only by default since 2023**. Many questions involve scenarios where a workflow needs to push code or create issues — the answer involves either setting `permissions: contents: write` in the workflow or changing the org/enterprise default.

3. **Environment secrets are only available when a job targets the environment**. If a job doesn't have `environment: production`, it cannot access secrets defined in the production environment, even if it's in the same workflow.

4. **Required workflows are org-level, not repo-level**. Org owners set required workflows; repo admins cannot disable them.

5. **Self-hosted runners in public repos are a security risk**. The exam tests awareness that malicious forks can execute code on self-hosted runners. Ephemeral runners mitigate this.

6. **Runner group default behavior**: New self-hosted runners go to the Default group; new repositories can access the Default group. This is the most permissive starting state.

7. **OIDC requires `id-token: write` permission**. If this is missing from the `permissions` block, the workflow cannot request an OIDC token.

8. **Reusable workflows run on their own runners**. They are jobs, not steps. They have their own `runs-on` configuration in the callee workflow.

9. **Cache is not shared across repositories**. If you need to share artifacts between repos, use GitHub Releases, Packages, or Artifacts with download actions — not the cache.

10. **Spending limits apply to GitHub-hosted runners only**. Self-hosted runner usage has no GitHub billing.

---

## Practice Questions

### Question 1
**Domain**: Domain 6 — GitHub Actions
**Topic**: Actions policies
**Difficulty**: Beginner

An enterprise wants to allow GitHub Actions workflows to run, but only using actions created by GitHub (in the `actions/` and `github/` namespaces) plus a specific third-party action: `aws-actions/configure-aws-credentials`. How should the enterprise configure this?

A. Set enterprise policy to "Allow all actions and reusable workflows"
B. Set enterprise policy to "Allow select actions" and specify GitHub-owned actions + `aws-actions/configure-aws-credentials@*`
C. Disable Actions at the enterprise level and create an exception list for each organization
D. Configure each organization separately with different action allowlists

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: "Allow select actions" at the enterprise level is the correct choice. You can check "GitHub-owned actions" to allow all `actions/*` and `github/*` namespaces, and then add specific additional actions to the custom allowlist (e.g., `aws-actions/configure-aws-credentials@*`). The `@*` pattern allows any version of the action. This provides a controlled, allowlist-based approach. Option A (allow all) is too permissive for an enterprise with restrictions. Option C (disable + exceptions) is not how GitHub Enterprise policy works — you cannot create exceptions to "disabled." Option D (per-org configuration) would work but is inefficient; enterprise-level policy is the intended mechanism for enterprise-wide standards.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/admin/policies/enforcing-policies-for-your-enterprise/enforcing-policies-for-github-actions-in-your-enterprise

</details>

---

### Question 2
**Domain**: Domain 6 — GitHub Actions
**Topic**: Self-hosted runner security
**Difficulty**: Intermediate

An organization has a public open-source repository. They want to use self-hosted runners for this repository to take advantage of more powerful hardware. What is the most important security measure to implement?

A. Add the runners to a private runner group restricted to that repository only
B. Configure the runners as ephemeral so each job gets a fresh environment
C. Use an IP allow list to prevent unauthorized access to the runners
D. Require all PRs to be reviewed before workflows can run on self-hosted runners

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: For public repositories with self-hosted runners, the most critical security control is using **ephemeral runners**. Public repos can receive pull requests from anyone (including attackers), and those PRs can trigger workflow runs that execute on self-hosted runners. With persistent runners, a malicious workflow could leave backdoors, exfiltrate secrets, or poison the runner environment for subsequent legitimate jobs. Ephemeral runners start fresh for each job — any malicious changes are discarded when the job ends. Option A (runner groups) restricts which repos use the runner but doesn't address job-to-job contamination. Option C (IP allow lists) protects the GitHub API access, not the runner security. Option D (PR review) is a reasonable additional control but review can be bypassed and doesn't prevent the runner contamination risk.

**Reference**: https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#hardening-for-self-hosted-runners

</details>

---

### Question 3
**Domain**: Domain 6 — GitHub Actions
**Topic**: GITHUB_TOKEN permissions
**Difficulty**: Intermediate

A developer reports that their workflow is failing when it tries to create a comment on a pull request. The workflow uses `${{ secrets.GITHUB_TOKEN }}` for authentication. The org's default workflow permissions are set to "Read repository contents and packages permissions." What change will fix the workflow?

A. Replace `${{ secrets.GITHUB_TOKEN }}` with a personal access token that has `pull_requests: write` scope
B. Add `permissions: pull-requests: write` to the workflow job or workflow level
C. Contact GitHub Support to enable PR write access for GITHUB_TOKEN
D. Change the org default to "Read and write permissions" for all workflows

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: The issue is that the GITHUB_TOKEN's default permissions are read-only (as set at the org level), and creating a comment on a PR requires `pull-requests: write` permission. The fix is to add a `permissions` block to the workflow file — either at the workflow level (applies to all jobs) or the specific job level:

```yaml
permissions:
  pull-requests: write
  contents: read  # Always include what you need
```

This is the least-privilege approach — only granting the specific permission needed. Option A (use a PAT) would work but is a worse practice: PATs are harder to manage, can expire, and are tied to a specific user account. Option C is incorrect — GITHUB_TOKEN permissions are configurable, not a support issue. Option D (change org default) would fix this workflow but also affects all other workflows — violating least-privilege for the whole org.

**Reference**: https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token

</details>

---

### Question 4
**Domain**: Domain 6 — GitHub Actions
**Topic**: Runner groups
**Difficulty**: Intermediate

An enterprise has two organizations: "Org-Prod" (production) and "Org-Dev" (development). The enterprise has a set of high-performance self-hosted runners that should ONLY be used by Org-Prod's repositories. How should this be configured?

A. Register the runners at the repository level in Org-Prod repositories only
B. Create an enterprise-level runner group, add the runners to it, and restrict the group to Org-Prod only
C. Create labels on the runners named "org-prod-only" and configure workflows to use that label
D. Create organization-level runner groups in both orgs but only add runners to Org-Prod's group

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Enterprise-level runner groups are the correct tool for controlling which organizations can access a set of runners. Create an enterprise runner group, add the high-performance runners to it, and configure the group to be available only to "Org-Prod." This prevents Org-Dev (or any other org) from using these runners, even if they create workflows targeting the same labels. Option A (repo-level registration) would require registering each runner separately in each repo — not scalable and harder to manage. Option C (labels) controls job routing but doesn't restrict which org can use the runners — any org's workflow could include the label. Option D (org-level groups) would work at the org level but doesn't leverage enterprise-level management; it also doesn't prevent org-dev from registering their own runners.

**Reference**: https://docs.github.com/en/actions/using-github-hosted-runners/managing-larger-runners/controlling-access-to-larger-runners

</details>

---

### Question 5
**Domain**: Domain 6 — GitHub Actions
**Topic**: OIDC authentication
**Difficulty**: Advanced

A workflow needs to deploy to AWS. The security team requires that no long-lived AWS credentials be stored as GitHub secrets. The deployment must only be possible from workflows running on the `main` branch. Which approach satisfies both requirements?

A. Store short-lived AWS credentials that are rotated every 24 hours as GitHub secrets
B. Configure OIDC integration between GitHub Actions and AWS IAM; create an IAM role with a trust policy that restricts the `sub` claim to `repo:myorg/myrepo:ref:refs/heads/main`
C. Use an AWS Lambda function to generate temporary credentials and call it from the workflow
D. Store the AWS credentials as organization-level secrets restricted to the production repository

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: OIDC (OpenID Connect) is specifically designed to eliminate long-lived credentials in CI/CD. GitHub issues a short-lived JWT for each workflow run containing claims about the context (repo, branch, environment, etc.). The AWS IAM role trust policy can be configured to only accept tokens where the `sub` claim matches `repo:myorg/myrepo:ref:refs/heads/main` — meaning deployments from feature branches or PRs would be rejected. The workflow uses `permissions: id-token: write` and the `aws-actions/configure-aws-credentials` action. No credentials are stored in GitHub secrets. Option A still stores credentials (even if rotated). Option C adds complexity and still requires some credentials for the Lambda. Option D (org secrets) stores long-lived credentials, violating the first requirement.

**Reference**: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect

</details>

---

## Official Documentation Links

- [About GitHub-hosted runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners)
- [About self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)
- [Managing runner groups](https://docs.github.com/en/actions/using-github-hosted-runners/managing-larger-runners/managing-larger-runners)
- [Required workflows](https://docs.github.com/en/actions/using-workflows/required-workflows)
- [Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
- [Encrypted secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [Environments for deployment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [OIDC security hardening](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Actions usage limits](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration)
