# Domain 6 Cheatsheet

- Policy precedence: enterprise, then organization, then repository.
- Required workflows are policy controls, not just reusable workflow patterns.
- Prefer ephemeral self-hosted runners for high-risk workloads.
- Runner groups control access to runner pools.
- `GITHUB_TOKEN` is read-only by default in modern orgs unless broadened.
- OIDC requires `id-token: write`.
