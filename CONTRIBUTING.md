# Contributing to GH-100 Cert Prep

Thank you for helping improve this study resource.
All contributions that improve accuracy, clarity, or coverage of exam-relevant content are welcome.

> For org-wide contribution standards see the [CertPrep CONTRIBUTING guide](https://github.com/certprep/.github/blob/main/CONTRIBUTING.md).
> Repo-specific notes are below.

---

## What We Accept

- **Accuracy corrections** — GitHub changes rapidly. If something is outdated, flag it.
- **New practice questions** — Must follow the question format below.
- **Lab and demo improvements** — Clearer steps, troubleshooting sections, or alternative approaches.
- **Better explanations** — Simpler, more precise descriptions of complex concepts.
- **Glossary additions** — New terms or improved definitions.
- **Script improvements** — Error handling, portability, or additional API examples.
- **Typos and formatting fixes** — Small improvements add up.

## What We Do Not Accept

- Content copied verbatim from official documentation (paraphrase and cite instead)
- Practice questions without answer explanations
- Speculative content not tied to official exam objectives
- Changes that remove accurate content without explanation
- Content referencing deprecated features as current (flag them as deprecated instead)
- Third-party tool promotions outside the GitHub ecosystem

---

## How to Contribute

### For Small Changes

Typos, dead links, minor wording — open a PR directly.

### For Substantial Changes

**Step 1 — Open an Issue First**

Describe what you want to change and why. This prevents duplicate effort and allows early feedback.

**Step 2 — Fork and Branch**

```bash
git clone https://github.com/YOUR_USERNAME/GH_100_Cert_Prep.git
cd GH_100_Cert_Prep

# Use a descriptive branch name
git checkout -b fix/brief-description
# or
git checkout -b add/brief-description
```

**Step 3 — Make Your Changes**

Follow the content standards below, then commit with a clear message:

```bash
git add path/to/changed-file.md
git commit -m "fix: short description of what changed and why"
```

**Step 4 — Open a Pull Request**

- Reference any related issues
- Summarize what changed and why
- Confirm the content is accurate against official documentation

### Fork-Only Lab Verification

If you are using this repository as a **training fork**, you can use the built-in lab verification framework:

- open a lab issue from `.github/ISSUE_TEMPLATE/lab-exercise.yml`
- submit a PR using `.github/pull_request_template.md`
- include a markdown evidence file under `lab-submissions/<lab-id>/`

This workflow is intentionally designed to run only in **forked repositories**.

---

## Content Standards

### Accuracy First

- All technical content must reflect current GitHub documentation
- Link to the relevant [GitHub Docs](https://docs.github.com) page when adding new topics
- If you are uncertain about something, add: `> Note: Verify this against current GitHub Docs — this may have changed.`
- Never guess at behavior. Research it or leave it out.

### Domain Weight Respect

Content depth should reflect official exam domain weights.
Heavier domains deserve proportionally deeper coverage.
Refer to `exam-metadata/` for domain weights.

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

### Markdown Formatting

- Use ATX-style headers (`#`, `##`, `###`)
- Use fenced code blocks with language identifiers (` ```bash `, ` ```yaml `, ` ```python `)
- Use tables for comparisons, not prose lists
- Use `<details>/<summary>` for collapsible answer sections
- Use GitHub admonitions for exam tips: `> [!NOTE]`, `> [!TIP]`, `> [!WARNING]`, `> [!IMPORTANT]`
- Keep lines under 120 characters where possible
- One blank line before and after headings

### Practice Question Format

All practice questions must follow this format:

```markdown
### Question N
**Domain**: Domain X — [Domain Title]
**Topic**: [Specific sub-topic]
**Difficulty**: Beginner | Intermediate | Advanced

[Question text — 2–4 sentence business scenario]

A. [Option A]
B. [Option B]
C. [Option C]
D. [Option D]

<details>
<summary>Answer</summary>

**Correct Answer: X**

**Explanation**: [Why the answer is correct and why other options are wrong]

**Reference**: [Link to GitHub Docs]
</details>
```

Requirements:

- Exactly one correct answer (or clearly specify "select all that apply")
- Explanations must teach the concept, not just repeat the answer
- Difficulty: Beginner = recall, Intermediate = application, Advanced = analysis/scenario
- Questions must be unambiguous — if reviewers disagree on the answer, revise it

---

## Reporting Issues

If you find inaccurate content but cannot fix it, open an issue with:

1. The file and section where the inaccuracy exists
2. What the current (incorrect) content says
3. What the correct content should say
4. A link to the official documentation that confirms the correction

---

## Security

If you discover a real security issue in this repository, do **not** open a public issue.
Follow the process in [SECURITY.md](https://github.com/certprep/.github/blob/main/SECURITY.md).

---

## Code of Conduct

Be respectful. Everyone here is learning.

---

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE) that covers this repository.
