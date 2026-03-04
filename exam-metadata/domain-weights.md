# GH-100 Domain Weights and Study Time Allocation

---

## Visual Weight Distribution

```
Domain 5 — Security & Compliance          ████████████████████████████████████  36%
Domain 4 — Access & Permissions           ██████████████████                    18%
Domain 6 — GitHub Actions                 ████████████████                      16%
Domain 2 — Identity & Authentication      ███████████                           11%
Domain 1 — Enterprise Support             █████████                              9%
Domain 3 — Deployment & Licensing         █████████                              9%
                                          0%         25%        50%        100%
```

---

## Approximate Question Count

Assuming 80 questions total (typical for GitHub certification exams):

| Domain | Weight | Est. Questions | Priority Level |
|--------|--------|---------------|----------------|
| Domain 5 — Security & Compliance | 36% | ~29 questions | CRITICAL |
| Domain 4 — Access & Permissions | 18% | ~14 questions | HIGH |
| Domain 6 — GitHub Actions | 16% | ~13 questions | HIGH |
| Domain 2 — Identity & Authentication | 11% | ~9 questions | MEDIUM-HIGH |
| Domain 1 — Enterprise Support | 9% | ~7 questions | MEDIUM |
| Domain 3 — Deployment & Licensing | 9% | ~7 questions | MEDIUM |
| **Total** | **100%** | **~80 questions** | |

> Note: GitHub does not publish the exact question count for GH-100. These estimates are based on similar certification exams. The weights are official.

---

## Recommended Study Time Allocation

For a candidate with 6+ months of GitHub admin experience targeting 4 weeks of prep:

### 4-Week Study Plan

| Week | Focus | Hours | Activities |
|------|-------|-------|------------|
| Week 1 | Foundation: Domains 1, 2, 3 | 8-10 hrs | Read docs, complete lab demos 01, 02, 03 |
| Week 2 | Access & Actions: Domains 4, 6 | 10-12 hrs | Read docs, complete lab demos 04, 06, practice questions |
| Week 3 | Security Deep Dive: Domain 5 | 14-16 hrs | Read docs twice, complete lab demo 05, all security practice Qs |
| Week 4 | Review + Practice Exams | 8-10 hrs | QUICK-REFERENCE review, weak area remediation |

**Total estimated study time: 40-48 hours**

### Daily Study Time by Domain

If studying daily for 4 weeks (28 days):

| Domain | % of Exam | Suggested Study Days | Minutes/Day |
|--------|-----------|---------------------|-------------|
| Domain 5 | 36% | 10 days | 90 min |
| Domain 4 | 18% | 5 days | 90 min |
| Domain 6 | 16% | 4-5 days | 90 min |
| Domain 2 | 11% | 3 days | 90 min |
| Domain 1 | 9% | 2-3 days | 60 min |
| Domain 3 | 9% | 2-3 days | 60 min |

---

## Domain Difficulty Assessment

| Domain | Difficulty | Why |
|--------|------------|-----|
| Domain 1 — Enterprise Support | Low | Mostly recall and awareness |
| Domain 2 — Identity & Authentication | Medium-High | SAML/SCIM/EMU require precise understanding |
| Domain 3 — Deployment & Licensing | Medium | GHES architecture needs hands-on familiarity |
| Domain 4 — Access & Permissions | Medium-High | Many overlapping permission levels + rulesets |
| Domain 5 — Security & Compliance | High | Most features, most nuance, most scenario questions |
| Domain 6 — GitHub Actions | Medium | Admin focus (not authoring) but runner security is nuanced |

---

## "Danger Zone" Topics (Highest Exam Risk)

These topics are the most commonly misunderstood and most likely to appear on the exam:

### Domain 5 Danger Zones
1. **Secret scanning vs push protection** — These are distinct features. Push protection blocks secrets BEFORE commit; secret scanning alerts AFTER.
2. **GHAS licensing for private repos** — GHAS is free for public repos; private repos require a license.
3. **Branch protection rules vs rulesets** — Both exist. Rulesets are newer and more flexible. Rulesets can be enterprise-wide.
4. **Dependabot alerts vs security updates vs version updates** — Three separate features with different triggers.
5. **Required workflows** — Live in Domain 6 but have security implications in Domain 5.

### Domain 4 Danger Zones
1. **Repository roles vs org roles** — Different role sets with different names.
2. **Base permissions** — Apply to ALL org members on ALL repos (unless repo has stricter explicit grants).
3. **CODEOWNERS + required reviews** — CODEOWNERS alone does not enforce review; needs branch protection to require it.
4. **Internal visibility** — Only available on GHEC/GHES, not GitHub.com Free/Team.

### Domain 6 Danger Zones
1. **Runner group inheritance** — Enterprise runner groups can be shared to orgs, org groups to repos.
2. **GITHUB_TOKEN scope** — Default is read-only since 2023; must explicitly grant write.
3. **Environment secrets availability** — Only available when a job targets the named environment.
4. **Required workflows** — Different from required status checks. Required workflows are org-level policies.

### Domain 2 Danger Zones
1. **SAML vs SCIM roles** — SAML = authentication; SCIM = provisioning/deprovisioning. They are complementary.
2. **EMU restrictions** — EMU users CANNOT interact with external (non-enterprise) repos.
3. **PAT authorization for SAML SSO** — After SAML is enabled, all existing PATs must be authorized for SSO access.

---

## Score Calculation Context

| Metric | Value |
|--------|-------|
| Passing score | 750 / 1000 (75%) |
| Domain 5 max contribution | 360 points |
| Domain 4 max contribution | 180 points |
| Domain 6 max contribution | 160 points |
| Score from Domains 1+2+3 combined | 290 points max |

**Practical implication**: You can score 0 on Domains 1, 2, and 3 and still pass if you score perfectly on Domains 4, 5, and 6 (700 points). However, a balanced score is safer. Never neglect any domain entirely.

**Minimum to pass if you score average elsewhere**:
- If you score 75% on Domains 1, 2, 3, 4, 6 = 542.5 points
- You need 750 to pass
- That leaves 207.5 points needed from Domain 5 (which has 360 max)
- Means you need ~58% on Domain 5 just to pass
- **Conclusion: You must score well on Domain 5, period.**

---

## Recommended Focus Order for Study

1. **Start here**: `exam-metadata/gh-100-exam-objectives.md` — understand scope
2. **Then**: `exam-metadata/key-terms-glossary.md` — build vocabulary
3. **Domain order** (most important first):
   - `docs/domain-5-security-compliance.md`
   - `docs/domain-4-access-permissions.md`
   - `docs/domain-6-github-actions.md`
   - `docs/domain-2-identity-authentication.md`
   - `docs/domain-1-enterprise-support.md`
   - `docs/domain-3-deployment-licensing.md`
4. **Labs** (run in parallel with study):
   - `demos/05-security-compliance/README.md`
   - `demos/04-access-permissions/README.md`
   - `demos/06-github-actions/README.md`
5. **Final review**: `QUICK-REFERENCE.md`
