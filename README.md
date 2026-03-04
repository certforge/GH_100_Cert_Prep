# GH-100: GitHub Administration Certification Prep

A comprehensive study repository for the **GH-100: GitHub Administration** certification exam. This repository provides structured study notes, hands-on labs, practice questions, and quick-reference materials aligned to the official exam domain weights.

---

## Exam Overview

| Field | Details |
|-------|---------|
| Exam Code | GH-100 |
| Full Name | GitHub Administration |
| Delivery | Online proctored (Pearson VUE) |
| Question Format | Multiple choice, multiple select |
| Duration | 120 minutes |
| Passing Score | 750 / 1000 |
| Language | English |
| Prerequisite Knowledge | GitHub fundamentals, basic Linux/CLI, networking concepts |

---

## Who Should Take This Exam

The GH-100 exam is designed for:

- **GitHub Enterprise administrators** managing GHEC or GHES deployments
- **DevOps/Platform engineers** responsible for GitHub infrastructure
- **Security engineers** implementing GitHub Advanced Security
- **IT administrators** migrating organizations to GitHub Enterprise
- **Team leads** managing organization-wide GitHub policies

**Recommended experience**: 6-12 months hands-on experience administering GitHub at the organization or enterprise level.

---

## Prerequisites

Before studying for GH-100, you should be comfortable with:

- Creating and managing GitHub repositories, branches, and pull requests
- Basic Git commands (clone, push, pull, merge, rebase)
- GitHub organization concepts (teams, members, repositories)
- Basic Linux command line and shell scripting
- Fundamental networking (DNS, HTTP/HTTPS, firewalls)
- Authentication concepts (SSO, SAML, OAuth, tokens)

---

## Repository Structure

```
GH_100_Cert_Prep/
├── README.md                          # This file
├── QUICK-REFERENCE.md                 # Printable cheat sheet for all domains
├── CONTRIBUTING.md                    # How to contribute to this repo
├── LICENSE                            # MIT License
├── .gitignore
├── .editorconfig
│
├── exam-metadata/
│   ├── gh-100-exam-objectives.md     # Complete domain/objective breakdown
│   ├── domain-weights.md             # Visual weight distribution + study time
│   └── key-terms-glossary.md         # 50+ GitHub Administration definitions
│
├── docs/
│   ├── domain-1-enterprise-support.md
│   ├── domain-2-identity-authentication.md
│   ├── domain-3-deployment-licensing.md
│   ├── domain-4-access-permissions.md
│   ├── domain-5-security-compliance.md   # HEAVIEST (36%) — most comprehensive
│   └── domain-6-github-actions.md
│
├── demos/
│   ├── 01-enterprise-setup/README.md
│   ├── 02-identity-sso-setup/README.md
│   ├── 03-deployment-options/README.md
│   ├── 04-access-permissions/README.md
│   ├── 05-security-compliance/README.md
│   └── 06-github-actions/README.md
│
├── .github/
│   ├── SECURITY.md
│   ├── dependabot.yml
│   └── workflows/
│       └── link-check.yml
│
└── scripts/
    └── README.md
```

---

## Domain Breakdown and Weights

| Domain | Title | Weight | Priority |
|--------|-------|--------|----------|
| Domain 1 | Support GitHub Enterprise for users and key stakeholders | 9% | Medium |
| Domain 2 | Manage user identities and GitHub authentication | 11% | Medium-High |
| Domain 3 | Describe how GitHub is deployed, distributed, and licensed | 9% | Medium |
| Domain 4 | Manage access and permissions based on membership | 18% | High |
| Domain 5 | Enable secure software development and ensure compliance | 36% | **Critical** |
| Domain 6 | Manage GitHub Actions | 16% | High |

**Domain 5 is worth more than a third of the exam.** Prioritize your study time accordingly.

---

## Quick Start Study Plan

### Week 1 — Foundation
- Read `exam-metadata/gh-100-exam-objectives.md` to understand scope
- Review `exam-metadata/key-terms-glossary.md` to build vocabulary
- Complete Domain 3 study notes (deployment/licensing — good foundation)
- Complete Domain 1 study notes (enterprise support)

### Week 2 — Identity and Access
- Complete Domain 2 study notes (identity and authentication)
- Complete Domain 4 study notes (access and permissions)
- Run Demo Lab 02 (SSO/SAML setup) and Demo Lab 04 (permissions)

### Week 3 — Security Deep Dive (Double Time Here)
- Complete Domain 5 study notes — read twice
- Run Demo Lab 05 (security policies)
- Focus on: Dependabot, secret scanning, code scanning, branch protections, rulesets, GHAS

### Week 4 — Actions and Review
- Complete Domain 6 study notes (GitHub Actions)
- Run Demo Lab 06 (Actions management)
- Take practice questions for all domains
- Review `QUICK-REFERENCE.md` daily

---

## How to Use This Repository

1. **Start with exam metadata** — understand what the exam tests before diving into content
2. **Read domain docs in weight order** — Domain 5, then 4, then 6, then 2, then 1 and 3
3. **Do the labs** — hands-on practice reinforces concepts tested in the exam
4. **Use the quick reference** — print or bookmark `QUICK-REFERENCE.md` for last-minute review
5. **Answer practice questions** — each domain doc includes 5-10 practice questions

---

## Study Tips

- **GitHub's UI changes frequently.** Always cross-reference with the official [GitHub Docs](https://docs.github.com). If something in this repo conflicts with current docs, docs win.
- **Terminology matters.** The exam uses GitHub's exact terms. Know the difference between "organization" and "enterprise," between "repository ruleset" and "branch protection rule."
- **GHEC vs GHES distinctions are heavily tested.** Many features are only available on one platform. Make a comparison table for yourself.
- **EMU (Enterprise Managed Users) is a major topic** in Domain 2 and Domain 4. Understand what it restricts and enables.
- **Domain 5 has scenario-based questions.** You will be given a security requirement and asked which GitHub feature satisfies it. Learn the use case for every security feature.
- **For Actions (Domain 6),** focus on the administrative controls — policies, runner groups, required workflows — not workflow authoring syntax.

---

## Official Resources

- [GitHub Docs](https://docs.github.com)
- [GitHub Enterprise Cloud Documentation](https://docs.github.com/en/enterprise-cloud@latest)
- [GitHub Enterprise Server Documentation](https://docs.github.com/en/enterprise-server@latest)
- [GitHub Advanced Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
- [GitHub Certifications](https://examregistration.github.com/)
- [GitHub Skills](https://skills.github.com)
- [GitHub Blog](https://github.blog)

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on submitting corrections, new practice questions, or lab improvements.

---

## License

This repository is licensed under the [MIT License](./LICENSE). Study materials are community-contributed and not affiliated with or endorsed by GitHub, Inc.

> Note: GitHub and GitHub Enterprise are trademarks of GitHub, Inc. This repository is an independent study resource.
