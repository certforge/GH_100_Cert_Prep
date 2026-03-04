# Demo Lab 02 — Identity and SSO Configuration

**Domain Coverage**: Domain 2 (Identity and Authentication)
**Prerequisites**: GitHub Enterprise Cloud org, Organization owner access, Access to an IdP (Okta trial or Azure AD trial)
**Estimated Time**: 90-120 minutes

---

## Learning Objectives

After completing this lab, you will be able to:
- Configure SAML SSO on a GitHub organization
- Test SAML configuration before enforcing it
- Configure SCIM provisioning for automatic user lifecycle management
- Manage PAT authorization for SAML SSO
- Enforce two-factor authentication
- Distinguish between different authentication methods

---

## Lab Setup

You need one of:
- **Option A**: Okta Developer Account (free at developer.okta.com)
- **Option B**: Azure Active Directory / Entra ID (free tier available)
- **Option C**: Any SAML 2.0-compliant IdP

Plus:
- GitHub Enterprise Cloud organization
- Organization owner access
- At least 2 GitHub test accounts to test SSO behavior

---

## Exercise 1 — Review Current Authentication Settings

### 1.1 Check Current Org Auth Settings

1. Navigate to: `Your Org > Settings > Authentication security`
2. Review the current settings:
   - Is 2FA required?
   - Is SAML SSO enabled?
   - Is there an active SAML provider?

### 1.2 Audit Current Members

1. Navigate to: `Your Org > People`
2. Count the current members and note who does/doesn't have 2FA enabled
3. Look for the "2FA" filter option

---

## Exercise 2 — Set Up SAML SSO with Okta (Option A)

### 2.1 Configure Okta

1. Sign into your Okta Developer account
2. Navigate to **Applications > Applications**
3. Click **Create App Integration**
4. Select: **SAML 2.0** > Click Next
5. App name: `GitHub Organization SSO`
6. In the SAML Settings tab, enter:

   - **Single sign-on URL**: `https://github.com/orgs/YOUR_ORG_NAME/saml/consume`
   - **Audience URI (SP Entity ID)**: `https://github.com/orgs/YOUR_ORG_NAME`
   - **Name ID format**: EmailAddress
   - **Application username**: Email

7. Under "Attribute Statements," add:
   - Name: `displayName` | Value: `user.displayName`
   - Name: `email` | Value: `user.email`

8. Click **Next** and then **Finish**
9. On the app's Sign On tab, click **View SAML setup instructions**
10. Copy:
    - Identity Provider Single Sign-On URL
    - Identity Provider Issuer
    - X.509 Certificate

### 2.2 Configure SAML SSO on GitHub

1. Navigate to: `Org Settings > Authentication security > SAML single sign-on`
2. Check **Enable SAML authentication**
3. Enter the values from Okta:
   - **Sign on URL**: The Okta SSO URL
   - **Issuer**: The Okta Entity ID / Issuer
   - **Public certificate**: The X.509 certificate (paste the full cert including `-----BEGIN CERTIFICATE-----`)
4. Click **Test SAML configuration**

**Critical step**: Test BEFORE saving. A failed test means your IdP settings don't match GitHub's expectations.

5. If the test succeeds, click **Save**

### 2.3 Assign Users in Okta

1. In Okta, go to your GitHub app
2. Navigate to the **Assignments** tab
3. Click **Assign > Assign to People**
4. Assign your test user accounts

---

## Exercise 3 — Set Up SAML SSO with Azure AD / Entra ID (Option B)

### 3.1 Create Enterprise Application in Azure AD

1. Sign into the Azure Portal (portal.azure.com)
2. Navigate to **Azure Active Directory** (or **Microsoft Entra ID**)
3. Click **Enterprise applications > New application**
4. Search for **GitHub** in the gallery
5. Select the **GitHub Enterprise Cloud - Organization** app template
6. Name it and click **Create**

### 3.2 Configure SSO

1. In the app, click **Set up single sign on > SAML**
2. Click **Edit** on **Basic SAML Configuration**
3. Set:
   - **Identifier (Entity ID)**: `https://github.com/orgs/YOUR_ORG_NAME`
   - **Reply URL**: `https://github.com/orgs/YOUR_ORG_NAME/saml/consume`
   - **Sign on URL**: `https://github.com/orgs/YOUR_ORG_NAME/sso`
4. Download the **Certificate (Base64)** and the **Federation Metadata XML**
5. Copy the **Login URL** and **Azure AD Identifier**

### 3.3 Configure on GitHub

Same as step 2.2 above — use the Azure AD values.

---

## Exercise 4 — Test SSO Authentication

### 4.1 Test as a User

1. In a private/incognito browser window
2. Navigate to: `https://github.com/orgs/YOUR_ORG_NAME/sso`
3. GitHub redirects you to the IdP login page
4. Sign in with your IdP credentials
5. You should be redirected back to GitHub and logged in

### 4.2 Observe the Link Created

After successful SSO:
1. The user's GitHub account is now linked to their IdP identity
2. Check as an org admin: `Org Settings > People` — the user should now show their SSO identity linked

---

## Exercise 5 — PAT Authorization for SAML SSO

### 5.1 Create a Test PAT

1. In a test user's GitHub account: `Settings > Developer settings > Personal access tokens`
2. Create a new classic PAT with `repo` scope
3. Note the token value

### 5.2 Test PAT Without Authorization

```bash
# Try to access the org's repos with the unauth'd PAT
curl -H "Authorization: Bearer YOUR_PAT" \
  https://api.github.com/repos/YOUR_ORG/YOUR_REPO

# Expected response: 403 Forbidden with message about SSO
```

### 5.3 Authorize the PAT for SSO

1. Go to `Settings > Developer settings > Personal access tokens`
2. Find the PAT
3. Click **Configure SSO** next to the token
4. Click **Authorize** next to your organization

### 5.4 Retry the API Call

```bash
# Now try again with the authorized PAT
curl -H "Authorization: Bearer YOUR_PAT" \
  https://api.github.com/repos/YOUR_ORG/YOUR_REPO

# Expected: 200 OK with repository data
```

---

## Exercise 6 — SCIM Provisioning Setup

> Note: Full SCIM testing requires an IdP that supports SCIM and a plan that allows provisioning. This exercise covers the concept and partial setup.

### 6.1 Generate a SCIM Token

1. Navigate to: `Org Settings > Authentication security`
2. Scroll to **SCIM provisioning**
3. Click **Generate new SCIM token**
4. Copy the token (it is shown only once)

### 6.2 Configure SCIM in Okta (if using Okta)

1. In Okta, navigate to your GitHub app
2. Click the **Provisioning** tab
3. Click **Configure API Integration**
4. Enable API integration
5. Enter:
   - API Token: the SCIM token you generated
   - Okta's provisioning endpoint automatically knows GitHub's SCIM URL
6. Test the API credentials
7. Enable provisioning features:
   - Create users (provisions new GitHub accounts)
   - Update user attributes
   - Deactivate users (deprovisioning)

### 6.3 Test Provisioning

1. In Okta, assign a NEW user (one who does not have a GitHub account) to the GitHub app
2. Check the GitHub org after a few minutes
3. The user should automatically appear in the org

### 6.4 Test Deprovisioning

1. In Okta, unassign a user from the GitHub app
2. After a short delay, check the org members list
3. The user should be automatically removed

---

## Exercise 7 — Enforce Two-Factor Authentication

**Warning**: Only do this in a test organization where all members have 2FA enabled, or you have control over all accounts.

### 7.1 Check 2FA Status of All Members

```bash
# List org members without 2FA
gh api orgs/YOUR_ORG/members \
  --jq '.[] | {login: .login}' \
  | head -20
```

Actually, use the UI for a cleaner view:
1. `Org Settings > People`
2. Filter by: **2FA enabled: disabled**
3. Note who doesn't have 2FA

### 7.2 Require 2FA

Only proceed if all members have 2FA:
1. Navigate to: `Org Settings > Authentication security`
2. Check **Require two-factor authentication for everyone in this organization**
3. Confirm the action

**Observe**: Members without 2FA are removed from the org immediately.

---

## Exercise 8 — Explore Fine-Grained PATs

### 8.1 Create a Fine-Grained PAT

1. Go to `Settings > Developer settings > Personal access tokens > Fine-grained tokens`
2. Click **Generate new token**
3. Configure:
   - Token name: `lab-fine-grained-token`
   - Expiration: 7 days
   - Resource owner: Your organization (requires owner approval if configured)
   - Repository access: Only select repositories > choose one specific repo
   - Permissions:
     - Issues: Read and write
     - Pull requests: Read only
     - (Leave everything else as "No access")
4. Click **Generate token**

### 8.2 Test Scope Restrictions

```bash
# This should work (issues: read and write)
curl -H "Authorization: Bearer FINE_GRAINED_PAT" \
  https://api.github.com/repos/YOUR_ORG/YOUR_REPO/issues

# This should fail (repository secrets: no access)
curl -H "Authorization: Bearer FINE_GRAINED_PAT" \
  https://api.github.com/repos/YOUR_ORG/YOUR_REPO/actions/secrets
# Expected: 403 Forbidden
```

---

## Lab Checkpoint Questions

1. What is the difference between SAML SSO and SCIM? Why are both needed?
2. If a user is deactivated in Okta but SCIM is not configured, will they lose access to GitHub?
3. After enabling SAML SSO, what must existing PAT users do before their tokens work again?
4. What happens to org members who don't have 2FA when you enforce 2FA — are their accounts deleted?
5. What is the NameID and why does it matter for SAML SSO?
6. Can a user be a member of a GitHub SAML SSO organization without having a personal GitHub account? (Answer: No, unless EMU is used)

---

## Key Takeaways

- SAML = Authentication (who are you); SCIM = Provisioning (create/update/delete accounts)
- Always TEST SAML configuration before enforcing it
- PATs and SSH keys must be authorized for SAML SSO after SSO is enabled
- 2FA enforcement removes non-compliant members — it does not delete accounts
- Fine-grained PATs are more secure: repo-scoped and permission-scoped

---

## Cleanup

1. If you enabled SAML SSO for testing, consider disabling it: `Org Settings > Authentication security > Disable SAML`
2. Delete test PATs: `Settings > Developer settings > Personal access tokens`
3. Remove test SCIM token: `Org Settings > Authentication security > SCIM provisioning > Revoke`
