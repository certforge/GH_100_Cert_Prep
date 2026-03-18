#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/scripts/output"
REPORT_FILE="$OUTPUT_DIR/lab-verification-report.md"

mkdir -p "$OUTPUT_DIR"

fail() {
  echo "ERROR: $*" >&2
  {
    echo "# GH-100 Lab Verification Report"
    echo
    echo "Status: FAIL"
    echo
    echo "- $*"
  } > "$REPORT_FILE"
  exit 1
}

extract_field() {
  local name="$1"
  printf '%s\n' "${PR_BODY:-}" | sed -n "s/^${name}: *//p" | head -n 1
}

LAB_ID="$(extract_field "Lab-ID")"
ISSUE_REF="$(extract_field "Issue")"
VALIDATION_EVIDENCE="$(extract_field "Validation-Evidence")"

[ -n "$LAB_ID" ] || fail "PR body must include 'Lab-ID: <official-lab-id>'."
[ -n "$ISSUE_REF" ] || fail "PR body must include 'Issue: #<number>'."
[ -n "$VALIDATION_EVIDENCE" ] || fail "PR body must include 'Validation-Evidence: <value>'."

case "$LAB_ID" in
  domain-1-enterprise-support|domain-2-identity-authentication|domain-3-deployment-licensing|domain-4-access-permissions|domain-5-security-compliance|domain-6-github-actions)
    ;;
  *)
    fail "Unsupported Lab-ID '$LAB_ID'."
    ;;
esac

CHANGED_FILES="$(git -C "$ROOT_DIR" diff --name-only "$BASE_SHA" "$HEAD_SHA")"
SUBMISSION_DIR="lab-submissions/$LAB_ID"

printf '%s\n' "$CHANGED_FILES" | grep -q "^$SUBMISSION_DIR/" || fail "PR must add or update a submission file under '$SUBMISSION_DIR/'."

SUBMISSION_FILE="$(printf '%s\n' "$CHANGED_FILES" | grep "^$SUBMISSION_DIR/.*\.md$" | head -n 1)"
[ -n "$SUBMISSION_FILE" ] || fail "No markdown submission file found under '$SUBMISSION_DIR/'."

FULL_SUBMISSION_PATH="$ROOT_DIR/$SUBMISSION_FILE"
[ -f "$FULL_SUBMISSION_PATH" ] || fail "Submission file '$SUBMISSION_FILE' does not exist in the PR checkout."

for section in "## Summary" "## Commands" "## Screenshots or Artifacts" "## Outcome"; do
  grep -q "^$section" "$FULL_SUBMISSION_PATH" || fail "Submission file '$SUBMISSION_FILE' must contain section '$section'."
done

case "$LAB_ID" in
  domain-1-enterprise-support)
    grep -Eiq "status\.github\.com|audit log|license usage|support" "$FULL_SUBMISSION_PATH" || fail "Domain 1 submission must mention support, status, audit log, or license evidence."
    ;;
  domain-2-identity-authentication)
    grep -Eiq "saml|scim|emu|pat|2fa|ldap|oauth|github app" "$FULL_SUBMISSION_PATH" || fail "Domain 2 submission must mention identity/auth evidence."
    ;;
  domain-3-deployment-licensing)
    grep -Eiq "ghes|ghec|github connect|ghe-repl|ghe-backup|license" "$FULL_SUBMISSION_PATH" || fail "Domain 3 submission must mention deployment or licensing evidence."
    ;;
  domain-4-access-permissions)
    if ! printf '%s\n' "$CHANGED_FILES" | grep -Eq "CODEOWNERS|ruleset|domain-4-access-permissions"; then
      grep -Eiq "ruleset|branch protection|codeowners|outside collaborator|base permission|merge queue" "$FULL_SUBMISSION_PATH" || fail "Domain 4 submission must include access-governance evidence."
    fi
    ;;
  domain-5-security-compliance)
    if ! printf '%s\n' "$CHANGED_FILES" | grep -Eq "dependabot|dependency-review|SECURITY\.md|domain-5-security-compliance"; then
      grep -Eiq "ghas|secret scanning|push protection|dependabot|code scanning|dependency review|sbom" "$FULL_SUBMISSION_PATH" || fail "Domain 5 submission must include security evidence."
    fi
    ;;
  domain-6-github-actions)
    if ! printf '%s\n' "$CHANGED_FILES" | grep -Eq "\.github/workflows|oidc|runner|domain-6-github-actions"; then
      grep -Eiq "runner|oidc|required workflow|environment|github_token|actions policy" "$FULL_SUBMISSION_PATH" || fail "Domain 6 submission must include Actions-admin evidence."
    fi
    ;;
esac

{
  echo "# GH-100 Lab Verification Report"
  echo
  echo "Status: PASS"
  echo
  echo "- PR: #${PR_NUMBER:-unknown}"
  echo "- Lab ID: $LAB_ID"
  echo "- Issue: $ISSUE_REF"
  echo "- Evidence marker: $VALIDATION_EVIDENCE"
  echo "- Submission file: $SUBMISSION_FILE"
} > "$REPORT_FILE"

echo "Verification passed for $LAB_ID using $SUBMISSION_FILE"
