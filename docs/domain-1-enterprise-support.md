# Domain 1 — Support GitHub Enterprise for Users and Key Stakeholders

**Exam Weight: 9%**
**Approximate Questions: 7-9**
**Priority: Medium**

---

## Domain Overview

Domain 1 covers the operational and support aspects of running GitHub at the enterprise level. Unlike domains that focus on technical configuration, this domain is about knowing what resources exist, how to use them, and how to communicate with stakeholders.

Topics in this domain appear in scenario form: "A user reports that GitHub is slow — what do you check first?" or "An enterprise admin needs to audit who accessed a repository last month — where do they look?"

---

## Key Concepts

- **GitHub Support tiers** and their response SLAs
- **GitHub Status page** for incident awareness
- **Audit log** — enterprise-level visibility into all actions
- **Audit log streaming** — forwarding events to external SIEM
- **Enterprise reports** — license usage, actions usage, security summaries
- **Stakeholder communication** — GitHub roadmap, changelogs, and internal communication patterns
- **Support ticket escalation** — when and how to escalate

---

## 1.1 GitHub Support Tiers

### Overview

GitHub offers tiered support options. Knowing which tier does what is directly tested.

| Tier | Who Gets It | First Response (Urgent) | First Response (High) | Availability |
|------|------------|------------------------|----------------------|--------------|
| GitHub Community Support | All plans | No SLA | No SLA | Self-service forum |
| GitHub Support (Standard) | Team / Enterprise | 8 business hours | 24 business hours | Business hours |
| GitHub Premium Support | Add-on (Enterprise) | 30 minutes | 4 business hours | 24/7/365 |
| GitHub Premium Plus Support | Add-on (Enterprise) | 15 minutes | 4 business hours | 24/7/365 + TAM |

**Priority levels**: Urgent (production system down), High (significant impact), Normal (general questions), Low (enhancement requests)

### Technical Account Manager (TAM)

Premium Plus includes a dedicated **Technical Account Manager**:
- Proactive architecture guidance
- Quarterly business reviews
- Escalation path into GitHub engineering
- Custom training sessions
- Help with adoption of new features

### Submitting Support Tickets

- Go to `https://support.github.com` or `github.com/support`
- Enterprise admins can submit tickets on behalf of users
- For GHES: also accessible from the Management Console
- Include: description of issue, steps to reproduce, diagnostic bundle (for GHES)

### GHES Diagnostic Bundles

For GHES support tickets, GitHub Support often requests a diagnostic bundle:

```bash
# Generate a diagnostic bundle from GHES admin shell
ghe-diagnostics > /tmp/diagnostics.json

# Or download from Management Console: Admin > Support > Download diagnostics
```

---

## 1.2 GitHub Status and Incident Monitoring

### GitHub Status Page

**URL**: https://status.github.com

- Shows current status of all GitHub services (Git operations, API, Actions, Packages, etc.)
- Shows incident history going back months
- Real-time updates during incidents

### How to Subscribe to Status Notifications

1. Visit `https://status.github.com`
2. Click "Subscribe to Updates"
3. Choose notification method:
   - **Email**: Incident start, updates, resolution
   - **Atom/RSS feed**: Feed URL for integration with monitoring tools
   - **Webhook**: POST to your endpoint for each status update
   - **SMS** (via third-party Statuspage integration)

### GitHub Changelog, Roadmap, and API Lifecycle

Admins should monitor GitHub change channels in addition to the status page:
- **GitHub Changelog** for feature releases and behavior changes
- **GitHub Roadmap** for upcoming features that may affect rollout planning
- **API changelog and deprecation notices** for integrations and automation

This matters when preparing stakeholder communications or validating whether internal tooling may need changes before a feature rollout or deprecation date.

### Exam Tip

When a user reports "GitHub is down," the correct first step for an admin is to **check status.github.com** before opening a support ticket.

---

## 1.3 Enterprise Audit Log

### What Is the Audit Log?

The audit log captures a detailed, timestamped record of events in an enterprise or organization. It answers: "Who did what, when, and where?"

### Event Categories

| Category | Examples |
|----------|---------|
| `repository` | Create, delete, rename, transfer, change visibility |
| `org` | Add/remove member, change settings, create/delete team |
| `enterprise` | Add/remove organization, change enterprise policy |
| `authentication` | OAuth token created, SAML auth, 2FA events |
| `billing` | Plan changes, seat changes |
| `business` | Enterprise policy changes |
| `actions` | Runner events, secret access, workflow events |

### Accessing the Audit Log

**Via UI**:
- Enterprise: `Enterprise Settings > Audit log`
- Organization: `Org Settings > Audit log`

**Via REST API**:
```bash
# Enterprise audit log (requires enterprise owner)
curl -H "Authorization: Bearer TOKEN" \
  "https://api.github.com/enterprises/ENTERPRISE/audit-log?per_page=100"

# Organization audit log
curl -H "Authorization: Bearer TOKEN" \
  "https://api.github.com/orgs/ORG/audit-log?per_page=100"
```

**Via gh CLI**:
```bash
gh api enterprises/ENTERPRISE/audit-log --paginate
```

### Filtering the Audit Log

In the UI:
- Filter by actor (user), event type (action), time range, organization

Via API:
- `phrase` parameter for text search
- `include=all|web|git|api` to filter event types
- `after` and `before` for date ranges (cursor-based pagination)

### Retention Periods

| Storage Method | Retention |
|----------------|-----------|
| UI (Enterprise audit log) | 90 days |
| REST API | 90 days |
| Git events via API | 7 days |
| Audit log streaming | Indefinite (controlled by destination) |

**Important**: For compliance requirements that need audit logs beyond 90 days, **audit log streaming** must be configured.

---

## 1.4 Audit Log Streaming

### Purpose

Streaming continuously forwards audit log events in real time to an external storage or SIEM system. Enables:
- Long-term retention beyond 90 days
- Integration with security monitoring tools (Splunk, Datadog, etc.)
- Real-time alerting on specific events

### Supported Destinations

| Destination | Protocol |
|-------------|---------|
| Amazon S3 | S3 API |
| Azure Blob Storage | Azure Storage API |
| Google Cloud Storage | GCS API |
| Splunk | HTTP Event Collector (HEC) |
| Datadog | Datadog Logs API |

### Configuration

Navigate to: `Enterprise Settings > Audit log > Streams > New stream`

Configure:
1. Select destination type
2. Provide credentials (S3 bucket + IAM, Azure connection string, etc.)
3. Optionally filter event types to stream
4. Save and test the stream

### Exam Tip

Streaming is configured at the **enterprise level**, not the organization level. Enterprise owners can configure it; org owners cannot.

---

## 1.5 Enterprise Reports and Dashboards

### License Usage Report

- **Location**: `Enterprise Settings > License`
- Shows: seat count, seats consumed, seats available
- Download as CSV for auditing
- Includes: user list, organizations each user belongs to, last active date

### GitHub Actions Usage

- **Location**: `Enterprise Settings > Billing > Actions`
- Shows: minutes consumed per organization
- Breaks down by OS (Linux, Windows, macOS)
- Useful for cost allocation across teams

### Security Summaries at Enterprise Level

- **Location**: `Enterprise Settings > Code Security`
- Shows: secret scanning alerts, code scanning alerts, Dependabot alerts by org
- Allows bulk enabling security features across organizations

### Key Metrics Admins Should Track

| Metric | Location | Frequency |
|--------|---------|-----------|
| Seat utilization | License settings | Monthly |
| Actions minutes burn | Billing > Actions | Weekly |
| Open critical security alerts | Security overview | Daily/Weekly |
| Failed SSO authentications | Audit log | On demand |
| New outside collaborators | Audit log | Weekly |

---

## 1.6 Communicating with Stakeholders

### GitHub Resources for Staying Current

| Resource | URL | What It Covers |
|----------|-----|---------------|
| GitHub Changelog | github.blog/changelog | Feature releases and updates |
| GitHub Blog | github.blog | Major announcements |
| GitHub Roadmap | github.com/orgs/github/projects/4247 | Upcoming features |
| GitHub Docs | docs.github.com | Official product documentation |
| GitHub Status | status.github.com | Service health |
| API changelog / deprecations | docs.github.com + developer notices | Breaking changes affecting apps, scripts, and integrations |

### Internal Communication Best Practices

- Use **GitHub Discussions** in a dedicated internal repo for GitHub policy announcements
- Pin important announcements to organization README (`.github` repo)
- Notify users before enforcing new security policies (SAML SSO, 2FA) via email
- Create a runbook wiki for common admin procedures
- Communicate API or Marketplace integration deprecations before effective dates

---

## Common Admin Tasks

### Checking Audit Log for a Specific User's Actions

```bash
# Via API: find all actions by a specific user in the last 30 days
gh api enterprises/MYENTERPRISE/audit-log \
  --jq '.[] | select(.actor == "suspect-user")' \
  --paginate
```

### Exporting License Data

Navigate to: `Enterprise settings > License > Export license usage`
Downloads a CSV with: username, email, last active, organizations.

### Setting Up a Support Escalation Contact

In GitHub Support settings, designate multiple enterprise owners as support contacts so tickets can be submitted by multiple admins.

---

## Gotchas and Exam Tips

1. **Audit log vs Security log**: The audit log is admin-facing. Users have a personal security log at `github.com/settings/security-log`. Don't confuse them.

2. **Git events in the audit log**: Git operation events (push, pull, clone) are available in the audit log API but are only retained for **7 days** via the API, not 90. This is a commonly tested distinction.

3. **Premium Support vs Premium Plus**: Premium Plus adds a TAM and dedicated support engineering. If a question asks about a "dedicated technical resource" or "proactive guidance," the answer is Premium Plus.

4. **Streaming is enterprise-level only**: You cannot configure audit log streaming from the organization settings page. It requires enterprise-level access.

5. **Status subscriptions**: The exam may ask the best way to "automatically notify the operations team when GitHub has an incident." The answer is configuring status.github.com webhook notifications, not manually checking the page.

6. **GitHub Connect requirement**: If a GHES instance is not connected to GitHub.com (no GitHub Connect), license sync data and unified search do not work. This is relevant when reporting seat usage.

---

## Practice Questions

### Question 1
**Domain**: Domain 1 — Enterprise Support
**Topic**: Support tiers
**Difficulty**: Beginner

An enterprise customer is experiencing a critical production outage due to GitHub Actions being completely unavailable. What is the minimum support tier that provides a 30-minute first response SLA?

A. GitHub Community Support
B. GitHub Support (Standard)
C. GitHub Premium Support
D. GitHub Advanced Support

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: GitHub Premium Support provides a 30-minute first response time for urgent issues. Standard GitHub Support (included with Team/Enterprise plans) provides an 8-business-hour response for urgent issues. There is no "GitHub Advanced Support" tier — the tiers are Community, Standard, Premium, and Premium Plus. For a critical production outage, Premium Support's 30-minute SLA is the minimum qualifying option.

**Reference**: https://docs.github.com/en/support/learning-about-github-support/about-github-support

</details>

---

### Question 2
**Domain**: Domain 1 — Enterprise Support
**Topic**: Audit log retention
**Difficulty**: Intermediate

A compliance officer requires GitHub audit log data to be retained for 2 years for regulatory purposes. The enterprise currently only uses the GitHub Enterprise Cloud audit log UI. What must the administrator configure?

A. Increase the audit log retention period in enterprise settings to 730 days
B. Configure audit log streaming to an external storage destination
C. Use the audit log REST API to export logs daily and store them externally
D. Purchase GitHub Premium Plus Support to extend audit log retention

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: GitHub Enterprise Cloud retains audit logs for 90 days in the UI and 90 days via the REST API (7 days for Git events). This cannot be extended. The only way to achieve 2-year retention is to configure **audit log streaming** to an external destination (Amazon S3, Azure Blob Storage, Google Cloud Storage, Splunk, or Datadog). Option C (daily API export) is a workaround that would technically work but is not the supported feature designed for this use case. Option A is incorrect — there is no setting to extend audit log retention in the UI. Option D is incorrect — support tier has no impact on audit log retention.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/streaming-the-audit-log-for-your-enterprise

</details>

---

### Question 3
**Domain**: Domain 1 — Enterprise Support
**Topic**: GitHub Status page
**Difficulty**: Beginner

Multiple developers in an organization report that push operations to GitHub are failing. As the GitHub administrator, what is the first thing you should check?

A. The organization's webhook delivery log
B. The enterprise audit log for failed push events
C. The GitHub Status page at status.github.com
D. The repository settings for push protection configuration

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: When multiple users across the organization report the same issue simultaneously, the most likely cause is a GitHub platform-wide or regional incident. The correct first step is to check **status.github.com** to determine if GitHub is experiencing an active incident. If the status page shows a Git operations incident, the issue is on GitHub's side and no further troubleshooting is needed until GitHub resolves it. If the status page is all green, then proceed to investigate organization-specific causes (webhooks, push protection, etc.).

**Reference**: https://www.githubstatus.com/

</details>

---

### Question 4
**Domain**: Domain 1 — Enterprise Support
**Topic**: Enterprise reporting
**Difficulty**: Intermediate

An enterprise administrator needs to identify which users have not logged into GitHub in the past 90 days in order to reclaim unused license seats. Where can this information be found?

A. The organization's People tab, filtered by last active date
B. Enterprise Settings > License, by downloading the license usage CSV
C. The audit log, filtered to authentication events
D. The security overview dashboard

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: The license usage report (downloadable from Enterprise Settings > License) includes each user's last active date. Downloading this as a CSV allows filtering for users inactive for 90+ days. While the audit log (option C) would contain login events, filtering it to identify all users who have NOT logged in would require complex queries and is not the intended use case. The org People tab (option A) shows members but does not provide a direct "last active" filter in a downloadable format. Security overview (option D) shows security alerts, not user activity.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/billing/managing-the-plan-for-your-github-account/viewing-the-subscription-and-usage-for-your-enterprise-account

</details>

---

### Question 5
**Domain**: Domain 1 — Enterprise Support
**Topic**: Support tiers and TAM
**Difficulty**: Beginner

Which GitHub Support tier includes a dedicated Technical Account Manager (TAM)?

A. GitHub Support (Standard)
B. GitHub Premium Support
C. GitHub Premium Plus Support
D. GitHub Enterprise Support

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: A Technical Account Manager (TAM) is included only with **GitHub Premium Plus Support**. Premium Plus is the highest tier, offering proactive guidance, quarterly business reviews, escalation to GitHub engineering, and a 15-minute first response SLA for urgent issues. GitHub Premium Support (option B) provides 24/7 support and 30-minute urgent response but does not include a TAM. There is no tier called "GitHub Enterprise Support."

**Reference**: https://docs.github.com/en/support/learning-about-github-support/about-github-premium-support

</details>

---

## Official Documentation Links

- [About GitHub Support](https://docs.github.com/en/support/learning-about-github-support/about-github-support)
- [About GitHub Premium Support](https://docs.github.com/en/support/learning-about-github-support/about-github-premium-support)
- [GitHub Status Page](https://www.githubstatus.com/)
- [Enterprise Audit Log](https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/about-the-audit-log-for-your-enterprise)
- [Audit Log Streaming](https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/streaming-the-audit-log-for-your-enterprise)
- [License Usage Reports](https://docs.github.com/en/enterprise-cloud@latest/billing/managing-the-plan-for-your-github-account/viewing-the-subscription-and-usage-for-your-enterprise-account)
