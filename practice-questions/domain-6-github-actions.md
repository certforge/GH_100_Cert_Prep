# Domain 6 Practice Questions

### Question 1
**Domain**: Domain 6 — Manage GitHub Actions  
**Topic**: Self-hosted runner security  
**Difficulty**: Intermediate

A public repository must use self-hosted runners. Which control most directly reduces the risk of one malicious job contaminating later jobs?

A. Use larger runners  
B. Use ephemeral self-hosted runners  
C. Increase artifact retention  
D. Store credentials in repository secrets

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Ephemeral runners start fresh and are discarded after a job, reducing persistence and contamination risk on public workloads.
</details>

### Question 2
**Domain**: Domain 6 — Manage GitHub Actions  
**Topic**: OIDC  
**Difficulty**: Intermediate

A workflow must authenticate to AWS without long-lived cloud credentials. What is required inside the workflow?

A. `permissions: packages: write`  
B. `permissions: id-token: write`  
C. `permissions: issues: write`  
D. `permissions: contents: write`

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: OIDC requires the workflow to request an ID token. That is enabled with `id-token: write`.
</details>

### Question 3
**Domain**: Domain 6 — Manage GitHub Actions  
**Topic**: Runner groups  
**Difficulty**: Beginner

An enterprise has a small set of high-trust runners that only one organization should use. What is the best administrative control?

A. Assign a custom label only  
B. Create an enterprise runner group and limit it to that organization  
C. Put the runners in the default group  
D. Store the runner token in an environment secret

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Enterprise runner groups are the correct boundary for controlling which organizations can consume a shared runner pool.
</details>
