# Demo Lab 06 — GitHub Actions Administration

**Domain Coverage**: Domain 6 (Manage GitHub Actions)
**Prerequisites**: GitHub organization (owner access), test repository, ideally a Linux VM for self-hosted runner setup
**Estimated Time**: 2-3 hours

---

## Learning Objectives

After completing this lab, you will be able to:
- Configure Actions policies at organization and enterprise levels
- Register and manage self-hosted runners
- Create and configure runner groups
- Set up required workflows
- Configure GITHUB_TOKEN permissions
- Manage encrypted secrets at different scopes
- Create deployment environments with protection rules
- Configure OIDC for cloud authentication (conceptual + hands-on)
- Manage Actions cache

---

## Lab Setup

```bash
# Create a test repository for Actions lab
gh repo create YOUR_ORG/actions-lab \
  --public \
  --description "GitHub Actions administration lab" \
  --clone

cd actions-lab
mkdir -p .github/workflows
```

---

## Exercise 1 — Configure Actions Policies

### 1.1 Review Current Actions Policy

1. Navigate to: `Org Settings > Actions > General`
2. Note the current settings:
   - Actions permissions (what can run)
   - Fork pull request workflows (do fork PRs get access to secrets?)
   - Workflow permissions (GITHUB_TOKEN default)

### 1.2 Restrict Actions to Specific Sources

1. Select: **Allow select actions and reusable workflows**
2. Configure:
   - [x] Allow actions created by GitHub
   - [x] Allow actions by Marketplace verified creators
   - In the custom allowlist, add:
     ```
     aws-actions/*
     azure/login@*
     google-github-actions/*
     ```
3. Save

### 1.3 Test the Policy

Create a test workflow that uses a non-allowed action:

```bash
cat > .github/workflows/policy-test.yml << 'EOF'
name: Policy Test

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4  # Allowed (GitHub-owned)
      - name: Echo
        run: echo "This workflow should run"
EOF

git add .github/workflows/policy-test.yml
git commit -m "Add policy test workflow"
git push
```

Run the workflow:
```bash
gh workflow run "Policy Test"
gh run watch
```

Now test with a disallowed action (modify the workflow to use an action not in your allowlist) and observe the error.

---

## Exercise 2 — Self-Hosted Runner Setup

### 2.1 Prepare a Runner Machine

You need a Linux machine (local VM, cloud VM, or WSL on Windows).

Minimum requirements:
- Linux (Ubuntu 22.04 recommended)
- 2 vCPUs, 4 GB RAM
- Network access to github.com (port 443)
- Docker installed (optional, for container jobs)

### 2.2 Register an Organization-Level Runner

1. Navigate to: `Org Settings > Actions > Runners > New runner`
2. Select: **Linux x64**
3. Follow the setup commands shown (they include your registration token)

```bash
# On your runner machine:

# Download runner
mkdir ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-linux-x64-2.319.1.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz

# Get registration token from GitHub
# Go to: Org Settings > Actions > Runners > New runner
# Copy the token from the configuration command

# Configure runner
./config.sh \
  --url https://github.com/YOUR_ORG \
  --token YOUR_REGISTRATION_TOKEN \
  --name "lab-runner-01" \
  --labels "linux,x64,lab,custom-label" \
  --runnergroup "Default" \
  --unattended

# Start the runner
./run.sh &
```

### 2.3 Verify Runner Registration

```bash
# Check runner status via API
gh api orgs/YOUR_ORG/actions/runners \
  --jq '.runners[] | {id: .id, name: .name, status: .status, labels: [.labels[].name]}'
```

In the GitHub UI: `Org Settings > Actions > Runners` — you should see your runner with status "Idle"

### 2.4 Run a Job on the Self-Hosted Runner

```bash
cat > .github/workflows/self-hosted-test.yml << 'EOF'
name: Self-Hosted Runner Test

on:
  workflow_dispatch:

jobs:
  test-on-self-hosted:
    runs-on: [self-hosted, linux, x64, lab]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Show runner info
        run: |
          echo "Runner hostname: $(hostname)"
          echo "Runner OS: $(uname -a)"
          echo "Runner user: $(whoami)"
          echo "Working directory: $(pwd)"

      - name: Check available tools
        run: |
          docker --version 2>/dev/null || echo "Docker not installed"
          python3 --version
          node --version 2>/dev/null || echo "Node not installed"
EOF

git add .github/workflows/self-hosted-test.yml
git commit -m "Add self-hosted runner test"
git push
gh workflow run "Self-Hosted Runner Test"
gh run watch
```

---

## Exercise 3 — Runner Groups

### 3.1 Create a Runner Group

```bash
# Create a new runner group at org level
gh api orgs/YOUR_ORG/actions/runner-groups -X POST \
  -f name="lab-runner-group" \
  -f visibility="selected" \
  -f selected_repository_ids="[]"  # Start with no repos

# Get the group ID
GROUP_ID=$(gh api orgs/YOUR_ORG/actions/runner-groups \
  --jq '.runner_groups[] | select(.name == "lab-runner-group") | .id')
echo "Group ID: $GROUP_ID"
```

### 3.2 Move Runner to the New Group

```bash
# Get your runner's ID
RUNNER_ID=$(gh api orgs/YOUR_ORG/actions/runners \
  --jq '.runners[] | select(.name == "lab-runner-01") | .id')

# Move runner to the new group
gh api orgs/YOUR_ORG/actions/runner-groups/$GROUP_ID/runners/$RUNNER_ID -X PUT

# Verify the runner is in the new group
gh api orgs/YOUR_ORG/actions/runner-groups/$GROUP_ID/runners \
  --jq '.runners[].name'
```

### 3.3 Restrict Group to a Specific Repository

```bash
# Get repository ID
REPO_ID=$(gh api repos/YOUR_ORG/actions-lab --jq '.id')

# Add repo to group
gh api orgs/YOUR_ORG/actions/runner-groups/$GROUP_ID -X PATCH \
  -f visibility="selected" \
  --jq '.selected_repositories_url'

# Associate specific repos
gh api orgs/YOUR_ORG/actions/runner-groups/$GROUP_ID/repositories -X PUT \
  -f repository_ids="[$REPO_ID]"
```

### 3.4 Test Group Access Control

Update your workflow to use the runner group:

```yaml
jobs:
  test:
    runs-on: [self-hosted, linux, lab]
    # This will use runners in groups accessible to this repo
```

---

## Exercise 4 — GITHUB_TOKEN Permissions

### 4.1 Check Default Permissions

1. Navigate to: `Org Settings > Actions > General > Workflow permissions`
2. Note the default setting (likely read-only)

### 4.2 Create a Workflow That Tests Token Permissions

```bash
cat > .github/workflows/token-permissions.yml << 'EOF'
name: GITHUB_TOKEN Permission Test

on:
  workflow_dispatch:

jobs:
  test-read:
    name: Test Read Permissions
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: List issues (read)
        run: |
          gh api repos/${{ github.repository }}/issues --jq 'length'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  test-write:
    name: Test Write Permissions
    runs-on: ubuntu-latest
    permissions:
      issues: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Create a test issue
        run: |
          ISSUE=$(gh issue create \
            --title "Automated test issue from workflow" \
            --body "This issue was created by a workflow to test GITHUB_TOKEN write permissions")
          echo "Created issue: $ISSUE"
          # Clean up: close the issue immediately
          gh issue close --repo ${{ github.repository }} $(echo $ISSUE | grep -o '[0-9]*$')
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF

git add .github/workflows/token-permissions.yml
git commit -m "Add GITHUB_TOKEN permission test"
git push
gh workflow run "GITHUB_TOKEN Permission Test"
gh run watch
```

### 4.3 Test Permission Restrictions

Create a workflow that deliberately lacks a needed permission:

```bash
cat > .github/workflows/permission-failure-test.yml << 'EOF'
name: Permission Failure Test

on:
  workflow_dispatch:

jobs:
  test-no-write:
    runs-on: ubuntu-latest
    permissions:
      contents: read  # Only read - no write
    steps:
      - uses: actions/checkout@v4
      - name: Try to create issue without permission
        run: |
          gh issue create \
            --title "Should fail" \
            --body "This should fail due to insufficient permissions"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        # Expected: This step should fail with permission error
EOF

git add .github/workflows/permission-failure-test.yml
git commit -m "Add permission failure test"
git push
gh workflow run "Permission Failure Test"
gh run watch
# This workflow should fail at the "Try to create issue" step
```

---

## Exercise 5 — Encrypted Secrets

### 5.1 Create Secrets at Different Scopes

```bash
# Repository-level secret
gh secret set REPO_SECRET --repo YOUR_ORG/actions-lab <<< "repo-secret-value"

# Organization-level secret (available to all repos)
gh secret set ORG_SECRET --org YOUR_ORG --visibility all <<< "org-secret-value"

# Organization-level secret (restricted to specific repos)
gh secret set RESTRICTED_ORG_SECRET \
  --org YOUR_ORG \
  --visibility selected \
  --repos "actions-lab" \
  <<< "restricted-org-secret-value"
```

### 5.2 Create a Workflow That Uses Secrets

```bash
cat > .github/workflows/secrets-test.yml << 'EOF'
name: Secrets Access Test

on:
  workflow_dispatch:

jobs:
  test-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Access repo secret
        run: |
          # Don't print secret values - they are masked
          if [ -n "$REPO_SECRET" ]; then
            echo "REPO_SECRET is available (value is masked)"
          else
            echo "REPO_SECRET is NOT available"
          fi
        env:
          REPO_SECRET: ${{ secrets.REPO_SECRET }}

      - name: Access org secret
        run: |
          if [ -n "$ORG_SECRET" ]; then
            echo "ORG_SECRET is available (value is masked)"
          else
            echo "ORG_SECRET is NOT available"
          fi
        env:
          ORG_SECRET: ${{ secrets.ORG_SECRET }}
EOF

git add .github/workflows/secrets-test.yml
git commit -m "Add secrets test workflow"
git push
gh workflow run "Secrets Access Test"
gh run watch
```

---

## Exercise 6 — Environments and Deployment Protection

### 6.1 Create Environments

```bash
# Create a staging environment (no protection)
gh api repos/YOUR_ORG/actions-lab/environments/staging -X PUT <<< '{}'

# Create a production environment with reviewer requirement
gh api repos/YOUR_ORG/actions-lab/environments/production -X PUT \
  --input - << 'EOF'
{
  "reviewers": [
    {
      "type": "User",
      "id": YOUR_USER_ID
    }
  ],
  "deployment_branch_policy": {
    "protected_branches": false,
    "custom_branch_policies": true
  }
}
EOF
```

Get your user ID:
```bash
gh api user --jq '.id'
```

### 6.2 Create Environment Secrets

```bash
# Get environment ID first
ENV_ID=$(gh api repos/YOUR_ORG/actions-lab/environments/production --jq '.id')

# Add production-only secret
gh api repos/YOUR_ORG/actions-lab/environments/production/secrets/PROD_API_KEY -X PUT \
  -f encrypted_value="..." \
  -f key_id="..."
# (In practice, use the UI for this - API requires encryption with the repo's public key)

# Via UI: Repo Settings > Environments > production > Add secret
```

### 6.3 Create a Deployment Workflow

```bash
cat > .github/workflows/deploy.yml << 'EOF'
name: Deployment Pipeline

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment"
          echo "Using staging config..."
          # Real deployment commands would go here

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    environment: production   # This triggers the reviewer approval requirement
    needs: deploy-staging      # Must deploy to staging first
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: |
          echo "Deploying to production environment"
          echo "PROD API KEY is available: ${{ secrets.PROD_API_KEY != '' }}"
          # Real deployment commands would go here
EOF

git add .github/workflows/deploy.yml
git commit -m "Add deployment pipeline with environments"
git push
```

Observe:
1. The staging job runs immediately
2. The production job pauses and sends a review request to the configured reviewer
3. After approval, the production job runs

---

## Exercise 7 — OIDC Configuration (AWS Example)

> This exercise requires an AWS account for the full hands-on experience. The conceptual walk-through is valuable even without AWS.

### 7.1 Understand OIDC Token Claims

Create a workflow that prints the OIDC token claims:

```bash
cat > .github/workflows/oidc-test.yml << 'EOF'
name: OIDC Token Test

on:
  workflow_dispatch:

permissions:
  id-token: write   # Required to request OIDC token
  contents: read

jobs:
  oidc-test:
    runs-on: ubuntu-latest
    steps:
      - name: Get OIDC token
        run: |
          # Request an OIDC token
          OIDC_TOKEN=$(curl -sLS \
            -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
            "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=sts.amazonaws.com" | jq -r '.value')

          # Decode the JWT payload (base64)
          PAYLOAD=$(echo $OIDC_TOKEN | cut -d. -f2)
          # Add padding if needed
          PADDED_PAYLOAD="${PAYLOAD}=="
          echo "OIDC Token Claims:"
          echo $PADDED_PAYLOAD | base64 -d 2>/dev/null | python3 -m json.tool
        # Note: The actual token value is not printed - only the decoded claims
EOF

git add .github/workflows/oidc-test.yml
git commit -m "Add OIDC token inspection workflow"
git push
gh workflow run "OIDC Token Test"
gh run watch
```

### 7.2 Review OIDC Token Claims

The token will contain claims like:
```json
{
  "sub": "repo:YOUR_ORG/actions-lab:ref:refs/heads/main",
  "aud": "sts.amazonaws.com",
  "iss": "https://token.actions.githubusercontent.com",
  "repository": "YOUR_ORG/actions-lab",
  "ref": "refs/heads/main",
  "sha": "abc123...",
  "workflow": "OIDC Token Test",
  "event_name": "workflow_dispatch",
  "environment": "",
  "actor": "YOUR_USERNAME"
}
```

The `sub` claim is what AWS IAM role trust policies use to restrict which repos/branches can assume the role.

### 7.3 Create AWS OIDC Integration (If AWS Available)

```bash
# AWS CLI commands to set up OIDC provider and role

# 1. Create OIDC provider (one-time setup)
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# 2. Create trust policy for IAM role
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/actions-lab:*"
        }
      }
    }
  ]
}
EOF

# 3. Create the IAM role
aws iam create-role \
  --role-name GitHubActionsLabRole \
  --assume-role-policy-document file://trust-policy.json

# 4. Attach a minimal policy (e.g., read-only S3)
aws iam attach-role-policy \
  --role-name GitHubActionsLabRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

Then create a workflow using OIDC:

```yaml
- name: Configure AWS Credentials (via OIDC)
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsLabRole
    aws-region: us-east-1

- name: Verify AWS access
  run: aws s3 ls
```

---

## Exercise 8 — Actions Cache Management

### 8.1 Create a Cached Workflow

```bash
cat > .github/workflows/cached-build.yml << 'EOF'
name: Cached Build

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache node modules
        uses: actions/cache@v4
        id: cache-npm
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-

      - name: Install dependencies
        run: |
          # Simulate creating some cache content
          mkdir -p ~/.npm
          echo "cached-content" > ~/.npm/test-cache.txt
          echo "Cache hit: ${{ steps.cache-npm.outputs.cache-hit }}"

      - name: Show cache status
        run: |
          if [ "${{ steps.cache-npm.outputs.cache-hit }}" == "true" ]; then
            echo "Cache was restored (CACHE HIT)"
          else
            echo "No cache found - dependencies were freshly installed (CACHE MISS)"
          fi
EOF

git add .github/workflows/cached-build.yml
git commit -m "Add cached build workflow"
git push
```

Run it twice and observe:
- First run: Cache MISS — dependencies are installed and cached
- Second run: Cache HIT — dependencies are restored from cache

### 8.2 Inspect and Delete Caches

```bash
# List all caches for the repository
gh api repos/YOUR_ORG/actions-lab/actions/caches \
  --jq '.actions_caches[] | {id: .id, key: .key, size_in_bytes: .size_in_bytes, last_accessed_at: .last_accessed_at}'

# Delete a specific cache by ID
CACHE_ID=1  # Replace with actual ID
gh api repos/YOUR_ORG/actions-lab/actions/caches/$CACHE_ID -X DELETE

# Clear all caches for a specific branch
gh api repos/YOUR_ORG/actions-lab/actions/caches?ref=refs/heads/main -X DELETE
```

---

## Lab Checkpoint Questions

1. At which levels can Actions policies be configured? Which level takes precedence?
2. What is an ephemeral runner and why is it recommended for public repos?
3. What is the purpose of runner groups? Give an example use case.
4. What is the default GITHUB_TOKEN permission level (as of 2023+)?
5. Can a job in a workflow access a secret from an environment it doesn't explicitly target?
6. What `permissions` key is required to request an OIDC token in a workflow?
7. What is the maximum Actions cache size per repository?
8. How do required workflows differ from required status checks?

---

## Key Takeaways

- Enterprise Actions policy overrides org policy which overrides repo policy
- Ephemeral runners are the security best practice for self-hosted runners
- Runner groups control which orgs/repos can use which runners
- GITHUB_TOKEN is read-only by default since 2023 — use `permissions:` to grant specific access
- Environment secrets are ONLY available to jobs that target the environment
- OIDC eliminates long-lived cloud credentials from secrets; `id-token: write` permission is required
- Actions cache is repo-scoped, 10 GB max, 7-day eviction on inactivity
- Required workflows are org-level policies enforced across repos regardless of repo settings

---

## Cleanup

```bash
# Remove self-hosted runner (from runner machine)
cd ~/actions-runner
./config.sh remove --token YOUR_REMOVAL_TOKEN

# Delete runner group
gh api orgs/YOUR_ORG/actions/runner-groups/$GROUP_ID -X DELETE

# Delete secrets
gh secret delete REPO_SECRET --repo YOUR_ORG/actions-lab
gh secret delete ORG_SECRET --org YOUR_ORG
gh secret delete RESTRICTED_ORG_SECRET --org YOUR_ORG

# Delete environments
gh api repos/YOUR_ORG/actions-lab/environments/staging -X DELETE
gh api repos/YOUR_ORG/actions-lab/environments/production -X DELETE

# Delete test repo if done
gh repo delete YOUR_ORG/actions-lab --yes
```
