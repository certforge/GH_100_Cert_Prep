# SAML, SCIM, and EMU Decision Table

| Need | Best Fit | Reason |
|------|----------|--------|
| Centralized login only | SAML SSO | Federated authentication |
| Automated provisioning and deprovisioning | SAML + SCIM | Authentication plus lifecycle management |
| Fully enterprise-controlled identities with no outside collaboration | EMU | IdP-created users constrained to enterprise resources |
| GHES directory-backed auth | LDAP or SAML/CAS | Instance-level identity control |
