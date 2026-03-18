# Domain 4 Practice Questions

### Question 1
**Domain**: Domain 4 — Manage access and permissions based on membership  
**Topic**: Base permissions  
**Difficulty**: Intermediate

An organization sets base permissions to `Read`. A user has no team or direct access to Repository Z. What effective access does the user have?

A. No access  
B. Read  
C. Write  
D. Admin

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Base permissions define the minimum access for organization members to organization-owned repositories. With `Read`, the user has read access even without team membership.
</details>

### Question 2
**Domain**: Domain 4 — Manage access and permissions based on membership  
**Topic**: Rulesets  
**Difficulty**: Intermediate

An enterprise wants one policy requiring signed commits on `main` across all organizations and also wants visibility into bypass history. Which feature is the best fit?

A. Classic branch protection only  
B. Repository rulesets at the enterprise level  
C. CODEOWNERS only  
D. Team sync

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Enterprise rulesets support centralized governance, bypass actors, and history/insights that classic branch protection does not provide.
</details>

### Question 3
**Domain**: Domain 4 — Manage access and permissions based on membership  
**Topic**: Outside collaborators  
**Difficulty**: Beginner

Which statement correctly describes an outside collaborator?

A. They are an organization member with restricted billing access  
B. They are not an organization member and are granted access to specific repositories  
C. They automatically inherit base permissions  
D. They can administer teams by default

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Outside collaborators are non-members who receive explicit repository access only. They do not inherit organization-wide base permissions.
</details>
