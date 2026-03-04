# Demo Lab 04 — Access and Permissions Management

**Domain Coverage**: Domain 4 (Access and Permissions)
**Prerequisites**: GitHub organization (owner access), 2-3 test GitHub accounts, Test repository
**Estimated Time**: 90-120 minutes

---

## Learning Objectives

After completing this lab, you will be able to:
- Configure repository roles and observe access differences
- Set up and test organization base permissions
- Create nested teams and configure team permissions
- Create and test CODEOWNERS files
- Configure branch protection rules
- Create repository rulesets
- Manage outside collaborators
- Configure internal repository visibility (GHEC)

---

## Lab Setup

**Required**:
- Your main GitHub account (org owner)
- 2 additional test GitHub accounts (will be org members)
- A test organization you control
- A test repository (create one for this lab)

**Create test accounts** or use existing personal accounts you manage.

```bash
# Install GitHub CLI if not already installed
# macOS:
brew install gh

# Authenticate
gh auth login
```

---

## Exercise 1 — Repository Roles

### 1.1 Create a Test Repository

```bash
# Create a new private test repository
gh repo create YOUR_ORG/access-lab-repo \
  --private \
  --description "Lab repo for testing access and permissions" \
  --add-readme
```

### 1.2 Add Test Users with Different Roles

Add your test accounts with different roles:

```bash
# Add test-user-1 as a Triage member
gh api repos/YOUR_ORG/access-lab-repo/collaborators/TEST_USER_1 -X PUT \
  -f permission="triage"

# Add test-user-2 as a Write member
gh api repos/YOUR_ORG/access-lab-repo/collaborators/TEST_USER_2 -X PUT \
  -f permission="write"
```

### 1.3 Test Access Levels

**As test-user-1 (Triage)**:
- [ ] Can view the repository: YES / NO
- [ ] Can clone the repository: YES / NO
- [ ] Can create an issue: YES / NO
- [ ] Can push a commit: YES / NO (should be NO)
- [ ] Can apply a label: YES / NO

```bash
# Test as test-user-1
gh auth switch --user TEST_USER_1

# Try to push (should fail for Triage)
echo "test" >> README.md
git add README.md
git commit -m "test triage push"
git push
# Expected: error
```

**As test-user-2 (Write)**:
- [ ] Can push a commit: YES / NO (should be YES)
- [ ] Can manage branch protections: YES / NO (should be NO)
- [ ] Can delete the repository: YES / NO (should be NO)

---

## Exercise 2 — Organization Base Permissions

### 2.1 Observe Default Base Permissions

1. Navigate to: `Org Settings > Member privileges > Base permissions`
2. Note the current setting (likely "Read")

### 2.2 Test with Base Permission = "None"

1. Change base permissions to **None**:
   ```
   Org Settings > Member privileges > Base permissions > None > Save
   ```

2. Add a test user as an **org member** (not a direct collaborator):
   ```bash
   gh api orgs/YOUR_ORG/invitations -X POST \
     -f email="TEST_USER_EMAIL" \
     -f role="direct_member"
   ```

3. Have the test user accept the invitation

4. Verify: the test user (as an org member with base=None) cannot see private repos unless explicitly granted

### 2.3 Change Base Permissions to "Read"

1. Change base permissions to **Read**
2. Verify: the same test user can now see (read) all org repos

**Key learning**: Base permissions are the org-wide floor. "None" means explicit grants only.

---

## Exercise 3 — Teams and Team Hierarchy

### 3.1 Create a Parent Team

```bash
# Create parent team "engineering"
gh api orgs/YOUR_ORG/teams -X POST \
  -f name="engineering" \
  -f description="All engineering staff" \
  -f privacy="closed"
```

### 3.2 Create Child Teams

```bash
# Create child team "frontend" under "engineering"
gh api orgs/YOUR_ORG/teams -X POST \
  -f name="frontend" \
  -f description="Frontend engineers" \
  -f privacy="closed" \
  -f parent_team_id=$(gh api orgs/YOUR_ORG/teams/engineering --jq '.id')

# Create child team "backend"
gh api orgs/YOUR_ORG/teams -X POST \
  -f name="backend" \
  -f description="Backend engineers" \
  -f privacy="closed" \
  -f parent_team_id=$(gh api orgs/YOUR_ORG/teams/engineering --jq '.id')
```

### 3.3 Grant Team Repository Access

```bash
# Give "engineering" team Write access to the test repo
gh api orgs/YOUR_ORG/teams/engineering/repos/YOUR_ORG/access-lab-repo -X PUT \
  -f permission="write"
```

### 3.4 Verify Inheritance

1. Add TEST_USER_1 to the "frontend" child team (NOT engineering directly):
   ```bash
   gh api orgs/YOUR_ORG/teams/frontend/memberships/TEST_USER_1 -X PUT \
     -f role="member"
   ```

2. Verify TEST_USER_1 now has Write access to the repo:
   ```bash
   gh api repos/YOUR_ORG/access-lab-repo/collaborators/TEST_USER_1/permission \
     --jq '.permission'
   # Expected output: "write" (inherited through parent team)
   ```

**Key learning**: Child teams inherit parent team repository access.

---

## Exercise 4 — CODEOWNERS

### 4.1 Create a CODEOWNERS File

In your test repository, create `.github/CODEOWNERS`:

```bash
cat > .github/CODEOWNERS << 'EOF'
# Global owner
*   @YOUR_ORG/engineering

# JavaScript files go to frontend team
*.js   @YOUR_ORG/frontend

# Backend services
/src/api/   @YOUR_ORG/backend

# Security-sensitive areas (last match wins)
/src/api/auth/   @YOUR_ORG/backend @YOUR_USERNAME
EOF

git add .github/CODEOWNERS
git commit -m "Add CODEOWNERS file"
git push
```

### 4.2 Test CODEOWNERS in a PR

Create a PR that modifies `/src/api/auth/`:
```bash
git checkout -b test/codeowners-lab
mkdir -p src/api/auth
echo "# Auth module" > src/api/auth/login.py
git add src/api/auth/login.py
git commit -m "Add auth login module"
git push -u origin test/codeowners-lab
gh pr create --title "Test CODEOWNERS" --body "Testing code owner review assignment"
```

Verify: The PR shows `@YOUR_ORG/backend` and `@YOUR_USERNAME` as requested reviewers.

### 4.3 Test Last-Match-Wins Behavior

Observe:
- `src/api/auth/login.py` matches `*`, `*.py` (if you add it), `/src/api/`, AND `/src/api/auth/`
- Only `/src/api/auth/` owners are requested (LAST matching pattern)
- This is the critical CODEOWNERS behavior for the exam

---

## Exercise 5 — Branch Protection Rules

### 5.1 Create a Branch Protection Rule for `main`

Via UI:
1. Navigate to: `Repo Settings > Branches > Add branch protection rule`
2. Branch name pattern: `main`
3. Enable:
   - [x] Require a pull request before merging
     - Required approving reviews: 1
     - [x] Dismiss stale PR approvals when new commits are pushed
     - [x] Require review from code owners
   - [x] Require status checks to pass
     - (If you have CI, add it here)
   - [x] Do not allow bypassing the above settings

4. Click **Save changes**

### 5.2 Test Branch Protection

```bash
# Try to push directly to main (should be blocked)
git checkout main
echo "direct push test" >> README.md
git add README.md
git commit -m "Test direct push to main"
git push
# Expected: error - "protected branch hook declined"
```

```bash
# Correct approach: create a PR
git checkout -b fix/readme-update
echo "PR-based update" >> README.md
git add README.md
git commit -m "Update readme via PR"
git push -u origin fix/readme-update
gh pr create --title "Readme update" --body "Testing branch protection"
```

### 5.3 Observe CODEOWNERS + Branch Protection Interaction

With branch protection requiring code owner review:
- Open the PR created above
- Notice that `@YOUR_ORG/backend` is a **required** reviewer (not just suggested)
- The PR cannot be merged without their approval

---

## Exercise 6 — Repository Rulesets

### 6.1 Create a Ruleset via UI

1. Navigate to: `Repo Settings > Rules > Rulesets > New ruleset`
2. Name: `require-signed-commits`
3. Target: Default branch
4. Enforcement: **Evaluate** (dry run first)
5. Rules: Add rule > **Required signatures**
6. Click **Save changes**

### 6.2 Check Ruleset Insights

1. Make a commit without signing
2. Navigate to: `Repo > Insights > Rulesets`
3. View the evaluation log — the ruleset detected unsigned commit but didn't block it (Evaluate mode)

### 6.3 Switch to Active and Test

1. Change enforcement to **Active**
2. Try to push an unsigned commit:
   ```bash
   git commit -m "Unsigned commit attempt" --allow-empty
   git push
   # Expected: blocked with error about required signatures
   ```

3. Configure commit signing and try again:
   ```bash
   # Sign with SSH (assuming you have GPG or SSH signing configured)
   git config --local commit.gpgsign true
   git commit -m "Signed commit" --allow-empty
   git push
   # Expected: success
   ```

---

## Exercise 7 — Outside Collaborators

### 7.1 Add an Outside Collaborator

Add a user who is NOT an org member to a specific repository:

```bash
gh api repos/YOUR_ORG/access-lab-repo/collaborators/OUTSIDE_USER -X PUT \
  -f permission="read"
```

### 7.2 Verify Outside Collaborator Access

1. As OUTSIDE_USER: can access `access-lab-repo` (read-only)
2. As OUTSIDE_USER: CANNOT access other org repos (even if base=Read)
3. Check: OUTSIDE_USER is listed in `Org > People > Outside collaborators`

### 7.3 Convert Outside Collaborator to Org Member

```bash
gh api orgs/YOUR_ORG/invitations -X POST \
  -f login="OUTSIDE_USER" \
  -f role="direct_member"
```

After accepting, OUTSIDE_USER becomes an org member and inherits base permissions.

---

## Lab Checkpoint Questions

1. You need a team member to manage repository settings (webhooks, deploy keys) but not delete the repository. What role do you assign?
2. If base permissions are set to "Write," can you use a team to give a user Read-only access to a specific repository?
3. A CODEOWNERS file has two entries: `*.py @python-team` and `/src/ @platform-team`. A PR modifies `/src/main.py`. Which team is requested as reviewer?
4. What is the difference between "Require review from Code Owners" (branch protection) and having a CODEOWNERS file?
5. Can a repository ruleset be applied to multiple repositories at the organization level? (Answer: yes)
6. What happens to outside collaborator access when they are converted to org members?

---

## Key Takeaways

- Highest permission wins — teams cannot restrict below base permissions
- Child teams inherit parent team repository access
- CODEOWNERS: LAST matching pattern wins
- CODEOWNERS + required reviews = enforced code ownership
- Rulesets can be applied at repo, org, or enterprise level
- Rulesets have bypass actors; classic branch protection has admin bypass toggle
- "Evaluate" mode = dry run for rulesets (see violations without blocking)

---

## Cleanup

```bash
# Remove branch protection rules
gh api repos/YOUR_ORG/access-lab-repo/branches/main/protection -X DELETE

# Remove teams created
gh api orgs/YOUR_ORG/teams/frontend -X DELETE
gh api orgs/YOUR_ORG/teams/backend -X DELETE
gh api orgs/YOUR_ORG/teams/engineering -X DELETE

# Remove test collaborators
gh api repos/YOUR_ORG/access-lab-repo/collaborators/TEST_USER_1 -X DELETE
gh api repos/YOUR_ORG/access-lab-repo/collaborators/TEST_USER_2 -X DELETE

# Delete test repo if desired
gh repo delete YOUR_ORG/access-lab-repo --yes
```
