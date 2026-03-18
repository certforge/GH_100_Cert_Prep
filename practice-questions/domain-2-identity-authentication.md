# Domain 2 Practice Questions

### Question 1
**Domain**: Domain 2 — Manage user identities and GitHub authentication  
**Topic**: SAML and SCIM  
**Difficulty**: Intermediate

An organization wants users to authenticate with the IdP and also be automatically removed from GitHub when they leave the company. Which configuration is required?

A. SAML SSO only  
B. SCIM only  
C. SAML SSO plus SCIM provisioning  
D. OAuth App approval

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: SAML handles authentication, while SCIM handles provisioning and deprovisioning. Both are needed when access must be automatically revoked after offboarding.
</details>

### Question 2
**Domain**: Domain 2 — Manage user identities and GitHub authentication  
**Topic**: Enterprise Managed Users  
**Difficulty**: Intermediate

A developer in an EMU enterprise wants to contribute to a public repository outside the enterprise. What is the expected behavior?

A. Allowed if the repo is public  
B. Allowed if they create a fine-grained PAT  
C. Allowed if they authenticate with SSH  
D. Not allowed because EMU identities are restricted to enterprise resources

<details>
<summary>Answer</summary>

**Correct Answer: D**

**Explanation**: EMU accounts are enterprise-controlled identities and cannot interact with resources outside the enterprise boundary.
</details>

### Question 3
**Domain**: Domain 2 — Manage user identities and GitHub authentication  
**Topic**: PATs under SAML  
**Difficulty**: Beginner

After SAML SSO is enabled, a developer's existing PAT starts returning 403 errors for organization resources. What should the developer do?

A. Regenerate the PAT as an OAuth token  
B. Authorize the PAT for SSO access  
C. Disable fine-grained permissions  
D. Add the token to organization secrets

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Existing PATs must be explicitly authorized for organizations protected by SAML SSO before they can access those resources.
</details>
