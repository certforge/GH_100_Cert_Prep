# Demo Lab 01 — Enterprise Setup and Support Configuration

**Domain Coverage**: Domain 1 (Enterprise Support) and Domain 3 (Deployment)
**Prerequisites**: GitHub Enterprise Cloud trial or Enterprise account, Organization owner access
**Estimated Time**: 60-90 minutes

---

## Learning Objectives

After completing this lab, you will be able to:
- Configure enterprise-level settings and policies
- Access and filter the enterprise audit log
- Set up audit log streaming to an external destination
- Generate and interpret enterprise reports
- Configure support escalation contacts
- Understand the difference between org-level and enterprise-level settings

---

## Lab Setup

You need:
- A GitHub Enterprise Cloud account with at least one organization
- Enterprise owner access
- (Optional) An AWS S3 bucket or Azure Blob Storage account for audit log streaming

---

## Exercise 1 — Explore the Enterprise Settings

### 1.1 Access Enterprise Settings

1. Sign in to GitHub.com
2. In the top-right corner, click your profile photo
3. Click **Your enterprises**
4. Click on your enterprise name
5. Click **Settings** in the enterprise navigation

Explore the settings sections:
- **Profile**: Enterprise name, description, avatar
- **Policies**: Repository, Actions, Copilot policies
- **Billing**: Seat counts, spending limits
- **Security**: IP allow lists, authentication policies
- **Compliance**: Audit log, streaming

### 1.2 Review Current Organizations

1. In Enterprise Settings, click **Organizations**
2. Note the organizations listed, their member counts, and settings

**Exam relevance**: Enterprise owners can see all organizations and their settings. Organization owners can only manage their own org.

### 1.3 Check License Usage

1. In Enterprise Settings, click **Billing**
2. Review the seat count: Total licensed vs consumed vs available

```
Questions to answer:
- How many seats are licensed?
- How many are consumed?
- Are any users consuming multiple seats (they shouldn't be)?
```

---

## Exercise 2 — Audit Log Exploration

### 2.1 Access the Enterprise Audit Log

1. Navigate to Enterprise Settings > **Audit log**
2. Review the recent events shown

### 2.2 Filter the Audit Log

Try these filters:

**Filter by action type**:
- In the search box, type: `action:repo.create`
- This shows only repository creation events

**Filter by actor**:
- Type: `actor:YOUR_USERNAME`
- This shows all actions performed by a specific user

**Filter by organization**:
- Type: `org:YOUR_ORG_NAME`
- This shows events from a specific organization

**Filter by date range**:
- Type: `created:>2026-01-01` or `created:2026-01-01..2026-02-01`

### 2.3 Identify Key Event Categories

Find at least one example of each event type:
- [ ] A repository creation (`repo.create`)
- [ ] An authentication event (`login`)
- [ ] A team membership change (`team.add_member` or similar)
- [ ] A settings change (`org.update_*`)

### 2.4 Access Audit Log via API

```bash
# Install and authenticate gh CLI first if not done
gh auth login

# Get recent audit log entries for your enterprise
# Replace ENTERPRISE_SLUG with your enterprise slug (from the URL)
gh api enterprises/ENTERPRISE_SLUG/audit-log --jq '.[] | {time: .created_at, action: .action, actor: .actor}' | head -20
```

**Note**: The enterprise slug is the part of your enterprise URL after `/enterprises/` — e.g., if your enterprise URL is `github.com/enterprises/acme-corp`, the slug is `acme-corp`.

---

## Exercise 3 — Configure Audit Log Streaming (Optional)

### 3.1 Set Up Streaming to Amazon S3

If you have an AWS account, set up streaming:

**Pre-requisites**:
- An S3 bucket created (e.g., `github-audit-logs-YOURNAME`)
- An IAM user or role with `s3:PutObject` permission on the bucket
- Access key ID and secret access key for the IAM user

**Steps**:
1. Navigate to Enterprise Settings > **Audit log** > **Streams** tab
2. Click **New stream**
3. Select **Amazon S3**
4. Fill in:
   - Bucket: your S3 bucket name
   - Region: your bucket's region
   - Access key ID and secret access key
5. Click **Generate stream** and **Save stream**
6. Perform some actions in GitHub (create a repo, modify a setting)
7. Check your S3 bucket — log files should appear within a few minutes

### 3.2 Verify Streaming Is Working

In your S3 bucket, you should see files like:
```
github-audit-logs/
  2026/
    03/
      03/
        enterprise-audit-log-1709504321.json.gz
```

---

## Exercise 4 — Enterprise Policies Configuration

### 4.1 Configure Repository Policies

1. Navigate to Enterprise Settings > **Policies** > **Repositories**
2. Review and optionally configure:
   - **Default visibility for new repos**: Private (recommended)
   - **Repository creation**: Who can create repos
   - **Repository deletion and transfer**: Restrict to owners only
   - **Repository forking**: Configure for private and internal repos
   - **Outside collaborators**: Restrict or allow

**Caution**: Changing these settings affects all organizations. Only make changes if you are in a test/lab environment.

### 4.2 Review Actions Policies

1. Navigate to Enterprise Settings > **Policies** > **Actions**
2. Note the available options:
   - Enable/disable Actions
   - Which actions are allowed
   - Self-hosted runner policies
   - Required workflows

---

## Exercise 5 — Configure Support Contacts

### 5.1 Add a Support Contact

1. Navigate to Enterprise Settings > **Support**
2. Review existing contacts
3. If your account allows it, add a second enterprise owner as a support contact

**Exam relevance**: Understanding that multiple enterprise owners = multiple support contacts, and that this ensures business continuity for support ticket access.

---

## Exercise 6 — Monitor GitHub Status

### 6.1 Set Up Status Monitoring

1. Visit https://status.github.com
2. Click **Subscribe to Updates**
3. Choose your notification method (email is simplest)
4. Note the incident history tab — review any recent incidents

### 6.2 Review Service Components

Note which GitHub services are monitored separately:
- Git Operations
- API Requests
- GitHub Actions
- GitHub Packages
- GitHub Pages
- Webhooks
- GitHub Codespaces

**Exam tip**: Each component can have independent status. "GitHub is down" usually means one specific component, not everything.

---

## Exercise 7 — Generate Enterprise Reports

### 7.1 Export License Usage

1. Enterprise Settings > **Billing** > **License**
2. Click **Export license usage** (downloads CSV)
3. Open the CSV and review:
   - Username
   - Email
   - Last active date
   - Organization memberships

### 7.2 Review Actions Usage

1. Enterprise Settings > **Billing** > **Actions**
2. Note minutes consumed per organization
3. Note the breakdown by runner OS (Linux/Windows/macOS)

---

## Lab Checkpoint Questions

Answer these before moving on:

1. What is the difference between an enterprise audit log and an organization audit log?
2. How long are audit log events retained in the GitHub UI?
3. What is required to retain audit log events beyond the default retention period?
4. Where do you configure which organizations get access to enterprise-level runner groups?
5. If an enterprise policy is set to "disable repository creation for non-owners," can an organization owner override this?

---

## Key Takeaways

- Enterprise settings are the highest level of GitHub administration
- Enterprise policies OVERRIDE organization policies — there is no escape
- Audit log streaming is the only way to retain events beyond 90 days
- License usage is deduplicated — a user in multiple orgs counts as one seat
- The GitHub Status page is always the first stop when troubleshooting platform issues

---

## Cleanup

If you made any test changes:
1. Revert any policy changes you made for testing
2. Remove any test streaming configurations (to avoid unnecessary data transfer)
3. Remove any test support contacts you may have added
