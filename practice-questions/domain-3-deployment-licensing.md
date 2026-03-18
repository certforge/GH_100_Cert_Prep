# Domain 3 Practice Questions

### Question 1
**Domain**: Domain 3 — Describe how GitHub is deployed, distributed, and licensed  
**Topic**: Deployment models  
**Difficulty**: Intermediate

An enterprise requires LDAP, CAS, and full control over data residency inside its own network. Which deployment model best fits?

A. GitHub Free  
B. GitHub Enterprise Cloud  
C. GitHub Enterprise Server  
D. GitHub Team

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: GHES is the self-hosted deployment that supports on-premises control, LDAP, CAS, and maximum data sovereignty.
</details>

### Question 2
**Domain**: Domain 3 — Describe how GitHub is deployed, distributed, and licensed  
**Topic**: High availability  
**Difficulty**: Intermediate

The GHES primary fails. What is the normal failover action?

A. Automatic failover occurs without admin action  
B. Run `ghe-repl-promote` on the replica and repoint traffic  
C. Restore from backup on the primary before users reconnect  
D. Use `ghe-backup` on the primary

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: GHES HA uses a primary-replica model. In a failover event, the admin promotes the replica and updates routing, commonly through DNS or a load balancer.
</details>

### Question 3
**Domain**: Domain 3 — Describe how GitHub is deployed, distributed, and licensed  
**Topic**: Licensing and GitHub Connect  
**Difficulty**: Beginner

What GitHub Connect feature helps avoid double-counting users across GHES and GHEC?

A. Required workflows  
B. License sync  
C. Audit log streaming  
D. Merge queue

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: License sync reconciles seat usage between GHES and GitHub.com when GitHub Connect is enabled.
</details>
