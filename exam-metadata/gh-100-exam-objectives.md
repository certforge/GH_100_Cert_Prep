# GH-100 Exam Objectives — Complete Domain Breakdown

**Exam**: GH-100: GitHub Administration
**Version**: Based on publicly available exam objectives (verify at https://examregistration.github.com/)

---

## How to Read This Document

Each domain lists its weight, then breaks down into measurable objectives — the specific skills and knowledge tested on the exam. Use this as a checklist: when you can confidently answer questions on each objective, you are ready for the exam.

---

## Domain 1 — Support GitHub Enterprise for Users and Key Stakeholders
**Weight: 9% (approximately 7-9 questions)**

### 1.1 Describe GitHub Support Options
- Distinguish between GitHub Community Support, GitHub Support, GitHub Premium Support, and GitHub Premium Plus Support
- Identify what response time SLAs apply to each support tier
- Know when to escalate to Premium Support vs standard support
- Understand the role of a Technical Account Manager (TAM)
- Know how to submit a support ticket and what information to include

### 1.2 Use GitHub Resources and Status Monitoring
- Access and interpret the GitHub Status page (status.github.com)
- Subscribe to GitHub status notifications (email, webhook, Atom feed)
- Locate the GitHub Changelog for feature announcements
- Use GitHub Roadmap to understand upcoming features
- Identify GitHub's public API changelog and deprecation notices

### 1.3 Manage the Enterprise Audit Log
- Access the enterprise audit log (via UI, API, and streaming)
- Understand the types of events captured (authentication, repository, org, billing)
- Filter audit log events by actor, action, and date range
- Configure audit log streaming to external destinations (S3, Azure Blob, Splunk, Datadog, GCS)
- Understand audit log retention periods (90 days in UI, 7 days for API, unlimited with streaming)
- Export audit log data via the REST API

### 1.4 Generate and Interpret Enterprise Reports
- Access license usage reports (who is consuming seats)
- Generate and download Actions usage reports
- Review secret scanning summary at the enterprise level
- Access Dependabot alert summaries across the enterprise
- Interpret code scanning coverage statistics

### 1.5 Communicate GitHub Changes to Stakeholders
- Identify strategies for communicating feature rollouts to users
- Use GitHub Discussions or wikis for internal announcements
- Understand GitHub's public communication channels for major changes

---

## Domain 2 — Manage User Identities and GitHub Authentication
**Weight: 11% (approximately 9-11 questions)**

### 2.1 Configure SAML Single Sign-On (SSO)
- Explain the purpose and architecture of SAML SSO
- Configure SAML SSO at the organization level on GHEC
- Configure SAML SSO globally on GHES (via Management Console)
- Identify supported Identity Providers (Okta, Azure AD / Entra ID, OneLogin, PingFederate)
- Understand the role of the NameID in linking GitHub accounts to IdP identities
- Test SAML configuration before enforcing it
- Handle SSO authorization for PATs and SSH keys

### 2.2 Configure SCIM Provisioning
- Explain the purpose of SCIM (System for Cross-domain Identity Management)
- Configure SCIM in the IdP to provision and deprovision GitHub users
- Understand that SCIM requires a SAML SSO configuration to already exist
- Know that SCIM automates user creation, attribute sync, and deprovisioning
- Understand the difference between SAML-only (no auto-deprovisioning) and SAML+SCIM

### 2.3 Manage Enterprise Managed Users (EMU)
- Explain what EMU is and how it differs from standard GHEC
- Know that EMU accounts are created entirely by the IdP
- Understand EMU restrictions (users cannot interact outside the enterprise)
- Know that EMU enterprises require separate setup (not convertible from standard GHEC)
- Understand username derivation (based on IdP username + enterprise shortcode)
- Know that EMU users cannot have a personal GitHub.com account

### 2.4 Configure Authentication Methods on GHES
- Configure built-in (username/password) authentication on GHES
- Configure LDAP authentication on GHES (via Management Console)
- Configure CAS (Central Authentication Service) on GHES
- Configure SAML authentication on GHES
- Run LDAP synchronization (`ghe-ldap-sync`)
- Manage LDAP team sync settings

### 2.5 Manage Personal Access Tokens
- Distinguish between classic PATs and fine-grained PATs
- Understand the scopes available for classic PATs
- Understand the permissions model for fine-grained PATs (resource owner, repositories, permissions)
- Configure PAT approval policies at the organization level
- Require expiration dates for PATs at the enterprise level
- Revoke PATs from the enterprise admin panel

### 2.6 Enforce Two-Factor Authentication
- Require 2FA at the organization level
- Require 2FA at the enterprise level
- Understand what happens to users who do not have 2FA enabled when enforcement begins
- Identify supported 2FA methods (TOTP, hardware security keys, GitHub Mobile)

### 2.7 Manage SSH Keys and Deploy Keys
- Require SSH key approval at the organization level
- Manage SSH certificate authorities (SSH CAs) for organizations
- Configure and use deploy keys (read-only or read-write access to a single repo)
- Understand the difference between a user SSH key, deploy key, and SSH CA

### 2.8 Manage OAuth Apps and GitHub Apps
- Distinguish between OAuth Apps and GitHub Apps
- Require OAuth App approval for organizations
- Restrict GitHub App installation to organization owners
- Review and revoke third-party OAuth app access
- Understand the GitHub Apps permission model (fine-grained per resource)

---

## Domain 3 — Describe How GitHub Is Deployed, Distributed, and Licensed
**Weight: 9% (approximately 7-9 questions)**

### 3.1 Describe GitHub Deployment Models
- Compare GitHub.com (Free/Pro/Team), GitHub Enterprise Cloud (GHEC), and GitHub Enterprise Server (GHES)
- Understand the decommissioned GitHub AE product
- Identify use cases that favor GHEC vs GHES
- Understand the concept of data residency and data sovereignty

### 3.2 Describe GitHub Enterprise Server Architecture
- Know that GHES is deployed as a virtual appliance
- Identify supported hypervisors (VMware vSphere, Hyper-V, XenServer, KVM, OpenStack)
- Identify supported cloud platforms (AWS, Azure, GCP)
- Understand the GHES Management Console (port 8443)
- Know that GHES is configured via the Management Console or `ghe-config` CLI

### 3.3 Manage GHES High Availability
- Explain the GHES primary + replica HA architecture
- Configure replication using `ghe-repl-setup` and `ghe-repl-start`
- Monitor replication status with `ghe-repl-status`
- Understand failover process and promotion of replica to primary
- Explain geo-replication (multiple read replicas in different regions)

### 3.4 Back Up and Restore GHES
- Know that `github-backup-utils` is the official backup tool
- Run `ghe-backup` to create a snapshot backup
- Run `ghe-restore` to restore from a backup
- Understand what is included in a GHES backup (repos, config, database, storage)
- Know the recommended backup frequency for production GHES instances

### 3.5 Upgrade and Maintain GHES
- Distinguish between hotpatch upgrades and full upgrade packages
- Understand the upgrade path (must upgrade incrementally through versions)
- Know that upgrades require scheduled maintenance mode
- Download upgrade packages from enterprise.github.com
- Understand release candidate (RC) versions and their purpose

### 3.6 Describe GitHub Licensing
- Understand per-seat licensing (each unique user = one seat)
- Know that GitHub Enterprise includes both GHEC and GHES rights
- Understand license seat consumption rules (what counts as a seat)
- Know that license usage syncs from GHES to GitHub.com every 24 hours (with GitHub Connect)
- Identify what GitHub Connect enables (license sync, unified search, GitHub Sponsors, Actions version pinning)

### 3.7 Describe GHES Networking Requirements
- Know default GHES port requirements (22, 25, 80, 443, 8443, 8080, 9418)
- Understand GHES network proxy configuration
- Know DNS requirements for GHES hostname
- Understand TLS certificate requirements for GHES (or self-signed option)

---

## Domain 4 — Manage Access and Permissions Based on Membership
**Weight: 18% (approximately 14-18 questions)**

### 4.1 Manage Repository Access and Roles
- Explain the five repository role levels (Read, Triage, Write, Maintain, Admin)
- Know what each role can and cannot do
- Assign repository roles to individual users or teams
- Understand custom repository roles (enterprise feature)
- Know when outside collaborators are used vs team members

### 4.2 Manage Organization Membership and Roles
- Explain organization roles (Owner, Member, Billing Manager, Security Manager)
- Invite users to an organization
- Remove members from an organization
- Convert organization members to outside collaborators
- Enforce membership requirements (2FA, SAML SSO authorization)

### 4.3 Configure Organization Base Permissions
- Set organization base permissions (None, Read, Write, Admin)
- Understand how base permissions interact with team permissions
- Know that the highest permission level always wins
- Configure default repository permission for new members

### 4.4 Manage Teams and Team Hierarchy
- Create teams and nested teams (parent/child)
- Assign team members and team maintainers
- Grant team permissions to repositories
- Understand that child teams inherit parent team repository access
- Configure team discussion settings
- Sync teams with IdP groups (team sync requires SAML SSO + SCIM)

### 4.5 Configure Repository Visibility
- Distinguish between public, private, and internal repositories
- Configure enterprise policies for who can change repository visibility
- Understand internal repositories (visible to all enterprise members)
- Configure forking policies for private and internal repositories
- Understand repository transfer implications for visibility and access

### 4.6 Configure Branch Protections
- Create branch protection rules for specific branches or patterns
- Configure required pull request reviews (including count and code owner requirement)
- Configure required status checks
- Enable "Require branches to be up to date before merging"
- Enable signed commit requirements
- Restrict who can push to protected branches
- Configure administrator bypass settings
- Understand merge queue and its relationship to branch protection

### 4.7 Configure Repository Rulesets
- Explain rulesets and how they differ from classic branch protections
- Create rulesets at the repository, organization, and enterprise level
- Configure bypass actors for rulesets
- Configure rules: required approvals, code owner review, status checks, commit message patterns, file path restrictions, file extension restrictions
- Understand that multiple rulesets can apply simultaneously (most restrictive wins for conflicts)
- Use ruleset insights to view bypass and rule evaluation history

### 4.8 Manage CODEOWNERS
- Create and format a CODEOWNERS file
- Understand the three valid CODEOWNERS file locations
- Write CODEOWNERS patterns (glob-style, `.gitignore` syntax)
- Understand how CODEOWNERS interacts with required reviews in branch protection
- Handle CODEOWNERS for monorepos with multiple teams

### 4.9 Manage Enterprise Policies for Access
- Configure enterprise-wide policies that override organization settings
- Restrict repository creation (who can create repos, what visibility)
- Configure repository deletion and transfer policies
- Configure forking policies at the enterprise level
- Restrict membership visibility (hide members from non-members)

### 4.10 Manage Outside Collaborators
- Add outside collaborators to repositories
- Understand that outside collaborators are not org members
- Convert outside collaborators to org members
- Enterprise policy: restrict or allow outside collaborators on private repositories

---

## Domain 5 — Enable Secure Software Development and Ensure Compliance
**Weight: 36% (approximately 29-36 questions)**

### 5.1 Configure GitHub Advanced Security (GHAS)
- Understand what GHAS includes (code scanning, secret scanning, dependency review)
- Know that GHAS is free for public repos on GitHub.com
- Know that GHAS requires a paid license for private/internal repos
- Enable GHAS at the repository, organization, or enterprise level
- Understand the GHAS license seat model (committer-based)

### 5.2 Configure and Manage Secret Scanning
- Enable secret scanning at the repository, organization, or enterprise level
- Understand the GitHub Partner Program (100+ token types detected by default)
- Create custom secret scanning patterns (regex) at org or enterprise level
- Configure push protection (blocks pushes containing secrets)
- Enable push protection at the organization or enterprise level
- Manage secret scanning alerts (dismiss, resolve, re-open)
- Understand alert states (open, resolved: false positive, resolved: revoked, resolved: used in tests, resolved: won't fix)
- Configure secret scanning to send email notifications
- Understand validity checks for active secrets

### 5.3 Configure and Manage Dependabot
- Enable Dependabot alerts (auto-enabled when a vulnerability is detected)
- Enable Dependabot security updates (auto-PRs to fix vulnerable dependencies)
- Configure Dependabot version updates via `.github/dependabot.yml`
- Understand supported package ecosystems (npm, pip, maven, gradle, cargo, gems, etc.)
- Configure Dependabot to use private registries
- Group Dependabot updates to reduce PR noise
- Manage Dependabot alerts (dismiss with reason, re-open)
- Understand the GitHub Advisory Database as the source for Dependabot alerts

### 5.4 Configure and Manage Code Scanning
- Enable code scanning with default setup (one-click, uses CodeQL)
- Enable code scanning with advanced setup (custom workflow file)
- Understand CodeQL as GitHub's semantic analysis engine
- Configure code scanning to run on push, pull request, and schedule
- Integrate third-party SAST tools via SARIF format
- Manage code scanning alerts (dismiss with reason, re-open)
- Require code scanning results as a branch protection status check
- Configure code scanning at the organization level (default setup rollout)

### 5.5 Configure Dependency Review
- Understand that dependency review shows dependency changes in PRs
- Enable the `dependency-review-action` in workflows
- Configure `dependency-review-config.yml` to fail on high-severity vulnerabilities
- Require dependency review as a required status check
- Understand that dependency review requires GHAS for private repos

### 5.6 Configure Branch Protection Rules
- Create and manage branch protection rules (see Domain 4.6 for rule types)
- Require specific status checks (CI, code scanning, dependency review)
- Require pull request reviews from at least N reviewers
- Require review from code owners (CODEOWNERS)
- Dismiss stale reviews when new commits are pushed
- Require signed commits (GPG or SSH signing)
- Prevent force pushes and branch deletion
- Restrict who can bypass rules (administrators bypass toggle)

### 5.7 Configure Repository Rulesets for Security
- Create rulesets enforcing commit signing
- Create rulesets requiring specific workflows to pass
- Configure file path restrictions (e.g., prevent edits to sensitive files)
- Configure enterprise-level rulesets that cascade to all repos
- Use bypass actors to allow specific roles/teams to bypass rules

### 5.8 Configure Security Policies
- Create a `SECURITY.md` file describing the vulnerability disclosure process
- Enable private vulnerability reporting for repositories or organizations
- Use security advisories to coordinate disclosure and request CVE IDs
- Configure default security policies at the organization level (`.github` repo)

### 5.9 Configure the Enterprise Security Overview
- Access the Security Overview dashboard at org and enterprise level
- Filter alerts by severity, ecosystem, alert type, and team
- Enable/disable security features for multiple repositories at once
- Understand coverage metrics (percentage of repos with each security feature enabled)
- Use security overview to identify repositories with the most critical alerts

### 5.10 Configure Audit Log and Compliance
- Enable audit log streaming to external SIEM systems
- Understand audit log event categories (repository, org, enterprise, authentication, billing, Actions)
- Use the audit log API to query programmatically
- Understand compliance considerations (SOC 2, FedRAMP for GHEC)
- Configure IP allow lists for organizations and enterprises
- Use GitHub's compliance documentation (Trust Center)

### 5.11 Configure Supply Chain Security
- Enable Dependency Graph (required for Dependabot alerts)
- Generate and download SBOMs (Software Bill of Materials) for repositories
- Understand Sigstore integration for artifact signing
- Configure private registries for Dependabot access
- Enable automatic dependency submission via Actions workflows

### 5.12 Manage Security at Scale
- Enable GHAS for all repositories in an organization (bulk enable)
- Configure default code scanning setup at the organization level
- Configure secret scanning push protection at the organization or enterprise level
- Use the REST API to manage security settings programmatically
- Understand the enterprise security enablement workflow

---

## Domain 6 — Manage GitHub Actions
**Weight: 16% (approximately 13-16 questions)**

### 6.1 Configure Actions Policies
- Enable or disable Actions at the repository, organization, or enterprise level
- Configure which actions are allowed (all, GitHub-created only, marketplace verified, custom allowlist)
- Understand that enterprise policies override organization policies
- Configure required status checks that use Actions workflows
- Understand Actions-specific enterprise policies

### 6.2 Manage Self-Hosted Runners
- Understand the self-hosted runner architecture (runner application, job queue, REST API)
- Register a self-hosted runner at the repository, organization, or enterprise level
- Understand the runner registration token and its expiry
- Configure runner labels for job routing (`runs-on: [self-hosted, linux, x64]`)
- Understand ephemeral runners (JIT runners) and why they are more secure
- Monitor runner status and online/offline state
- Remove (delete) a self-hosted runner
- Understand security considerations for self-hosted runners (especially with public repos)

### 6.3 Manage Runner Groups
- Create runner groups at the organization or enterprise level
- Add runners to runner groups
- Restrict runner groups to specific organizations (enterprise-level groups)
- Restrict runner groups to specific repositories (org-level groups)
- Understand the default runner group behavior
- Move runners between groups

### 6.4 Configure Required Workflows
- Understand required workflows (org-level workflows that must pass for all matching repos)
- Create and configure a required workflow in organization settings
- Understand which repository the required workflow source lives in
- Know that required workflows appear as required status checks on PRs
- Understand bypass permissions for required workflows

### 6.5 Manage Workflow Permissions and Secrets
- Configure the default GITHUB_TOKEN permissions (read-only vs read-write)
- Set workflow permissions at the organization or enterprise level
- Use the `permissions:` key in workflow files to scope GITHUB_TOKEN
- Create and manage encrypted secrets at repo, org, and enterprise levels
- Create and manage environment secrets
- Restrict which workflows can access organization secrets
- Understand that environment secrets are only available for jobs targeting the environment

### 6.6 Manage Environments and Deployment Protection
- Create deployment environments (production, staging, etc.)
- Configure required reviewers for environment deployments
- Configure deployment wait timers
- Configure deployment branch policies (restrict which branches can deploy)
- Understand how environment protection rules interact with workflow jobs
- Configure environment secrets and variables

### 6.7 Configure OpenID Connect (OIDC) for Cloud Authentication
- Understand the OIDC token flow in GitHub Actions
- Configure `permissions: id-token: write` in workflows
- Know the GitHub OIDC provider URL
- Understand cloud provider configuration (IAM roles, federated credentials)
- Know the security benefits of OIDC vs long-lived secrets

### 6.8 Manage Actions Cache
- Understand how `actions/cache` works
- Know the cache storage limit (10 GB per repository)
- Understand cache eviction policy (7 days of no access)
- Manage and delete caches via the API or UI
- Configure cache for specific branches

### 6.9 Monitor and Manage Actions Usage
- View Actions usage metrics (minutes consumed) at org and enterprise level
- Configure Actions spending limits
- Understand billing for GitHub-hosted runners (minutes per OS)
- Set usage limits for self-hosted runners
- Review workflow run history and logs
- Manage workflow run retention (default 90 days, configurable down to 1 day)

### 6.10 Manage Reusable Workflows
- Understand the difference between reusable workflows and composite actions
- Configure a workflow as reusable (using `workflow_call` trigger)
- Call a reusable workflow from another workflow
- Pass inputs and secrets to reusable workflows
- Use reusable workflows to standardize CI/CD processes across the organization

---

## Appendix: Key Objective Mapping

| Exam Domain | Key Skills to Demonstrate |
|-------------|--------------------------|
| Domain 1 | Audit log, support tiers, enterprise reporting |
| Domain 2 | SAML SSO, SCIM, EMU, PATs, 2FA, OAuth/GitHub Apps |
| Domain 3 | GHEC vs GHES, HA, backup, licensing, GitHub Connect |
| Domain 4 | Repository roles, org roles, teams, CODEOWNERS, rulesets, visibility |
| Domain 5 | GHAS, secret scanning, Dependabot, code scanning, branch protection, rulesets, security overview |
| Domain 6 | Actions policies, self-hosted runners, runner groups, required workflows, OIDC, secrets, environments |
