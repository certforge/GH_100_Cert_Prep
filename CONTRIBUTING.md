# Contributing to GH-100 Cert Prep

Thank you for helping improve this study resource. Contributions that correct inaccuracies, add practice questions, update content for new GitHub features, or improve labs are all welcome.

---

## What We Need Most

1. **Accuracy corrections** — GitHub changes rapidly. If you notice something outdated, please flag it.
2. **New practice questions** — Especially for Domain 5 (security) and Domain 6 (Actions).
3. **Lab improvements** — More detailed steps, troubleshooting sections, or alternative approaches.
4. **Glossary additions** — New terms or improved definitions.
5. **Typos and formatting fixes** — Small improvements add up.

---

## How to Contribute

### Step 1 — Open an Issue First (for substantial changes)

Before writing a large PR, open an issue describing what you want to change and why. This avoids duplicate effort and lets maintainers give early feedback.

For small changes (typos, dead links, minor wording), you can open a PR directly.

### Step 2 — Fork and Branch

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/GH_100_Cert_Prep.git
cd GH_100_Cert_Prep

# Create a descriptive branch
git checkout -b fix/domain5-secret-scanning-accuracy
# or
git checkout -b add/domain6-practice-questions
```

### Step 3 — Make Your Changes

Follow the content standards below, then commit with a clear message:

```bash
git add docs/domain-5-security-compliance.md
git commit -m "fix: update push protection setup steps for enterprise level"
```

### Step 4 — Open a Pull Request

- Use the PR template provided
- Reference any related issues
- Summarize what changed and why

---

## Content Standards

### Accuracy First

- All technical content must reflect current GitHub documentation
- Link to the relevant [GitHub Docs](https://docs.github.com) page when adding new topics
- If you are not certain something is current, add a note: `> Note: Verify this against current GitHub Docs — this feature may have changed.`
- Never guess at behavior. If unsure, research or leave it out.

### Domain Weight Respect

Content depth should reflect exam weights:
- Domain 5 (36%) — exhaustive coverage
- Domain 4 (18%) and Domain 6 (16%) — thorough coverage
- Domain 2 (11%) — solid coverage
- Domain 1 (9%) and Domain 3 (9%) — concise but complete

### Terminology

Use GitHub's exact terminology. Common correct terms:

| Use This | Not This |
|----------|----------|
| Enterprise Managed Users (EMU) | Managed accounts |
| repository ruleset | branch ruleset |
| GitHub Advanced Security (GHAS) | GitHub security suite |
| organization owner | org admin |
| fine-grained personal access token | fine-grained PAT (OK to abbreviate after first use) |
| GitHub Enterprise Cloud (GHEC) | GHEC cloud |
| GitHub Enterprise Server (GHES) | self-hosted GitHub |
| Dependabot alerts | vulnerability alerts (old name) |

### Practice Questions Format

All practice questions must follow this exact format:

```markdown
### Question N
**Domain**: Domain X — [Domain Title]
**Topic**: [Specific sub-topic]
**Difficulty**: Beginner | Intermediate | Advanced

[Question text]

A. [Option A]
B. [Option B]
C. [Option C]
D. [Option D]

<details>
<summary>Answer</summary>

**Correct Answer: X**

**Explanation**: [Detailed explanation of why the answer is correct and why other options are wrong]

**Reference**: [Link to GitHub Docs]
</details>
```

Requirements:
- Each question must have exactly one correct answer (or clearly specify "select all that apply")
- Explanations must teach the concept, not just repeat the answer
- Difficulty must be accurate (Beginner = recall, Intermediate = application, Advanced = analysis/scenario)
- Questions must be unambiguous — if reviewers disagree on the answer, the question needs revision

### Markdown Formatting

- Use ATX-style headers (`#`, `##`, etc.)
- Use fenced code blocks with language specifiers (` ```bash `, ` ```yaml `, etc.)
- Use tables for comparisons
- Use `<details>/<summary>` for collapsible answer sections in practice questions
- Keep lines under 120 characters where possible
- One blank line between sections

---

## What We Will NOT Merge

- Content copied verbatim from GitHub documentation (paraphrase and cite instead)
- Practice questions without answer explanations
- Speculative content that is not verifiable against GitHub Docs
- Changes that remove accurate content without explanation
- Content that refers to deprecated features as current (flag it as deprecated instead)

---

## Reporting Issues

If you find inaccurate content but do not have time to fix it, please open an issue with:

1. The file and section where the inaccuracy exists
2. What the current (incorrect) content says
3. What the correct content should say
4. A link to the GitHub Docs page that confirms the correction

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License that covers this repository.
