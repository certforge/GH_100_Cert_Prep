# GH-100 Key Terms Glossary

GitHub Administration terminology you must know for the exam. Definitions reflect GitHub's official usage.

---

## A

**Audit Log**
A chronological record of all events in an organization or enterprise. Captures authentication events, repository actions, membership changes, billing events, and more. Available via the GitHub UI, REST API, and streaming. Enterprise audit logs cover all organizations within the enterprise.

**Audit Log Streaming**
A feature that continuously forwards audit log events to an external destination in real time. Supported destinations: Amazon S3, Azure Blob Storage, Google Cloud Storage, Splunk, and Datadog. Required for long-term retention beyond the 90-day UI window.

---

## B

**Base Permissions**
The minimum repository permission level granted to all members of an organization. Options: None, Read, Write, Admin. Applies to all organization-owned repositories for all org members. Does not affect outside collaborators.

**Billing Manager**
An organization or enterprise role that grants access to billing settings and invoices only. A Billing Manager cannot access repositories or manage members.

**Branch Protection Rule**
A classic (legacy) rule applied to branches matching a specific name pattern. Controls who can push, whether PRs are required, what status checks must pass, and more. Being superseded by Repository Rulesets in newer GitHub features.

---

## C

**CAS (Central Authentication Service)**
An authentication protocol supported by GitHub Enterprise Server. Allows GHES to delegate authentication to a CAS server. GHES-specific; not available on GHEC.

**Classic PAT (Personal Access Token)**
An older form of personal access token that uses account-level scopes (e.g., `repo`, `admin:org`). Classic PATs cannot be scoped to a specific repository. See also: Fine-Grained PAT.

**CodeQL**
GitHub's semantic code analysis engine used for code scanning. CodeQL models code as a database and runs queries to find security vulnerabilities. Supports C/C++, C#, Go, Java, JavaScript/TypeScript, Python, Ruby, Swift.

**CODEOWNERS**
A file that defines which individuals or teams are responsible for code in a repository. Located in `.github/CODEOWNERS`, `docs/CODEOWNERS`, or root `CODEOWNERS`. Uses `.gitignore`-style patterns. When combined with a branch protection rule requiring code owner review, changes to owned files require approval from the code owner.

**Code Scanning**
A GHAS feature that analyzes code for security vulnerabilities and coding errors. Uses CodeQL by default; also accepts results from third-party tools in SARIF format. Results appear as code scanning alerts in the Security tab.

**Custom Secret Scanning Pattern**
A user-defined regular expression added to secret scanning to detect secrets specific to an organization or enterprise that are not in the GitHub Partner Program list.

---

## D

**Default Setup (Code Scanning)**
A one-click method to enable code scanning on a repository or across an organization. GitHub automatically determines the languages present and configures CodeQL accordingly. No workflow file editing required.

**Dependabot**
An automated service that monitors dependencies for known vulnerabilities and updates. Consists of three features: Dependabot alerts (notifications), Dependabot security updates (auto-PRs for vulnerable deps), and Dependabot version updates (auto-PRs to keep deps current).

**Dependabot Alerts**
Notifications generated when a repository's dependency is found in the GitHub Advisory Database as having a known vulnerability (CVE). Enabled by default for public repos; can be enabled org/enterprise-wide.

**Dependabot Security Updates**
Automatically generated pull requests that update a vulnerable dependency to a patched version. Requires Dependabot alerts to be enabled.

**Dependabot Version Updates**
Automatically generated pull requests that keep dependencies up to date with their latest versions, regardless of whether a vulnerability exists. Configured via `.github/dependabot.yml`.

**Deploy Key**
An SSH key that grants read (or read-write) access to a single repository. Used for automated deployments. Unlike a user SSH key, a deploy key is scoped to one repository and does not grant access to the user's other repositories.

**Dependency Graph**
A GitHub feature that maps a repository's dependencies based on manifest files (package.json, requirements.txt, pom.xml, etc.). Required for Dependabot alerts to work. Enabled by default for public repos.

**Dependency Review**
A GHAS feature that shows changes to dependencies in pull requests, flagging any that introduce known vulnerabilities. Implemented via the `dependency-review-action` in a workflow.

---

## E

**EMU (Enterprise Managed Users)**
A GitHub Enterprise Cloud configuration where user accounts are fully managed by the enterprise's Identity Provider. EMU users are created by the IdP, cannot sign up independently, and can only access resources within the enterprise. Their usernames are derived from the IdP.

**Enterprise**
The top-level administrative entity in GitHub that contains one or more organizations. An enterprise account is required for GHEC and GHES. Enterprise owners can set policies that apply across all organizations.

**Enterprise Owner**
The highest-privilege role in GitHub. Enterprise owners can manage all organizations, set enterprise-wide policies, view all audit logs, and manage billing.

**Ephemeral Runner**
A self-hosted runner configured to handle one job and then stop (also called a JIT runner). Best practice for security, especially for public repositories, because the runner environment is clean for each job.

---

## F

**Fine-Grained PAT (Personal Access Token)**
A newer PAT format that allows granular scoping to specific repositories and specific permissions (e.g., read-only access to issues for one repository). More secure than classic PATs. Can require organization owner approval before use.

**Fork Policy**
An organization or enterprise policy that controls whether repositories can be forked. Can restrict forking of private and internal repositories. Separate policies for private vs internal repos.

---

## G

**ghe-backup-utils**
The official open-source backup toolkit for GitHub Enterprise Server. Creates point-in-time snapshot backups of all GHES data including repositories, database, configuration, and storage assets.

**ghe-config-apply**
A GHES CLI command that applies pending configuration changes. Run after making changes in the Management Console or via `ghe-config set`.

**ghe-repl-setup**
A GHES CLI command used to configure a secondary appliance as a high-availability replica.

**ghe-repl-status**
A GHES CLI command that reports the current replication lag and status between the primary and replica appliances.

**GHAS (GitHub Advanced Security)**
A set of security features for GitHub repositories: code scanning, secret scanning (with push protection), and dependency review. Free for public repositories. Requires a paid license for private and internal repositories. Licensed per active committer.

**GitHub AE**
GitHub's now-deprecated isolated cloud deployment option (Azure-hosted). Customers should migrate to GHEC or GHES.

**GitHub Actions**
GitHub's built-in CI/CD and automation platform. Workflows are defined in YAML files in `.github/workflows/`. Jobs run on GitHub-hosted or self-hosted runners.

**GitHub Advisory Database**
GitHub's database of known security vulnerabilities (CVEs and GHSAs). Used by Dependabot to identify vulnerable dependencies. Published publicly at https://github.com/advisories.

**GitHub Apps**
First-class integrations built on GitHub's API. GitHub Apps have fine-grained permissions, act as their own identity (not as a user), and can be installed on organizations or individual repositories. Preferred over OAuth Apps for most integration use cases.

**GitHub Connect**
A feature that creates a secure connection between a GHES instance and GitHub.com. Enables: license usage syncing, unified search (search GitHub.com from GHES), GitHub Sponsors, and Actions version pinning from GitHub.com.

**GitHub Enterprise Cloud (GHEC)**
GitHub's hosted enterprise product. Runs on GitHub.com infrastructure. Adds enterprise features: SAML SSO, audit log streaming, enterprise policies, GHAS, larger storage limits, and SLA guarantees.

**GitHub Enterprise Server (GHES)**
GitHub's self-hosted enterprise product. Deployed as a virtual appliance on customer infrastructure. Provides full data sovereignty. Includes additional auth options (LDAP, CAS, built-in).

**GitHub-Hosted Runners**
Virtual machines provided and managed by GitHub to run Actions workflow jobs. Available in Ubuntu, Windows, and macOS. Billed by compute minute.

---

## H

**High Availability (HA) — GHES**
A GHES architecture with a primary appliance and at least one replica. The replica can be promoted to primary if the primary fails. Replication is near-real-time.

---

## I

**IdP (Identity Provider)**
An external service that manages user authentication and identity. Common IdPs for GitHub SSO: Okta, Azure Active Directory (Entra ID), OneLogin, PingFederate. GitHub acts as a Service Provider (SP) that trusts the IdP.

**Internal Repository**
A repository visibility option available on GHEC and GHES. Internal repositories are visible to all members of the enterprise but not to the general public. Used for inner-sourcing.

**IP Allow List**
A security feature that restricts access to GitHub resources (org or enterprise) to specific IP address ranges. Blocks all traffic from IPs not on the list.

---

## J

**GITHUB_TOKEN**
An automatically generated, short-lived token that Actions workflows use to authenticate API requests. Created at the start of each workflow run and expires when the run completes. Its permissions can be configured at the organization/enterprise level and overridden in the workflow `permissions:` block.

---

## L

**LDAP (Lightweight Directory Access Protocol)**
A protocol for accessing directory services (like Active Directory). Supported by GHES for authentication and team membership sync. Not available on GHEC.

**License Seat**
A license unit consumed by a unique user. In GitHub Enterprise, each unique user who can access the system consumes one seat, regardless of how many organizations they belong to.

---

## M

**Management Console**
The web-based administration UI for GitHub Enterprise Server. Accessed at `https://HOSTNAME:8443`. Used for configuration, maintenance mode, upgrades, SSL certificates, authentication settings, and resource management.

**Merge Queue**
A GitHub feature that automatically queues pull requests for merging, running required checks before each merge. Prevents merge conflicts and failed checks. Enabled per branch in branch protection rules.

---

## N

**NameID**
In SAML, the identifier used to link a GitHub user account to their IdP identity. GitHub uses the NameID sent by the IdP during SAML authentication to associate the GitHub account with the IdP user record.

---

## O

**OAuth App**
A third-party application that authenticates as a GitHub user using OAuth 2.0. OAuth Apps request scopes (like `repo`, `admin:org`) and act on behalf of the user. Organization owners can require OAuth App approval before use within the org.

**OIDC (OpenID Connect)**
An identity protocol built on OAuth 2.0. In the context of GitHub Actions, OIDC allows workflows to obtain a short-lived token from GitHub's OIDC provider to authenticate with cloud providers (AWS, Azure, GCP) without storing long-lived credentials as secrets.

**Organization**
A shared GitHub account that groups users and repositories. Organizations are the primary administrative unit for teams, permissions, and billing. An enterprise can contain multiple organizations.

**Outside Collaborator**
A user who has been granted access to one or more repositories in an organization but is not an org member. Outside collaborators do not inherit base permissions and only have access to explicitly granted repositories.

---

## P

**Personal Access Token (PAT)**
A token used in place of a password for API or Git access. Two types: classic PAT (account-wide scopes) and fine-grained PAT (repo-specific, permission-specific). PATs created for use in SAML SSO-protected organizations must be authorized for SSO.

**Private Repository**
A repository visible only to the repository owner and explicitly granted collaborators/teams. Available on all GitHub plans.

**Private Vulnerability Reporting**
A feature that allows security researchers to privately report vulnerabilities to maintainers via the Security tab, without creating a public issue. Maintainers can then create a private security advisory, fix the vulnerability, and coordinate disclosure.

**Push Protection**
A secret scanning feature that blocks pushes to a repository if the pushed commits contain known secrets (tokens, API keys, etc.). Can be bypassed with a justification if the user has permission to do so.

---

## R

**Replication (GHES)**
The process of keeping a GHES replica appliance synchronized with the primary. Near-real-time replication of all data. Used for both HA (failover) and geo-replication (geographic read performance).

**Repository Role**
The permission level assigned to a user or team for a specific repository. Standard roles: Read, Triage, Write, Maintain, Admin. Custom repository roles can be created on GHEC/GHES.

**Repository Ruleset**
A newer, more flexible alternative to branch protection rules. Can be applied at the repository, organization, or enterprise level. Supports bypass actors, multiple simultaneous rulesets, and a richer set of rules.

**Required Status Checks**
A branch protection or ruleset requirement that specific CI checks (workflow jobs) must pass before a pull request can be merged.

**Required Workflow**
An organization-level policy that forces specific Actions workflows to run and pass for all matching repositories in the org. Different from required status checks (which reference check names); required workflows reference actual workflow files.

**Runner Group**
A collection of self-hosted runners grouped for access control purposes. Runner groups can be restricted to specific organizations (enterprise-level) or specific repositories (org-level).

---

## S

**SAML (Security Assertion Markup Language)**
An XML-based standard for exchanging authentication and authorization data between an Identity Provider (IdP) and a Service Provider (SP). GitHub uses SAML 2.0 for enterprise SSO.

**SAML SSO**
Single sign-on implemented via SAML. Users authenticate through their company's IdP instead of directly with GitHub credentials. Required for SCIM provisioning.

**SARIF (Static Analysis Results Interchange Format)**
A standard JSON-based format for representing the output of static analysis tools. GitHub accepts SARIF results from third-party SAST tools for display as code scanning alerts.

**SBOM (Software Bill of Materials)**
A formal record of all components and dependencies in a software artifact. GitHub can generate SBOMs in SPDX and CycloneDX formats for repositories.

**SCIM (System for Cross-domain Identity Management)**
A standard for automating the provisioning and deprovisioning of user accounts. When configured, the IdP automatically creates and removes GitHub accounts (and org memberships) as users are added or removed in the IdP.

**Secret Scanning**
A GHAS feature that scans repository history and new commits for known secret formats (API keys, tokens, credentials). Two components: secret scanning alerts (detect already-committed secrets) and push protection (block new commits containing secrets).

**Security Manager**
An organization role that grants read access to all repositories in the org and the ability to manage all code scanning, secret scanning, and Dependabot alerts. Does not grant admin or write access.

**Security Overview**
A dashboard in GitHub that provides an organization-wide or enterprise-wide view of security alerts, feature enablement coverage, and risk metrics across all repositories.

**Self-Hosted Runner**
A runner machine that the customer manages and registers with GitHub to run Actions workflow jobs. Can be any physical or virtual machine with network access to GitHub.com (or GHES).

**SSH CA (Certificate Authority)**
An SSH certificate authority registered with a GitHub organization. Users can authenticate via SSH certificates signed by the org's CA instead of registering individual SSH keys.

---

## T

**Team**
A group within a GitHub organization that can be granted permissions to repositories. Teams can be nested (parent/child), mentioned as a group, and synced with IdP groups.

**Team Sync**
A feature that synchronizes GitHub team memberships with IdP groups automatically. Requires SAML SSO and SCIM to be configured. When a user is added to an IdP group, they are automatically added to the corresponding GitHub team.

**TOTP (Time-based One-Time Password)**
A 2FA method that generates a 6-digit code every 30 seconds from an authenticator app (Google Authenticator, Authy, etc.). Supported as a GitHub 2FA method.

---

## V

**Vulnerability Disclosure Policy**
Documented guidance (typically in SECURITY.md) on how security researchers should report vulnerabilities. Private vulnerability reporting is GitHub's built-in mechanism for this.

---

## W

**WebAuthn**
A web standard for strong authentication using hardware security keys (YubiKey, etc.) or built-in biometric authenticators. Supported as a GitHub 2FA method (listed as "security key" in GitHub settings).

**Workflow**
A YAML-defined automation in GitHub Actions stored in `.github/workflows/`. Triggered by events (push, PR, schedule, etc.) and composed of one or more jobs that run on runners.
