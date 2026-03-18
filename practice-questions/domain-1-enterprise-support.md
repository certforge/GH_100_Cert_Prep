# Domain 1 Practice Questions

### Question 1
**Domain**: Domain 1 — Support GitHub Enterprise for users and key stakeholders  
**Topic**: Support escalation  
**Difficulty**: Intermediate

A GHES production instance is unavailable after a storage incident. The enterprise has standard GitHub Support only. The admin needs the fastest possible response from GitHub. What is the best recommendation?

A. Open a Community Discussion because GHES is self-hosted  
B. Open a standard support ticket and expect a 30-minute urgent SLA  
C. Upgrade to a premium support tier if the business requires faster urgent-response SLAs  
D. Wait for the status page to confirm whether GHES is down globally

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: Standard GitHub Support does not provide the same urgent-response SLA as Premium Support or Premium Plus. If the business needs faster time-to-response for production outages, a premium tier is the right operational control.
</details>

### Question 2
**Domain**: Domain 1 — Support GitHub Enterprise for users and key stakeholders  
**Topic**: Audit log retention  
**Difficulty**: Intermediate

An enterprise must retain audit events for two years. Which GitHub-native feature is designed for this requirement?

A. Increase audit log retention in the UI to 730 days  
B. Configure audit log streaming to an external destination  
C. Export CSV reports from the License page weekly  
D. Use webhook delivery logs as a long-term audit system

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: UI and API retention are limited. Long-term retention is achieved by streaming audit logs to external storage or SIEM systems such as S3, Azure Blob, Splunk, Datadog, or GCS.
</details>

### Question 3
**Domain**: Domain 1 — Support GitHub Enterprise for users and key stakeholders  
**Topic**: GitHub status and communications  
**Difficulty**: Beginner

Multiple teams report failed pushes at the same time. What should an admin check first?

A. The organization's webhook history  
B. `status.github.com`  
C. The CODEOWNERS file in each repository  
D. The Actions billing dashboard

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: When the same symptom appears across multiple teams, first validate whether GitHub is experiencing a platform incident. The GitHub Status page is the correct first check.
</details>
