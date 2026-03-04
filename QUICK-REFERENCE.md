# GH-100 Quick Reference — GitHub Administration

Printable cheat sheet covering all 6 exam domains. Designed for last-minute review before the exam.

---

## Domain 1 — Enterprise Support (9%)

### Support Tiers
| Tier | Response Time | Availability | Included With |
|------|--------------|--------------|---------------|
| GitHub Community | None (community) | Public forum | All plans |
| GitHub Support | 8-hour (urgent) | Business hours | Team/Enterprise |
| GitHub Premium Support | 30-min (urgent) | 24/7/365 | Add-on |
| GitHub Premium Plus | 15-min (urgent) | 24/7/365 + TAM | Add-on |

### Key Admin Capabilities
- **Audit log**: Enterprise-level audit log captures org + repo + user events; stream to external SIEM
- **GitHub Status**: status.github.com — check incident history and subscribe to notifications
- **Support tickets**: Raised from `github.com/support` or enterprise admin console
- **Audit log retention**: 7 days (API streaming); 90 days (UI) for enterprise audit logs
- **Enterprise reporting**: License usage, actions usage, secret scanning summary available in enterprise settings

### Exam Tip
Premium Support includes a **Technical Account Manager (TAM)**. Premium Plus adds dedicated engineering support and custom training.

---

## Domain 2 — Identity & Authentication (11%)

### Authentication Methods
| Method | Use Case | Enterprise Control |
|--------|----------|-------------------|
| Username/Password | Individual accounts | Cannot enforce for GHEC |
| SSH Keys | Git operations | Can require org-level approval |
| Personal Access Tokens (classic) | API/Git access | Can require expiration |
| Fine-grained PATs | Scoped API access | Can require approval |
| OAuth Apps | Third-party integrations | Can block/approve per org |
| GitHub Apps | First-class integrations | Can block/approve per org |
| SAML SSO | Enterprise IdP auth | Enforced per org (GHEC) or globally (GHES) |

### SAML SSO Key Points
- Configured per organization on GHEC; globally on GHES
- Users must authorize their PAT/SSH key for SSO after SAML is enabled
- Linking: User's GitHub account is linked to IdP identity via **NameID**
- **SCIM** provisions and deprovisions users automatically via IdP
- Supported IdPs: Okta, Azure AD (Entra ID), OneLogin, PingFederate, and any SAML 2.0 provider

### Enterprise Managed Users (EMU)
- Accounts are **created and controlled by the IdP** — users cannot sign up independently
- EMU users can only access resources within the enterprise
- Usernames are derived from the IdP
- Requires a separate GitHub Enterprise Cloud with EMU enabled (different from standard GHEC)
- Cannot interact with public repositories outside the enterprise

### Two-Factor Authentication (2FA)
- Enforceable at organization or enterprise level
- Methods: TOTP app, SMS (deprecated), security key (WebAuthn), GitHub Mobile
- Enterprise owners can require 2FA for all members
- Users without 2FA are removed from org if requirement is enforced

### LDAP (GHES Only)
- Configure in GHES Management Console
- Sync: `ghe-ldap-sync` — syncs team memberships from LDAP groups
- Authentication via LDAP, SAML, or built-in (GHES only)

---

## Domain 3 — Deployment, Distribution & Licensing (9%)

### Deployment Models
| Model | Hosted By | Network | Customization | Licensing |
|-------|-----------|---------|---------------|-----------|
| GitHub.com (Free/Pro/Team) | GitHub | Public cloud | Low | Per user |
| GitHub Enterprise Cloud (GHEC) | GitHub | Public cloud | Medium | Per seat |
| GitHub Enterprise Server (GHES) | Customer | On-premises / private cloud | High | Per seat |
| GitHub AE (Deprecated) | GitHub | Isolated cloud | High | Per seat |

### GHES Key Facts
- Deployed as a **virtual appliance** (VMware, Hyper-V, AWS, Azure, GCP)
- Version upgrades are manual (hotpatch or upgrade package)
- **High Availability (HA)**: Primary + replica appliance; automatic failover
- **Geo-replication**: Multiple replicas in different regions for read performance
- **Backup Utilities**: `github-backup-utils` — snapshot backups of all GHES data
- Management Console: `https://HOSTNAME:8443` — admin web UI for GHES
- **ghe-config-apply** — apply configuration changes
- License file uploaded via Management Console or via `ghe-license` CLI

### Licensing
- GitHub Enterprise = GHEC + GHES (bundled license)
- **Per-seat licensing**: each unique user consuming a seat is counted once
- License sync: GHES syncs license usage to GitHub.com every 24 hours (if connected)
- **GitHub Connect**: bridges GHES to GitHub.com for license sync, unified search, GitHub Actions caching from GHEC

### GHES vs GHEC Feature Gaps
- GHEC: SAML SSO per org, Actions minutes included, Codespaces
- GHES: LDAP, CAS, built-in auth, full data sovereignty, no monthly bandwidth cap

---

## Domain 4 — Access & Permissions (18%)

### Permission Levels (Repository)
| Role | Read | Triage | Write | Maintain | Admin |
|------|------|--------|-------|----------|-------|
| View code | Yes | Yes | Yes | Yes | Yes |
| Create issues | Yes | Yes | Yes | Yes | Yes |
| Push to non-protected branches | No | No | Yes | Yes | Yes |
| Manage branch protections | No | No | No | Yes | Yes |
| Delete repository | No | No | No | No | Yes |

### Organization Roles
| Role | Capabilities |
|------|-------------|
| Owner | Full control — settings, billing, member management, security |
| Member | Access repos per base permission; manage own teams |
| Billing Manager | View/manage billing only; no repo access |
| Security Manager | Read all repos; manage security alerts org-wide |
| Outside Collaborator | Access to specific repos only; not an org member |

### Enterprise Roles
- **Enterprise owner**: Full control over all organizations in the enterprise
- **Enterprise member**: Member of at least one org in the enterprise
- **Billing manager**: Enterprise-level billing access only

### Base Permissions
Set at the organization level. Options: None, Read, Write, Admin.
Default is Read — members get at minimum read access to all org repos.

### Repository Visibility
| Visibility | Who Can See | Available On |
|------------|------------|--------------|
| Public | Everyone | All plans |
| Private | Members with access | All plans |
| Internal | All enterprise members | GHEC / GHES |

**Internal** repositories are key for inner-sourcing — visible to all enterprise members but not the public.

### Team Hierarchy
- Teams can be nested (parent/child)
- Child teams inherit parent team permissions
- Teams can be synced with IdP groups (SAML + SCIM required)
- `@org/team-name` mention to notify the whole team

### CODEOWNERS
- File location: `.github/CODEOWNERS`, `CODEOWNERS`, or `docs/CODEOWNERS`
- Patterns use `.gitignore` syntax
- When a PR touches a file, matching CODEOWNERS are automatically requested as reviewers
- Combine with branch protection "Require review from code owners" for enforcement

### Enterprise Policies
Set at the enterprise level — **override** organization settings. Examples:
- Repository creation policy (who can create repos)
- Repository deletion and transfer policy
- Forking policy (disable forks of private/internal repos)
- Default repository visibility
- Actions policies

---

## Domain 5 — Security & Compliance (36%)

### GitHub Advanced Security (GHAS)
Requires GHAS license (included with GHEC for public repos, licensed for private/internal).
Enables: code scanning, secret scanning (push protection), dependency review.

### Secret Scanning
| Feature | What It Does |
|---------|-------------|
| Secret scanning alerts | Detects committed secrets in repo history |
| Push protection | Blocks pushes containing secrets before they reach the repo |
| Custom patterns | Define regex patterns for org/enterprise-specific secrets |
| Partner program | 100+ patterns detected automatically by default |
| Alert management | Dismiss, resolve, or re-open alerts |

Push protection can be enabled at the repository, organization, or enterprise level.

### Dependabot
| Feature | What It Does |
|---------|-------------|
| Dependabot alerts | Notifies of vulnerable dependencies (CVE database) |
| Dependabot security updates | Auto-creates PRs to fix vulnerable deps |
| Dependabot version updates | Auto-creates PRs to keep deps up to date |
| `dependabot.yml` | Config file in `.github/` to configure update schedules |

### Code Scanning
- Uses **CodeQL** (GitHub's semantic analysis engine) or third-party SARIF tools
- Configured via Actions workflow or default setup (one-click at repo or org level)
- Results appear as code scanning alerts in the Security tab
- Can be required via branch protection rules (required status checks)

### Branch Protection Rules (Classic)
Key settings:
- Require pull request reviews before merging (N reviewers)
- Require review from code owners
- Dismiss stale reviews when new commits are pushed
- Require status checks to pass (CI, code scanning)
- Require branches to be up to date
- Require signed commits
- Include administrators (bypass toggle)
- Restrict who can push to matching branches
- Allow force pushes
- Allow deletions

### Repository Rulesets (Newer — Prefer These)
- Available at repository, organization, or enterprise level
- Supports **bypass actors** (specific roles/teams can bypass)
- Multiple rulesets can apply to same branch simultaneously
- Rule types: branch name, tag name, commit message, required deployments, required workflows, code scanning results
- **Enterprise rulesets** cascade down to all orgs/repos

### Dependency Review
- Requires GHAS for private repos
- `dependency-review-action` in a workflow checks PRs for vulnerable dependency changes
- Configured via `dependency-review-config.yml` or inline action params
- Can **fail the workflow** if a PR introduces a known vulnerability

### Security Policies
- `SECURITY.md` in `.github/` or root of repo
- Defines how to report vulnerabilities (private vulnerability reporting)
- **Private vulnerability reporting**: maintainers enable it per repo; reporters submit via Security tab

### Audit Log Streaming
- Stream enterprise audit log to: Azure Blob Storage, Amazon S3, Google Cloud Storage, Splunk, Datadog
- Configure in enterprise settings > Audit log > Streams
- Events include: authentication, repository actions, org changes, billing events

### IP Allow Lists
- Restricts access to the enterprise or organization to specific IP ranges
- Configured in organization/enterprise settings
- Applies to web, API, and Git access

---

## Domain 6 — GitHub Actions (16%)

### Actions Policies (Enterprise/Org Level)
- **Disable Actions** for all repos, selected repos, or all repos
- **Allow all actions** or restrict to: GitHub-created, verified marketplace, specific actions list
- Set at organization level or enterprise level (enterprise policy overrides org)

### Self-Hosted Runners
| Scope | Registered At | Available To |
|-------|--------------|--------------|
| Repository | Repo settings | That repo only |
| Organization | Org settings | All repos in org (via runner groups) |
| Enterprise | Enterprise settings | All orgs (via runner groups) |

### Runner Groups
- Organize self-hosted runners into groups
- Control which orgs/repos can use which runner group
- Default group: all new self-hosted runners added here
- Can restrict to specific organizations and repositories
- GitHub-hosted runners have their own default group

### Required Workflows
- Defined at the organization level
- Applied to matching repositories in the org
- Workflow must pass before PRs can be merged
- Enforces org-wide CI standards

### Workflow Permissions
- Default: `GITHUB_TOKEN` read-only for all permissions
- Can set to read/write for specific permissions in `permissions:` block
- **Enterprise/org default**: configure whether `GITHUB_TOKEN` defaults to read or read+write
- `secrets.GITHUB_TOKEN` is auto-generated per workflow run; expires when run ends

### Encrypted Secrets
| Scope | Set At | Available To |
|-------|--------|-------------|
| Repository secret | Repo settings | That repo |
| Organization secret | Org settings | Repos granted access |
| Environment secret | Environment settings | Jobs targeting that environment |
| Enterprise secret | Enterprise settings | All orgs (GitHub-hosted runners) |

### Environments and Deployment Protection
- Environments: production, staging, etc.
- **Protection rules**: required reviewers, wait timer, deployment branches
- Environments can restrict which branches can deploy to them
- Secrets scoped to environments are only available when a job targets that environment

### OIDC for Cloud Authentication
- Instead of long-lived secrets, workflows get a short-lived OIDC token
- Cloud providers (AWS, Azure, GCP) validate the token against GitHub's OIDC endpoint
- Configure via `permissions: id-token: write` + cloud provider's GitHub OIDC integration

### Actions Cache
- `actions/cache` action caches dependencies between runs
- Cache key is based on hash of lock files
- Max cache size: 10 GB per repository
- Cache entries evicted after 7 days of no access

### Usage Limits
| Resource | GitHub-Hosted Limit |
|----------|-------------------|
| Job execution time | 6 hours |
| Workflow run time | 35 days |
| API requests per hour | 1,000 per repo per hour |
| Concurrent jobs (free) | 20 |
| Concurrent jobs (Team) | 40 |

---

## Key CLI Commands Reference

### GHES Admin Commands
```bash
# Apply configuration changes
ghe-config-apply

# Check cluster status
ghe-cluster-status

# Run LDAP sync
ghe-ldap-sync

# Backup GHES
ghe-backup

# Restore GHES
ghe-restore

# Check license
ghe-license

# List users
ghe-user-list

# Promote user to admin
ghe-user-promote USERNAME

# Check replication status
ghe-repl-status
```

### GitHub CLI (gh) Useful Commands
```bash
# Manage org members
gh api orgs/ORG/members

# List enterprise organizations
gh api enterprises/ENTERPRISE/organizations

# List secret scanning alerts
gh api repos/OWNER/REPO/secret-scanning/alerts

# List Dependabot alerts
gh api repos/OWNER/REPO/dependabot/alerts

# List code scanning alerts
gh api repos/OWNER/REPO/code-scanning/alerts

# Audit log
gh api enterprises/ENTERPRISE/audit-log

# List self-hosted runners
gh api orgs/ORG/actions/runners
```

---

## Key File Locations

| File | Purpose |
|------|---------|
| `.github/SECURITY.md` | Security vulnerability reporting policy |
| `.github/CODEOWNERS` | Auto-assign reviewers by file path |
| `.github/dependabot.yml` | Configure Dependabot update schedules |
| `.github/workflows/*.yml` | GitHub Actions workflow definitions |
| `SECURITY.md` (root) | Alternative location for security policy |
| `docs/CODEOWNERS` | Alternative CODEOWNERS location |

---

## SAML SSO Configuration Summary

1. Go to Org Settings > Authentication security > SAML single sign-on
2. Enter IdP SSO URL, Issuer, and Public certificate
3. Test SAML configuration before enabling
4. Enable SAML SSO (members must re-authenticate)
5. Enable SCIM provisioning in IdP (requires SCIM token)
6. Members must authorize PATs and SSH keys for SAML SSO
7. Revoked IdP sessions = revoked GitHub access (with SCIM)

---

## Exam-Day Reminders

- Read questions carefully — "organization" vs "enterprise" scope changes the answer
- "Enterprise policy" always overrides "organization policy"
- GHAS features require the GHAS license for private/internal repos
- Push protection and secret scanning alerts are separate features (both need GHAS for private repos)
- Branch protection rules (classic) and rulesets coexist — rulesets are the newer, more flexible model
- Self-hosted runners should use ephemeral mode for security (especially for public repos)
- EMU users cannot have personal accounts outside the enterprise
- SCIM deprovisions users automatically; SAML alone does not
