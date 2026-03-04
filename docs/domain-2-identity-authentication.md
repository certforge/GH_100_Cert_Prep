# Domain 2 — Manage User Identities and GitHub Authentication

**Exam Weight: 11%**
**Approximate Questions: 9-11**
**Priority: Medium-High**

---

## Domain Overview

Domain 2 covers how users authenticate to GitHub and how identity is managed at the enterprise level. This domain is particularly important because authentication choices cascade into security (Domain 5) and access control (Domain 4).

Key distinctions tested:
- SAML vs SCIM (authentication vs provisioning)
- EMU vs standard GHEC (two very different enterprise configurations)
- Classic PAT vs fine-grained PAT
- OAuth Apps vs GitHub Apps
- What each auth method can and cannot do

---

## Key Concepts

- **SAML SSO** — federated authentication via IdP
- **SCIM** — automated user provisioning/deprovisioning
- **EMU** — fully IdP-managed GitHub accounts
- **LDAP** — directory-based auth for GHES
- **2FA** — enforcement and supported methods
- **PATs** — classic vs fine-grained; org approval policies
- **SSH keys and SSH CAs** — per-user and org-level SSH auth
- **OAuth Apps vs GitHub Apps** — integration authentication models
- **Deploy keys** — single-repo SSH access for automation

---

## 2.1 SAML Single Sign-On

### How SAML SSO Works

SAML (Security Assertion Markup Language) is an XML-based protocol for federated authentication:

1. User attempts to access GitHub
2. GitHub redirects to the IdP login page (Service Provider-initiated SSO)
3. User authenticates with the IdP (password, MFA, etc.)
4. IdP sends a SAML assertion (signed XML) back to GitHub
5. GitHub validates the assertion and grants access
6. GitHub links the GitHub account to the IdP identity via the **NameID**

```
User Browser
     |
     | 1. Access GitHub
     v
GitHub.com (Service Provider)
     |
     | 2. Redirect to IdP
     v
Identity Provider (Okta, Azure AD, etc.)
     |
     | 3. User authenticates
     | 4. IdP sends SAML assertion
     v
GitHub.com
     |
     | 5. Validate assertion, link via NameID
     v
User gains access
```

### Configuring SAML SSO on GHEC (Org Level)

1. Navigate to: `Org Settings > Authentication security > SAML single sign-on`
2. Fill in:
   - **Sign on URL**: IdP SSO URL (e.g., `https://dev-12345.okta.com/app/github/sso/saml`)
   - **Issuer**: IdP Entity ID
   - **Public certificate**: IdP's X.509 signing certificate
3. Click "Test SAML configuration" — do this BEFORE enabling
4. Save and enable SAML SSO
5. Members must re-authenticate via SSO on their next visit

### Configuring SAML SSO on GHES (Global)

GHES configures SAML at the instance level (not per-org):

1. Management Console > Authentication > SAML
2. Set: Identity provider SSO URL, Issuer, Public certificate
3. Apply configuration: `ghe-config-apply`

### Supported Identity Providers

| IdP | Documentation Available |
|-----|------------------------|
| Okta | Yes (official GitHub docs) |
| Azure Active Directory (Entra ID) | Yes |
| OneLogin | Yes |
| PingFederate | Yes |
| Any SAML 2.0-compliant IdP | Use generic SAML config |

### PAT and SSH Key Authorization for SAML SSO

After enabling SAML SSO:
- Existing PATs and SSH keys must be **authorized for SSO** before they can access org resources
- Users do this in their GitHub settings: Settings > Applications > Authorized OAuth Apps / Personal access tokens
- Tokens not authorized for SSO will receive a `403` error when accessing org resources
- Enterprise owners can see and revoke authorized credentials in enterprise settings

### Key SAML Fields

| Field | What It Is |
|-------|-----------|
| NameID | Unique identifier from IdP; used to link GitHub account to IdP identity |
| ACS URL | Assertion Consumer Service URL — where IdP posts the SAML response (GitHub provides this) |
| Entity ID | GitHub's identifier as a service provider |
| Sign on URL | Where GitHub redirects users to authenticate |
| Certificate | IdP's public certificate to validate signed assertions |

---

## 2.2 SCIM Provisioning

### SAML vs SCIM: Key Distinction

| Feature | SAML | SCIM |
|---------|------|------|
| Purpose | Authentication (who you are) | Provisioning (create/delete accounts) |
| What it handles | Login verification | Account lifecycle management |
| Auto-deprovisioning? | No | Yes |
| Required for team sync? | Yes (must be configured first) | Yes (must also be configured) |

**Without SCIM**: A user removed from the IdP can still log in via GitHub credentials until manually removed.
**With SCIM**: A user removed from the IdP is automatically deprovisioned from GitHub.

### How SCIM Works

1. IdP sends SCIM API calls to GitHub when users are added/removed/modified
2. GitHub creates, updates, or deactivates user accounts accordingly
3. SCIM uses a **SCIM token** (generated in GitHub org settings) for authentication

### Setting Up SCIM

Prerequisites: SAML SSO must already be configured and enabled.

1. Generate a SCIM token: `Org Settings > Authentication security > Generate SCIM token`
2. Copy the token (shown only once)
3. Configure SCIM in the IdP:
   - Set the SCIM base URL: `https://api.github.com/scim/v2/organizations/ORG`
   - Set the authentication: Bearer token (use the SCIM token)
4. Test user provisioning through the IdP

### What SCIM Manages

- **Provision**: Creates a GitHub account + org membership when a user is assigned in the IdP
- **Update**: Syncs attribute changes (name, email)
- **Deprovision**: Removes org membership (and optionally suspends the GitHub account) when user is unassigned in IdP

---

## 2.3 Enterprise Managed Users (EMU)

### What is EMU?

Enterprise Managed Users is a **different GitHub Enterprise Cloud configuration** where GitHub accounts are entirely created and managed by the enterprise's IdP. This is not a setting you toggle on a standard GHEC org — it requires a separate enterprise setup.

### EMU vs Standard GHEC

| Feature | Standard GHEC | Enterprise Managed Users (EMU) |
|---------|--------------|-------------------------------|
| Account creation | User signs up on GitHub.com | IdP creates the account |
| Username | User-chosen | Derived from IdP (format: `username_SHORTCODE`) |
| Personal account | Yes, can have personal repos | No personal account — entirely enterprise-owned |
| Interact with public repos | Yes | No — cannot interact outside the enterprise |
| Sign in without SSO | Yes | No — must use IdP |
| Can fork external repos | Yes | No |
| Visibility to non-enterprise | Public profile visible | Profile hidden from non-enterprise members |

### EMU Restrictions (High Exam Frequency)

EMU users **cannot**:
- Create personal repositories visible outside the enterprise
- Fork external (non-enterprise) repositories
- Interact with (comment, star, fork) public repositories outside the enterprise
- Have a separate personal GitHub.com account
- Access GitHub.com without SSO

EMU users **can**:
- Access all repositories within the enterprise (per normal permissions)
- Have a user profile within the enterprise context
- Use GitHub Codespaces (within enterprise)

### EMU Username Format

`<IdP_username>_<enterprise_shortcode>`

Example: A user `john.doe` in an enterprise with shortcode `acme` becomes `john.doe_acme`.

### Why EMU Exists

EMU provides maximum enterprise control: no personal accounts, no data leakage to personal repos, no outside collaboration. Used by enterprises with strict data governance requirements.

---

## 2.4 LDAP Authentication (GHES Only)

### LDAP on GHES

LDAP (Lightweight Directory Access Protocol) allows GHES to authenticate users against an existing directory service (Active Directory, OpenLDAP, etc.).

**Configuration**: Management Console > Authentication > LDAP

Key fields:
- **Host**: LDAP server hostname
- **Port**: 389 (LDAP) or 636 (LDAPS)
- **Domain bind user/password**: Service account for LDAP queries
- **Search base**: LDAP OU to search for users
- **User login attribute**: Which LDAP attribute maps to username (e.g., `sAMAccountName`, `uid`)

### LDAP Sync

Team memberships can be synchronized from LDAP groups to GitHub teams.

```bash
# Run LDAP synchronization manually
ghe-ldap-sync

# LDAP sync runs automatically on a schedule (configurable)
# Check sync status
ghe-ldap-sync-check
```

### Auth Options on GHES

| Method | GHEC | GHES |
|--------|------|------|
| Built-in (username/password) | No | Yes |
| SAML SSO | Yes (org-level) | Yes (instance-level) |
| LDAP | No | Yes |
| CAS | No | Yes |

---

## 2.5 Personal Access Tokens (PATs)

### Classic PATs vs Fine-Grained PATs

| Feature | Classic PAT | Fine-Grained PAT |
|---------|-------------|-----------------|
| Scope | Account-level (e.g., `repo`, `admin:org`) | Per-resource permissions |
| Repository targeting | All repos or none | Specific repos only |
| Expiration | Optional (can be non-expiring) | Required (max 1 year) |
| Org approval required | No (by default) | Yes (org can require it) |
| GitHub API support | Full | Growing (most APIs supported) |

### Managing PATs at the Enterprise Level

Administrators can:
- **Require expiration**: Force all PATs to have an expiration date
- **Require approval**: Classic PAT or fine-grained PAT requests require org owner approval
- **Revoke PATs**: Enterprise owners can revoke any user's PAT from enterprise settings

Configuration: `Enterprise Settings > Authentication security > Personal access tokens`

### PAT Best Practices for Admins

- Enforce expiration policy (no non-expiring tokens)
- Prefer fine-grained PATs for new integrations
- Require approval for fine-grained PATs for sensitive organizations
- Regularly audit authorized PATs via the API

---

## 2.6 Enforcing Two-Factor Authentication

### 2FA Methods Supported by GitHub

| Method | Security Level | Notes |
|--------|---------------|-------|
| TOTP authenticator app | Good | Google Authenticator, Authy, 1Password |
| SMS (text message) | Low (deprecated) | GitHub is phasing this out |
| Security key (WebAuthn) | Excellent | YubiKey, built-in biometrics |
| GitHub Mobile | Good | Push notifications from GitHub app |

### Enforcing 2FA at the Organization Level

1. `Org Settings > Authentication security > Two-factor authentication`
2. Click "Require two-factor authentication for everyone in this organization"
3. Members without 2FA enabled have a grace period, then are removed from the organization

**Important**: Org owners are not exempt — they must have 2FA enabled too.

**Effect of enforcement**: Users who do not enable 2FA within the grace period are removed from the org (not deleted from GitHub). They can re-join after enabling 2FA.

### Enforcing 2FA at the Enterprise Level

`Enterprise Settings > Authentication security > Require two-factor authentication`

This enforces 2FA across all organizations in the enterprise.

---

## 2.7 SSH Keys, Deploy Keys, and SSH CAs

### SSH Keys (User-Level)

Users add SSH keys to their GitHub account for Git operations. Admins can:
- View all SSH keys for users (via the API)
- Revoke SSH keys
- Require SSH key approval for org access (with SAML SSO)

### Deploy Keys

A deploy key is an SSH key registered to a specific **repository** (not a user). Use for CI/CD automation that needs to clone/push to a single repo.

```bash
# Generate a deploy key pair
ssh-keygen -t ed25519 -C "deploy key for myrepo" -f deploy_key

# Add the public key to the repo:
# Repo Settings > Deploy keys > Add deploy key
# Check "Allow write access" for read-write deploy keys
```

**Limitations**: One deploy key cannot access multiple repositories. Use a machine user or GitHub App for multi-repo access.

### SSH Certificate Authorities (CAs)

Organizations can register an SSH CA. Members can then authenticate using SSH certificates signed by the CA, without registering individual SSH keys.

Benefits:
- Certificates can have expiration dates
- Centralized issuance and revocation
- No need for users to register keys individually

Configuration: `Org Settings > Security > SSH certificate authorities > New CA`

---

## 2.8 OAuth Apps vs GitHub Apps

### Comparison

| Feature | OAuth App | GitHub App |
|---------|-----------|------------|
| Acts as | A user (on behalf of) | Its own identity |
| Permissions | Scopes (broad, e.g., `repo`) | Fine-grained per permission |
| Installation | User or org | Org or specific repos |
| Rate limits | User's rate limit | Higher, separate rate limit |
| Webhooks | No native webhook subscription | Yes |
| Best for | User-facing apps | Server-to-server integrations |

### Admin Controls for OAuth Apps

- **Require approval**: `Org Settings > Third-party application access policy > Require approval for OAuth apps`
- Owners must approve each OAuth app before members can use it
- Approved apps can be revoked at any time

### Admin Controls for GitHub Apps

- Admins can restrict which GitHub Apps can be installed in the org
- Configure: `Org Settings > GitHub Apps`
- Enterprise owners can set policies for GitHub App installation across all orgs

### Exam Tip

OAuth Apps are the older model. GitHub Apps are the preferred modern approach. If a question asks which is "more secure" or "more granular," the answer is **GitHub Apps**.

---

## Common Admin Tasks

### View and Revoke SAML-Linked Identities

```bash
# List SAML SSO identities for an org
gh api orgs/ORG/members --jq '.[].login'

# View linked SAML identity for a specific user
gh api orgs/ORG/credential-authorizations

# Revoke a user's SAML SSO authorization
gh api -X DELETE orgs/ORG/credential-authorizations/CREDENTIAL_ID
```

### List All PATs Authorized for an Org

```bash
# Enterprise-level token audit
gh api enterprises/ENTERPRISE/credential-authorizations
```

---

## Gotchas and Exam Tips

1. **SAML alone does not deprovision users**. SAML handles login only. Without SCIM, a user removed from the IdP still has a GitHub account until manually removed.

2. **SCIM requires SAML**. You cannot configure SCIM without first having SAML SSO enabled for the organization.

3. **PAT authorization for SAML orgs**. After SAML SSO is enabled on an org, all existing PATs must be re-authorized for SSO. This is a step users forget, and it causes "403 Forbidden" errors.

4. **EMU is a separate enterprise setup**. You cannot convert a standard GHEC enterprise to EMU by toggling a setting. It requires a new enterprise with the EMU flag set at provisioning time.

5. **SSH CAs are org-level, not enterprise-level**. Each org manages its own SSH CA.

6. **Fine-grained PATs require expiration**. Unlike classic PATs, fine-grained PATs cannot be created without an expiration date. Maximum lifetime is 1 year.

7. **2FA enforcement removes members without 2FA**. When an org enforces 2FA, members who don't enable it within the grace period are removed from the org — they are not suspended or deleted from GitHub.

8. **Deploy keys are repo-scoped, not user-scoped**. A deploy key does not belong to a GitHub user account.

---

## Practice Questions

### Question 1
**Domain**: Domain 2 — Identity & Authentication
**Topic**: SAML vs SCIM
**Difficulty**: Intermediate

An organization uses SAML SSO for authentication. A security administrator needs to ensure that when an employee leaves the company and is deactivated in Okta, their GitHub access is automatically revoked. What additional configuration is required?

A. Configure GitHub's "Automatic user suspension" setting in enterprise settings
B. Configure SCIM provisioning in Okta to sync with GitHub
C. Enable "Require SAML SSO" at the organization level
D. Create a GitHub Actions workflow that polls Okta for deactivated users

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: SAML SSO handles authentication (verifying who a user is when they log in) but does NOT automatically deprovision users. When a user is deactivated in the IdP, they can still access GitHub using their existing GitHub credentials unless SCIM is configured. **SCIM (System for Cross-domain Identity Management)** is the protocol that enables automatic provisioning and deprovisioning. When SCIM is configured in Okta, deactivating a user in Okta triggers a SCIM API call to GitHub, which removes the user's org membership. Option A does not exist as described. Option C only affects login behavior, not deprovisioning. Option D is an anti-pattern that would introduce fragility and delay.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/organizations/managing-saml-single-sign-on-for-your-organization/about-scim-for-organizations

</details>

---

### Question 2
**Domain**: Domain 2 — Identity & Authentication
**Topic**: EMU restrictions
**Difficulty**: Intermediate

A company uses GitHub Enterprise Cloud with Enterprise Managed Users (EMU). A developer wants to contribute to an open-source project hosted on a public GitHub repository outside the enterprise. What should the developer do?

A. Fork the public repository to a personal repository within the enterprise
B. Request that an enterprise owner grant permission to interact with external repos
C. Create a separate personal GitHub.com account for open-source contributions
D. This is not possible — EMU users cannot interact with repositories outside the enterprise

<details>
<summary>Answer</summary>

**Correct Answer: D**

**Explanation**: Enterprise Managed Users (EMU) are designed to provide maximum enterprise control by restricting users entirely to the enterprise's resources. EMU users **cannot** interact with repositories outside the enterprise — this includes forking, starring, commenting on, or contributing to public repositories on GitHub.com. Option C is also incorrect — EMU users cannot have a separate personal GitHub.com account (this would defeat the purpose of EMU's isolation). If the company needs employees to contribute to open source, EMU may not be the right model, or they should use a standard GHEC enterprise instead.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/admin/identity-and-access-management/using-enterprise-managed-users-for-iam/about-enterprise-managed-users

</details>

---

### Question 3
**Domain**: Domain 2 — Identity & Authentication
**Topic**: SAML PAT authorization
**Difficulty**: Intermediate

An organization has just enabled SAML SSO. A developer reports that their existing personal access token (PAT) is now returning 403 errors when accessing the organization's repositories via the API. No changes were made to the developer's GitHub account or repository access. What is the cause?

A. SAML SSO revokes all existing PATs when enabled
B. The PAT needs to be authorized for SAML SSO in the developer's account settings
C. PATs do not work with SAML SSO — only OAuth tokens can be used
D. The organization's base permissions were changed when SAML SSO was enabled

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: When an organization enables SAML SSO, existing personal access tokens must be **explicitly authorized for SAML SSO** before they can access that organization's resources. Users do this at: GitHub Settings > Applications > Authorized OAuth Apps, then find their token and click "Authorize" next to the SSO organization. Option A is incorrect — SAML SSO does not delete existing PATs, but it does block unauthorized ones. Option C is incorrect — PATs do work with SAML SSO once authorized. Option D is incorrect — base permissions are not changed by enabling SAML SSO.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/authentication/authenticating-with-saml-single-sign-on/authorizing-a-personal-access-token-for-use-with-saml-single-sign-on

</details>

---

### Question 4
**Domain**: Domain 2 — Identity & Authentication
**Topic**: GitHub Apps vs OAuth Apps
**Difficulty**: Beginner

A developer is building a GitHub integration that needs to create issues in multiple repositories, manage webhooks, and act with its own identity (not as a user). Which authentication mechanism should the developer use?

A. A classic personal access token with `repo` scope
B. An OAuth App
C. A GitHub App
D. A fine-grained personal access token

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: **GitHub Apps** are the correct choice when an integration needs to act with its own identity (not as a specific user), manage webhooks natively, and have fine-grained permissions. GitHub Apps have their own rate limits (not shared with users), can be installed at the org or repo level, and use a more secure authentication flow (installation access tokens vs OAuth tokens). OAuth Apps (option B) act as a user via OAuth scopes and do not have their own identity. Classic PATs and fine-grained PATs are user credentials — they act as the user, not as an application identity.

**Reference**: https://docs.github.com/en/developers/apps/getting-started-with-apps/differences-between-github-apps-and-oauth-apps

</details>

---

### Question 5
**Domain**: Domain 2 — Identity & Authentication
**Topic**: 2FA enforcement
**Difficulty**: Intermediate

An organization owner enables the "Require two-factor authentication" setting for their organization. There are 50 organization members, 10 of whom do not have 2FA enabled. What happens to those 10 members?

A. Their accounts are permanently deleted from GitHub
B. They are suspended from GitHub until they enable 2FA
C. They are removed from the organization but their GitHub accounts remain
D. They receive an email warning but retain organization access for 30 days

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: When an organization enforces 2FA, members who do not have 2FA enabled are **removed from the organization**. Their GitHub accounts are NOT deleted or suspended — they simply lose organization membership. Once they enable 2FA, they can request to rejoin the organization. Option A is incorrect — account deletion is not triggered by 2FA enforcement. Option B is incorrect — "suspended" is an enterprise account state, not triggered by 2FA enforcement at the org level. Option D is incorrect — there is no 30-day grace period described in the enforcement behavior (a warning may be shown, but non-compliant members are removed when enforcement is activated).

**Reference**: https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-two-factor-authentication-for-your-organization/requiring-two-factor-authentication-in-your-organization

</details>

---

## Official Documentation Links

- [About SAML for GHEC](https://docs.github.com/en/enterprise-cloud@latest/organizations/managing-saml-single-sign-on-for-your-organization/about-identity-and-access-management-with-saml-single-sign-on)
- [SCIM for Organizations](https://docs.github.com/en/enterprise-cloud@latest/organizations/managing-saml-single-sign-on-for-your-organization/about-scim-for-organizations)
- [About Enterprise Managed Users](https://docs.github.com/en/enterprise-cloud@latest/admin/identity-and-access-management/using-enterprise-managed-users-for-iam/about-enterprise-managed-users)
- [About LDAP for GHES](https://docs.github.com/en/enterprise-server@latest/admin/identity-and-access-management/using-ldap-for-enterprise-iam/using-ldap)
- [Managing Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [Requiring 2FA](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-two-factor-authentication-for-your-organization/requiring-two-factor-authentication-in-your-organization)
- [GitHub Apps vs OAuth Apps](https://docs.github.com/en/developers/apps/getting-started-with-apps/differences-between-github-apps-and-oauth-apps)
