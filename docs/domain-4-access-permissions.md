# Domain 4 — Manage Access and Permissions Based on Membership

**Exam Weight: 18%**
**Approximate Questions: 14-18**
**Priority: High**

---

## Domain Overview

Domain 4 is about GitHub's layered permission model — from the individual repository level up through organizations and the enterprise. This domain has a high question count (18%) and tests your ability to apply the right permission model to specific scenarios.

The key skill tested: given a business requirement ("developers in Team A need write access to Repo X but read-only access to Repo Y"), identify the correct GitHub constructs to implement it.

This domain also covers **rulesets** (the newer, more powerful replacement for branch protection rules) and **CODEOWNERS** as governance mechanisms.

---

## Key Concepts

- **Repository roles** — 5 standard levels per repo
- **Organization roles** — owner, member, billing manager, security manager
- **Enterprise roles** — enterprise owner, billing manager
- **Base permissions** — org-level floor for all members
- **Teams and team hierarchy** — nested teams, team sync
- **Repository visibility** — public, private, internal
- **CODEOWNERS** — file-based code ownership and review assignment
- **Branch protection rules** — classic per-branch governance
- **Repository rulesets** — modern, flexible, multi-level governance
- **Outside collaborators** — non-member repository access
- **Enterprise policies** — enterprise-wide policy overrides

---

## 4.1 Repository Roles

### The Five Standard Roles

| Role | Read | Clone | Create Issues | Push Non-Protected | Manage Branch Protections | Delete Repo |
|------|------|-------|--------------|---------------------|--------------------------|-------------|
| Read | Yes | Yes | Yes | No | No | No |
| Triage | Yes | Yes | Yes | No | No | No |
| Write | Yes | Yes | Yes | Yes | No | No |
| Maintain | Yes | Yes | Yes | Yes | Yes | No |
| Admin | Yes | Yes | Yes | Yes | Yes | Yes |

### Triage Role — Key Capabilities

The Triage role is often overlooked. Triage users can:
- Read code and clone repositories
- Create, comment, close, and reopen issues and pull requests
- Apply labels and milestones
- Request reviewers on PRs
- Mark issues as duplicates

Triage users CANNOT:
- Push code
- Manage branch protections
- Merge pull requests

**Use case**: QA engineers, product managers, issue triagers who need to manage the issue tracker but should not push code.

### Maintain Role — Key Capabilities

Maintain users can:
- Everything Write users can do
- Manage non-protected branch settings
- Create releases and tags
- Manage GitHub Pages settings
- Manage repository topics and description
- Manage webhooks and deploy keys

Maintain users CANNOT:
- Delete the repository
- Change repository visibility
- Transfer the repository

**Use case**: Team leads who own a repository's operational settings but should not have full admin rights.

### Custom Repository Roles (Enterprise Feature)

On GHEC and GHES, enterprise and organization owners can create custom repository roles by:
1. Starting from one of the 5 base roles
2. Adding additional permissions on top

Example: "Security Reviewer" = Read base + ability to view/dismiss security alerts

Configure at: `Org Settings > Repository roles > New role`

---

## 4.2 Organization Roles

### Standard Organization Roles

| Role | Repository Access | Member Management | Billing | Security Alerts |
|------|------------------|------------------|---------|----------------|
| Owner | Via team/direct assignment | Full | Full | Full |
| Member | Via base permissions + team assignments | Limited | No | No |
| Billing Manager | None | None | Full | No |
| Security Manager | Read to all repos | None | No | Full |
| Outside Collaborator | Specific repos only | None | No | No |

### Organization Owner

The highest privilege in an organization. Can:
- Delete the organization
- Manage all settings (webhooks, integrations, authentication)
- Add/remove all members and teams
- Override any repository admin setting
- Enable/disable GHAS features for the org
- Transfer repositories to/from the org

**Best practice**: Have 2-3 organization owners minimum (for redundancy), but not too many.

### Security Manager Role

A non-owner role that grants org-wide security visibility:
- Read access to all repositories (ignores base permissions for this purpose)
- Manage Dependabot, code scanning, and secret scanning alerts for all repos
- Receive security alert notifications
- Cannot push code, manage members, or change settings

**Use case**: A dedicated security team that needs to review and manage alerts across all repos without being full org owners.

Assign the role: `Org Settings > Member privileges > Security managers`

---

## 4.3 Base Permissions

### What Are Base Permissions?

Base permissions define the **minimum access level** every organization member has to every organization-owned repository.

| Base Permission Level | What It Grants |
|----------------------|---------------|
| None | Members have no access to private/internal repos unless explicitly granted |
| Read | Members can view and clone all org repos |
| Write | Members can push to all org repos |
| Admin | Members have admin rights to all org repos |

**Default**: Read (most enterprises set this and manage access via teams)

### How Base Permissions Interact with Other Permissions

The **highest** permission level always wins. If a user has:
- Base permission: Read
- Team permission: Write to Repo A
- Direct permission: Maintain for Repo B

Their effective access is:
- Repo A: Write (team overrides base)
- Repo B: Maintain (direct permission overrides base)
- All other repos: Read (base permission applies)

### Common Pattern for Enterprise Base Permissions

Most enterprises set base permissions to **None** and then grant access only via teams. This provides least-privilege by default and prevents accidental access to repositories teams shouldn't see.

---

## 4.4 Teams and Team Hierarchy

### Team Basics

- Teams group organization members for permission management and mentions
- A team can be granted a role (Read, Triage, Write, Maintain, Admin) on any repository
- Team members inherit all team repository permissions

### Nested Teams (Parent/Child)

Teams support a parent-child hierarchy:
- A child team **inherits** all parent team repository permissions
- Child team members are also visible as parent team members
- Notifications sent to a parent team reach all child team members

Example hierarchy:
```
Engineering (parent)
├── Frontend (child - inherits Engineering's repo access)
│   ├── React-Team (grandchild - inherits Frontend's access)
│   └── Vue-Team (grandchild)
└── Backend (child)
    ├── API-Team (grandchild)
    └── DB-Team (grandchild)
```

### Team Sync with IdP Groups

When SAML SSO + SCIM is configured, GitHub teams can be synchronized with IdP groups:
- Adding a user to an IdP group automatically adds them to the GitHub team
- Removing a user from an IdP group automatically removes them from the GitHub team
- Team membership becomes a function of IdP group membership

Configuration:
1. SAML SSO must be enabled for the org
2. SCIM provisioning must be configured
3. Create the team and connect it to the IdP group: `Team Settings > Team sync`

### Team Maintainers

Each team has **maintainers** who can:
- Add/remove team members
- Edit team settings (name, description, visibility)
- Manage child teams

Team maintainers do not need to be organization owners.

---

## 4.5 Repository Visibility

### The Three Visibility Levels

| Visibility | Who Can See | When Available |
|------------|------------|---------------|
| Public | Everyone on the internet | All plans |
| Private | Repo owner + explicit collaborators/teams | All plans |
| Internal | All members of the enterprise | GHEC and GHES only |

### Internal Repositories

Internal repositories are GitHub's "inner source" feature:
- Any enterprise member can see and clone internal repos (without explicit permission)
- Cannot be seen by external users or non-enterprise members
- Forks of internal repos stay within the enterprise (enforced by fork policy)

**Key use case**: Share internal tooling, frameworks, or documentation across all teams in the enterprise without making it fully public.

### Repository Visibility Change Policies

Enterprise owners can control:
- Whether org owners can change repository visibility
- Whether members can change repository visibility
- The default visibility for new repositories

Configure: `Enterprise Settings > Policies > Repository policies`

### Fork Policies

Forks of private and internal repositories can be restricted at the organization level:
- Disable forks entirely for private repos
- Restrict forks to only within the organization or enterprise

Configure: `Org Settings > Member privileges > Fork policy`

---

## 4.6 Branch Protection Rules (Classic)

### Overview

Branch protection rules define how branches behave — whether PRs are required, what checks must pass, who can push. "Classic" refers to the pre-ruleset system, which still works and is widely used.

Applied to: a specific branch name or a name pattern (e.g., `main`, `release/*`, `v[0-9]+`)

### All Branch Protection Rule Settings

| Setting | What It Does |
|---------|-------------|
| Require a pull request before merging | No direct pushes; PRs required |
| Require approvals (N) | PR needs N approvals to merge |
| Dismiss stale pull request approvals | Re-request review if new commits pushed |
| Require review from code owners | CODEOWNERS must approve files they own |
| Require status checks to pass | Listed checks must succeed |
| Require branches to be up to date | Branch must be up to date with base before merge |
| Require conversation resolution before merging | All PR comments must be resolved |
| Require signed commits | Commits must be GPG or SSH signed |
| Require linear history | No merge commits — squash or rebase only |
| Require deployments to succeed | Specific environments must deploy successfully |
| Lock branch | Make branch read-only |
| Do not allow bypassing the above settings | Admins also subject to rules |
| Restrict who can push to matching branches | Only specific users/teams can push |
| Allow force pushes | Override default no-force-push behavior |
| Allow deletions | Allow branch deletion despite protection |

### The "Include Administrators" / Bypass Setting

By default, repository admins can bypass branch protection rules. The "Do not allow bypassing the above settings" checkbox removes this bypass — even admins must follow the rules.

For rulesets, this is handled via **bypass actors** configuration.

---

## 4.7 Repository Rulesets

### What Are Rulesets?

Repository rulesets are GitHub's newer, more powerful approach to branch governance. They can be applied at the repository, organization, or enterprise level and support more rule types than classic branch protection rules.

### Rulesets vs Classic Branch Protection Rules

| Feature | Branch Protection Rules | Repository Rulesets |
|---------|------------------------|---------------------|
| Scope | Repository only | Repository, organization, enterprise |
| Bypass configuration | Admins can bypass by default | Explicit bypass actors required |
| Multiple rules on same branch | One rule per branch pattern | Multiple rulesets can stack |
| Tag protection | No | Yes |
| Commit message enforcement | No | Yes |
| File path restrictions | No | Yes |
| File size limits | No | Yes |
| Required workflows | No | Yes |
| History | No | Yes (bypass history, rule evaluation logs) |
| Status | Active (on/off only) | Active / Evaluate (dry run) / Disabled |

### Ruleset Rule Types

| Rule Category | Specific Rules |
|---------------|---------------|
| Branch targeting | Target branches by name, pattern, or default branch |
| Tag targeting | Target tags by name or pattern |
| Commit restrictions | Require signed commits, linear history |
| PR requirements | Required approvals, code owner review, dismiss stale reviews, conversation resolution |
| Status checks | Required status check names, required to be up to date |
| Deployments | Required deployment environments |
| Metadata | Commit message pattern, branch name pattern, tag name pattern |
| File restrictions | File path restriction, file extension restriction, file size limit |
| Workflows | Required workflows (specify org + repo + workflow file) |
| Code scanning | Required code scanning results (tool + severity thresholds) |

### Bypass Actors

Bypass actors are roles, teams, or apps that can bypass a ruleset:
- Organization owners
- Repository admins
- Specific teams
- Specific GitHub Apps (e.g., your CI bot)
- Repository roles (e.g., all Maintain-level users)

Configure at the ruleset level. Bypass history is logged.

### Enterprise-Level Rulesets

Enterprise owners can create rulesets that apply to **all repositories in all organizations** in the enterprise. This is the most powerful governance tool for enforcing standards at scale.

Example: An enterprise ruleset requiring signed commits on `main` across all repos.

---

## 4.8 CODEOWNERS

### What Is CODEOWNERS?

CODEOWNERS is a file that defines which individuals or teams are **automatically requested as reviewers** when a pull request modifies files they own.

### File Locations (In Priority Order)

1. `.github/CODEOWNERS`
2. `CODEOWNERS` (root directory)
3. `docs/CODEOWNERS`

The first file found is used. Only one CODEOWNERS file per repository is active.

### CODEOWNERS Syntax

```gitignore
# This is a comment

# Global owner — applies to everything not matched by a more specific rule
*       @global-owner

# All Python files
*.py    @python-team

# The docs directory and all its files
/docs/  @docs-team

# Specific files
/scripts/deploy.sh   @devops-team @senior-engineer

# Directories with multiple owners
/src/   @frontend-team @backend-team

# Organization team reference
/config/   @myorg/platform-team

# Most specific pattern wins (last match in file wins)
/src/api/auth/   @security-team
```

**Key Rule**: The last matching pattern in the file takes precedence. Unlike `.gitignore`, the LAST matching rule wins (not the most specific).

### CODEOWNERS + Branch Protection Rules

CODEOWNERS alone does NOT require reviews. To enforce code owner reviews:

1. Create or edit a branch protection rule for `main`
2. Enable "Require a pull request before merging"
3. Enable "Require review from Code Owners"

Now any PR touching a file owned by a team/person will require that owner's approval.

### CODEOWNERS for Monorepos

```gitignore
# Monorepo CODEOWNERS example
/services/auth/         @auth-team
/services/payments/     @payments-team
/services/ui/           @frontend-team
/infrastructure/        @platform-team
/docs/                  @tech-writers @all-team-leads
/CODEOWNERS             @platform-team   # Only platform can edit this file
```

---

## 4.9 Outside Collaborators

### What Are Outside Collaborators?

Users who have access to one or more repositories in an organization but are NOT organization members.

Differences from org members:
- Do not inherit base permissions (get only what is explicitly granted per repo)
- Cannot be added to teams
- Do not see private organizational information
- Cannot create repositories in the org

### Managing Outside Collaborators

Add via: `Repo Settings > Collaborators and teams > Add people`
View org-wide: `Org Settings > People > Outside collaborators`

### Enterprise Policy for Outside Collaborators

Enterprise owners can set policies controlling whether org owners can add outside collaborators to private repositories.

Configure: `Enterprise Settings > Policies > Repository policies > Forking and external collaborators`

---

## 4.10 Enterprise-Level Policies

Enterprise policies override organization-level settings. Enterprise owners set these guardrails.

### Key Enterprise Policies

| Policy | Options |
|--------|---------|
| Default repository visibility | Public / Private / Internal |
| Repository creation | All members / Owners only / No members |
| Repository deletion | All admins / Owners only / No members |
| Repository transfer | All admins / Owners only / No members |
| Fork policy | Allow / Restrict to org / Restrict to enterprise / Disabled |
| Actions policy | Enabled for all / Disabled / Selected organizations |
| OAuth App policy | No policy / All allowed / Specific apps |
| Members can invite outside collaborators | Allow / Restrict to owners |
| Members can change repo visibility | Allow / Restrict to owners |

---

## Common Admin Tasks

### Setting Up Least-Privilege Access for a New Team

```bash
# 1. Create the team via API
gh api orgs/ORG/teams -X POST \
  -f name="backend-api-team" \
  -f description="Backend API developers" \
  -f privacy="closed"

# 2. Grant team access to specific repo
gh api orgs/ORG/teams/TEAM_SLUG/repos/ORG/REPO_NAME -X PUT \
  -f permission="write"

# 3. Add team members
gh api orgs/ORG/teams/TEAM_SLUG/memberships/USERNAME -X PUT \
  -f role="member"
```

### Reviewing All Repository Access for a User

```bash
# List all repos a user can access in an org
gh api orgs/ORG/members/USERNAME --jq '.login'
# Then check team memberships
gh api orgs/ORG/teams --jq '.[].slug' | xargs -I {} \
  gh api orgs/ORG/teams/{}/members --jq '.[].login' | grep USERNAME
```

### Creating a Repository Ruleset via API

```bash
gh api repos/ORG/REPO/rulesets -X POST \
  --input - <<'EOF'
{
  "name": "protect-main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "required_pull_request",
      "parameters": { "required_approving_review_count": 2 } },
    { "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "required_status_checks": [{ "context": "ci/test" }]
      }
    }
  ]
}
EOF
```

---

## Gotchas and Exam Tips

1. **The highest permission always wins**. If base permissions = Write and a team grants Read, the user still has Write (not Read). You cannot use a team to restrict below the base permission level.

2. **CODEOWNERS last-match rule**. The LAST matching pattern in CODEOWNERS wins, not the most specific. This is the opposite of most people's intuition.

3. **Triage cannot push code**. The Triage role is only about issue/PR management. Triage users cannot push to branches.

4. **Security Manager is an org role, not a repo role**. It grants read access to all repos org-wide plus security management. It's a separate concept from repository roles.

5. **Inside collaborator vs outside collaborator**: "Inside collaborator" is not an official GitHub term. The distinction is member vs outside collaborator.

6. **Internal repos require GHEC or GHES**. The internal visibility level does not exist on GitHub.com Free or Team plans.

7. **Base permissions apply to private repos only**. Public repos are readable by everyone regardless of base permissions.

8. **Enterprise rulesets cascade**. An enterprise ruleset applies to all repos in all orgs. Organization rulesets apply to repos in that org. Repository rulesets apply to that repo only. All applicable rulesets are evaluated — the most restrictive combination applies.

9. **Team sync requires both SAML and SCIM**. Team sync with IdP groups requires both SAML SSO AND SCIM provisioning to be configured. SAML alone does not enable team sync.

---

## Practice Questions

### Question 1
**Domain**: Domain 4 — Access & Permissions
**Topic**: Repository roles
**Difficulty**: Beginner

A QA engineer needs to be able to create, label, and close issues on a repository, as well as request reviewers on pull requests, but should NOT be able to push code. Which repository role should be assigned?

A. Read
B. Triage
C. Write
D. Maintain

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: The **Triage** role is specifically designed for users who manage the issue tracker and pull requests without needing write access to code. Triage users can create issues, apply labels, close/reopen issues, request reviewers on PRs, and manage milestones — but cannot push code. Read (option A) allows viewing and cloning but no issue management beyond commenting. Write (option C) grants all Triage capabilities plus push access — more than needed and violates least-privilege. Maintain (option D) is even broader — this is for team leads.

**Reference**: https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization

</details>

---

### Question 2
**Domain**: Domain 4 — Access & Permissions
**Topic**: Base permissions and team permissions
**Difficulty**: Intermediate

An organization has base permissions set to Read. A developer is a member of Team Alpha, which has Write access to Repository X. What is the developer's effective access level for Repository Y, which Team Alpha has no permissions on?

A. Write (base permissions are elevated by team membership)
B. Read (base permissions apply when no team permission exists)
C. None (team membership restricts access to only team repositories)
D. Admin (developers get admin to repos they are explicitly not in a team for)

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: Base permissions apply to ALL organization-owned repositories for ALL organization members. Since the organization's base permission is Read, every member has at least Read access to every private repository. Team Alpha's Write permission on Repository X does not affect access to Repository Y — the developer's access to Repository Y is governed by the base permission (Read). The highest permission wins: for Repository X, Write (team) > Read (base), so Write. For Repository Y, only base (Read) applies.

**Reference**: https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/setting-base-permissions-for-an-organization

</details>

---

### Question 3
**Domain**: Domain 4 — Access & Permissions
**Topic**: CODEOWNERS
**Difficulty**: Intermediate

A repository's CODEOWNERS file contains the following entries:
```
*           @general-team
*.js        @js-team
/src/auth/  @security-team
```

A pull request modifies `/src/auth/login.js`. Which team(s) will be requested as required reviewers?

A. @general-team only (most general pattern applies)
B. @js-team only (`.js` files are owned by @js-team)
C. @security-team only (the last matching pattern wins)
D. All three teams (all matching patterns apply)

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: In CODEOWNERS, the **last matching pattern in the file wins**. The file path `/src/auth/login.js` matches all three patterns:
- `*` matches everything
- `*.js` matches `.js` files
- `/src/auth/` matches files in that directory

Since `/src/auth/` is the last matching pattern, **@security-team** is the required reviewer. This is a critical CODEOWNERS behavior that many people get wrong — they assume the most specific rule wins (like `.gitignore`), but CODEOWNERS uses last-match-wins. If you want both @js-team and @security-team, you'd need to write `/src/auth/ @security-team @js-team` as the last matching entry.

**Reference**: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

</details>

---

### Question 4
**Domain**: Domain 4 — Access & Permissions
**Topic**: Repository rulesets vs branch protection rules
**Difficulty**: Advanced

An enterprise administrator needs to enforce commit signing on the `main` branch across ALL repositories in ALL organizations in the enterprise. What is the most efficient approach?

A. Create a branch protection rule requiring signed commits in each repository
B. Create an organization-level ruleset requiring signed commits for `main` in each organization
C. Create an enterprise-level ruleset requiring signed commits targeting `main`
D. Use a GitHub Actions required workflow that validates commit signatures

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: **Enterprise-level rulesets** are the most efficient approach because they cascade down to all repositories in all organizations in the enterprise without requiring any configuration in individual repos or orgs. A single enterprise ruleset targeting `refs/heads/main` with the "require signed commits" rule applies everywhere automatically. Option A would require creating rules in hundreds of repositories — not scalable. Option B requires creating a ruleset in every organization — better than A but still requires multiple configurations. Option D (required workflow) could validate signatures but is not a native governance mechanism and adds workflow maintenance overhead.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/admin/policies/enforcing-policies-for-your-enterprise/enforcing-repository-management-policies-in-your-enterprise

</details>

---

### Question 5
**Domain**: Domain 4 — Access & Permissions
**Topic**: Internal repository visibility
**Difficulty**: Beginner

A company uses GitHub Enterprise Cloud and wants to create a repository containing internal tooling code that should be accessible to all employees but not to the general public. What repository visibility should be used?

A. Private
B. Public
C. Internal
D. Protected

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: **Internal** repositories are visible to all members of the enterprise (anyone with a seat in the enterprise account) but are not visible to the general public. This is exactly the "inner source" use case — sharing code across all teams internally. Private (option A) would require explicit access grants to each person or team — not scalable for "all employees." Public (option B) would expose the code to the entire internet. "Protected" (option D) is not a repository visibility level in GitHub.

**Reference**: https://docs.github.com/en/enterprise-cloud@latest/repositories/creating-and-managing-repositories/about-repositories#about-internal-repositories

</details>

---

### Question 6
**Domain**: Domain 4 — Access & Permissions
**Topic**: Security Manager role
**Difficulty**: Intermediate

An organization has a dedicated security engineering team. These engineers need to review and manage Dependabot, code scanning, and secret scanning alerts across ALL repositories in the organization. They should NOT have write access to code or the ability to manage organization members. Which role should they be assigned?

A. Organization Owner
B. Repository Admin on each repository
C. Security Manager (organization role)
D. Write-level access on each repository

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: The **Security Manager** organization role is precisely designed for this scenario. Security Managers get read access to all repositories (for alert context) and full management capabilities for security alerts (Dependabot, code scanning, secret scanning) across the org. They cannot push code, manage members, or change organization settings — exactly the principle of least privilege for a security team. Organization Owner (option A) grants far too many permissions. Repository Admin per repo (option B) would grant too much access (admin can delete repos) and would require configuration in every repository. Write access (option D) grants push access, which is not needed for alert management.

**Reference**: https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization

</details>

---

## Official Documentation Links

- [Repository roles for organizations](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization)
- [Roles in an organization](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/roles-in-an-organization)
- [Setting base permissions](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/setting-base-permissions-for-an-organization)
- [About teams](https://docs.github.com/en/organizations/organizing-members-into-teams/about-teams)
- [About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [Security managers](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)
- [About internal repositories](https://docs.github.com/en/enterprise-cloud@latest/repositories/creating-and-managing-repositories/about-repositories#about-internal-repositories)
