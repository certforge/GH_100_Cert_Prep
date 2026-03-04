# Scripts — GH-100 Cert Prep Utilities

This directory contains utility scripts for common GitHub Administration tasks that are relevant to the GH-100 exam. These scripts are intended as learning aids — they demonstrate how to perform admin tasks programmatically via the GitHub API and CLI.

---

## Prerequisites

All scripts require:
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
- `jq` for JSON processing: `brew install jq` (macOS) or `apt install jq` (Linux)
- `curl` for direct API calls
- Appropriate GitHub permissions for the operations you're performing

```bash
# Verify prerequisites
gh --version
jq --version
curl --version
gh auth status
```

---

## Available Script Patterns

Rather than shipping executable scripts (which could become outdated), this section provides copy-paste script patterns for common admin operations. Adapt these to your environment.

---

### Pattern 1 — Audit: Find All Repos Without GHAS Enabled

```bash
#!/bin/bash
# Usage: GITHUB_ORG=myorg bash find-repos-without-ghas.sh

ORG="${GITHUB_ORG:-YOUR_ORG_NAME}"

echo "Checking GHAS status for all repos in $ORG..."
echo "Repository,GHAS Status,Secret Scanning,Push Protection,Code Scanning"

gh api "orgs/$ORG/repos" --paginate \
  --jq '.[] | {
    name: .name,
    ghas: .security_and_analysis.advanced_security.status,
    secret_scanning: .security_and_analysis.secret_scanning.status,
    push_protection: .security_and_analysis.secret_scanning_push_protection.status
  }' | \
  jq -r '[.name, .ghas, .secret_scanning, .push_protection] | @csv'
```

**What this does**: Exports a CSV of all repositories with their security feature status. Useful for Domain 5 — understanding which repos have GHAS enabled.

---

### Pattern 2 — Bulk Enable Secret Scanning Push Protection

```bash
#!/bin/bash
# Enables secret scanning and push protection for all private repos in an org
# Usage: GITHUB_ORG=myorg bash enable-push-protection.sh

ORG="${GITHUB_ORG:-YOUR_ORG_NAME}"
FAILED=()
SUCCESS=()

echo "Enabling push protection for all repos in $ORG..."

repos=$(gh api "orgs/$ORG/repos" --paginate --jq '.[].name')

for repo in $repos; do
  echo -n "  $repo: "

  result=$(gh api "repos/$ORG/$repo" -X PATCH \
    -f security_and_analysis='{"advanced_security":{"status":"enabled"},"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}' \
    2>&1)

  if echo "$result" | grep -q '"secret_scanning_push_protection":{"status":"enabled"}'; then
    echo "OK"
    SUCCESS+=("$repo")
  else
    echo "FAILED (may need GHAS license for private repos)"
    FAILED+=("$repo")
  fi
done

echo ""
echo "Summary:"
echo "  Succeeded: ${#SUCCESS[@]}"
echo "  Failed: ${#FAILED[@]}"
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "  Failed repos: ${FAILED[*]}"
fi
```

**What this does**: Domain 5 hands-on — bulk enables GHAS + secret scanning + push protection. Failed repos likely need GHAS license for private repos.

---

### Pattern 3 — Export Open Dependabot Alerts

```bash
#!/bin/bash
# Exports all open Dependabot alerts for an organization
# Usage: GITHUB_ORG=myorg bash export-dependabot-alerts.sh > alerts.csv

ORG="${GITHUB_ORG:-YOUR_ORG_NAME}"

echo "Repository,Alert Number,Package,Severity,CVE,State"

repos=$(gh api "orgs/$ORG/repos" --paginate --jq '.[].name')

for repo in $repos; do
  gh api "repos/$ORG/$repo/dependabot/alerts?state=open&per_page=100" \
    --paginate \
    --jq '.[] | [
      "'"$repo"'",
      (.number | tostring),
      .dependency.package.name,
      .security_advisory.severity,
      (.security_advisory.cve_id // "GHSA"),
      .state
    ] | @csv' 2>/dev/null
done
```

**What this does**: Domain 5 reporting — aggregates all open Dependabot alerts across an org into a CSV for management reporting.

---

### Pattern 4 — Audit Repository Role Assignments

```bash
#!/bin/bash
# Lists all direct collaborators and their roles for a repository
# Usage: GITHUB_ORG=myorg GITHUB_REPO=myrepo bash audit-repo-access.sh

ORG="${GITHUB_ORG:-YOUR_ORG_NAME}"
REPO="${GITHUB_REPO:-YOUR_REPO_NAME}"

echo "Direct collaborators for $ORG/$REPO:"
echo "Username,Permission,Type"

gh api "repos/$ORG/$REPO/collaborators" --paginate \
  --jq '.[] | [.login, .permissions | to_entries | map(select(.value == true)) | last.key, "direct"] | @csv'

echo ""
echo "Team access for $ORG/$REPO:"
echo "Team,Permission"

gh api "repos/$ORG/$REPO/teams" --paginate \
  --jq '.[] | [.name, .permission] | @csv'
```

**What this does**: Domain 4 — audits who has access to a specific repository, useful for access review processes.

---

### Pattern 5 — List All Organization Members Without 2FA

```bash
#!/bin/bash
# Finds org members who do not have 2FA enabled (requires org owner or billing manager access)
# Usage: GITHUB_ORG=myorg bash find-no-2fa.sh

ORG="${GITHUB_ORG:-YOUR_ORG_NAME}"

echo "Members of $ORG without 2FA enabled:"
echo "(Note: Requires org admin access to see 2FA status)"

gh api "orgs/$ORG/members?filter=2fa_disabled" --paginate \
  --jq '.[] | {login: .login, id: .id}' \
  | jq -r '[.login] | @tsv'
```

**What this does**: Domain 2 — finds members who need to enable 2FA before you can enforce it.

---

### Pattern 6 — List Self-Hosted Runners and Status

```bash
#!/bin/bash
# Lists all self-hosted runners at the organization level with their status
# Usage: GITHUB_ORG=myorg bash list-runners.sh

ORG="${GITHUB_ORG:-YOUR_ORG_NAME}"

echo "Self-hosted runners for $ORG:"
echo ""
printf "%-30s %-10s %-10s %s\n" "Runner Name" "Status" "OS" "Labels"
printf "%-30s %-10s %-10s %s\n" "----------" "------" "--" "------"

gh api "orgs/$ORG/actions/runners" --paginate \
  --jq '.runners[] | [
    .name,
    .status,
    (.labels[] | select(.type == "system") | .name) // "unknown",
    ([.labels[] | select(.type == "custom") | .name] | join(","))
  ] | @tsv' | \
  while IFS=$'\t' read -r name status os labels; do
    printf "%-30s %-10s %-10s %s\n" "$name" "$status" "$os" "$labels"
  done
```

**What this does**: Domain 6 — operational view of all self-hosted runners for runner management.

---

### Pattern 7 — Audit Enterprise Audit Log for Security Events

```bash
#!/bin/bash
# Exports security-relevant audit log events from the enterprise
# Usage: GITHUB_ENTERPRISE=myenterprise bash audit-security-events.sh > security-events.jsonl

ENTERPRISE="${GITHUB_ENTERPRISE:-YOUR_ENTERPRISE_SLUG}"

# Security-relevant action categories
ACTIONS=(
  "repo.create"
  "repo.destroy"
  "repo.transfer"
  "repo.visibility_change"
  "protected_branch.create"
  "protected_branch.destroy"
  "protected_branch.update_allow_force_pushes"
  "secret_scanning_alert.resolve"
  "repository.secret_scanning_push_protection_bypass"
  "org.update_member"
  "org.remove_member"
  "enterprise.add_organization"
)

echo "Fetching security audit events from enterprise: $ENTERPRISE"

for action in "${ACTIONS[@]}"; do
  echo "--- Events for action: $action ---" >&2
  gh api "enterprises/$ENTERPRISE/audit-log?phrase=action:$action&per_page=100" \
    --paginate \
    --jq '.[]' 2>/dev/null
done
```

**What this does**: Domain 1 & 5 — extracts security-relevant audit events for compliance review.

---

### Pattern 8 — Check Actions Policy for All Orgs in Enterprise

```bash
#!/bin/bash
# Reports the Actions policy settings for each org in an enterprise
# Usage: GITHUB_ENTERPRISE=myenterprise bash check-actions-policies.sh

ENTERPRISE="${GITHUB_ENTERPRISE:-YOUR_ENTERPRISE_SLUG}"

echo "Actions policies by organization in $ENTERPRISE:"
echo "Org,Actions Enabled,Allowed Actions,Self-hosted Runners"

gh api "enterprises/$ENTERPRISE/organizations" --paginate \
  --jq '.organizations[].login' | \
  while read -r org; do
    policy=$(gh api "orgs/$org/actions/permissions" 2>/dev/null | \
      jq -r '[.enabled_repositories, .allowed_actions, .enabled] | @csv' 2>/dev/null)
    echo "$org,$policy"
  done
```

**What this does**: Domain 6 — audits Actions policy configuration across all organizations in an enterprise.

---

## Usage Notes

1. **Always test in a non-production org first** — many of these scripts make changes if you remove the read-only logic.

2. **Rate limits**: For large enterprises (hundreds of repos), these scripts may hit API rate limits. Add `sleep 1` between iterations or use the `--paginate` flag with `gh api` which handles rate limiting automatically.

3. **Authentication**: Run `gh auth login` and select appropriate scopes before using these scripts. Enterprise-level scripts require the `read:enterprise` scope.

4. **Exam relevance**: These scripts demonstrate concepts tested in the exam — knowing THAT you can do something via the API, and roughly HOW, is more important for the exam than memorizing exact API paths.

---

## Official API Reference

- [GitHub REST API](https://docs.github.com/en/rest)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GraphQL API](https://docs.github.com/en/graphql)
- [Octokit SDKs](https://github.com/octokit)
