# Domain 5 Practice Questions

### Question 1
**Domain**: Domain 5 — Enable secure software development and ensure compliance  
**Topic**: GHAS licensing  
**Difficulty**: Beginner

An enterprise wants code scanning, secret scanning, and dependency review on private repositories. What is required?

A. No additional license because the repositories are private  
B. A GHAS license for private and internal repositories  
C. Only CodeQL licensing  
D. GitHub Packages billing only

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: GHAS is required for private and internal repositories for these features, while public GitHub.com repositories receive those capabilities without separate GHAS licensing.
</details>

### Question 2
**Domain**: Domain 5 — Enable secure software development and ensure compliance  
**Topic**: Push protection  
**Difficulty**: Intermediate

Push protection is enabled enterprise-wide. A developer needs to push a fake credential used in tests. What is the expected flow?

A. The push is permanently blocked with no exception path  
B. The user can bypass with a reason, and the event is logged  
C. GitHub automatically revokes the fake credential  
D. The user must disable secret scanning at the repository level

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Push protection is designed to prevent accidental leaks while still allowing controlled bypass with justification. Those bypasses are auditable.
</details>

### Question 3
**Domain**: Domain 5 — Enable secure software development and ensure compliance  
**Topic**: Dependency review  
**Difficulty**: Intermediate

A team wants pull requests to fail if they introduce a high-severity vulnerable package. Which implementation is correct?

A. Enable only Dependabot version updates  
B. Add the dependency-review action and require its check  
C. Enable only audit log streaming  
D. Use CODEOWNERS for dependency files

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Dependency review evaluates dependency changes in pull requests. To enforce it, add the action and make its resulting check required.
</details>
