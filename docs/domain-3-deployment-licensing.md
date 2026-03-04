# Domain 3 — Describe How GitHub Is Deployed, Distributed, and Licensed

**Exam Weight: 9%**
**Approximate Questions: 7-9**
**Priority: Medium**

---

## Domain Overview

Domain 3 covers the infrastructure and commercial aspects of GitHub deployment. Unlike domains focused on features, this domain asks: "Which GitHub product fits which scenario?" and "How does GitHub Enterprise licensing work?"

Understanding GHEC vs GHES trade-offs is essential. The exam will present scenarios and ask which deployment model best meets the requirements (data sovereignty, authentication options, maintenance control, etc.).

---

## Key Concepts

- **GitHub deployment models**: GitHub.com, GHEC, GHES, and the deprecated GitHub AE
- **GHES architecture**: virtual appliance, hypervisor support, Management Console
- **High availability**: primary + replica, failover, geo-replication
- **Backup and restore**: `github-backup-utils`
- **GHES upgrades**: hotpatch vs full upgrade packages
- **GitHub licensing**: per-seat model, what counts as a seat
- **GitHub Connect**: bridge between GHES and GitHub.com

---

## 3.1 GitHub Deployment Models

### Overview Comparison

| Aspect | GitHub.com (Free/Pro/Team) | GitHub Enterprise Cloud (GHEC) | GitHub Enterprise Server (GHES) |
|--------|--------------------------|-------------------------------|--------------------------------|
| Hosting | GitHub-managed | GitHub-managed | Customer-managed |
| Infrastructure | GitHub's cloud | GitHub's cloud | Customer's data center / cloud |
| Data location | GitHub's servers (US-based) | GitHub's servers (configurable residency options) | Wherever customer deploys |
| SAML SSO | No | Yes (org-level) | Yes (instance-level) |
| LDAP / CAS | No | No | Yes |
| Maintenance by | GitHub | GitHub | Customer |
| Updates | Automatic | Automatic | Manual (admin applies upgrades) |
| High availability | N/A | Built into platform | Customer-configured |
| Network isolation | No | No (public internet) | Yes (air-gapped possible) |
| GHAS for private repos | Requires GHAS license | Requires GHAS license | Requires GHAS license |
| GitHub Actions runners | GitHub-hosted + self-hosted | GitHub-hosted + self-hosted | Self-hosted only (no GitHub-hosted) |
| Actions minutes included | Limited (plan-based) | 50,000 min/month (Enterprise) | Self-hosted — no billing |

### When to Choose GHEC vs GHES

**Choose GHEC when**:
- You need GitHub-managed infrastructure (no ops overhead)
- You want automatic updates and no maintenance windows
- Your compliance requirements allow cloud hosting
- You need GitHub-hosted Actions runners
- You want Codespaces

**Choose GHES when**:
- You require data sovereignty (data must not leave your network)
- You need air-gapped deployment (no internet access)
- You need LDAP or CAS authentication
- Your compliance framework mandates on-premises hosting
- You need custom network security policies (firewalls, proxies)

### GitHub AE (Deprecated)

GitHub AE was a fully managed, single-tenant GitHub instance hosted by GitHub on Azure infrastructure. It has been deprecated. Customers should migrate to GHEC or GHES.

---

## 3.2 GitHub Enterprise Server Architecture

### What Is GHES?

GHES is distributed as a **virtual appliance** — a pre-built VM image containing all GitHub services. Customers deploy this image on their infrastructure.

### Supported Hypervisors and Cloud Platforms

| Platform | Notes |
|----------|-------|
| VMware vSphere (ESXi) | Most common on-premises option |
| Microsoft Hyper-V | Windows Server-based deployments |
| KVM | Linux kernel-based virtualization |
| XenServer | Citrix hypervisor |
| OpenStack KVM | OpenStack environments |
| Amazon Web Services (AWS) | Deploy via AMI |
| Microsoft Azure | Deploy via VHD |
| Google Cloud Platform (GCP) | Deploy via custom image |

### GHES Hardware Requirements (General)

- Minimum: 8 vCPUs, 32 GB RAM for small instances
- Recommended for production: 16+ vCPUs, 64+ GB RAM
- Storage: SSD recommended; separate OS, data, and temp volumes
- Size depends on: user count, repository count, LFS usage, Actions usage

### The Management Console

The Management Console is the web-based admin UI for GHES, accessed at:
```
https://HOSTNAME:8443
```

Functions:
- Configure authentication (SAML, LDAP, built-in)
- Upload SSL certificates
- Configure SMTP/email settings
- Set network configuration (hostname, DNS, proxy)
- Enable/disable services (Codespaces, GHAS, Actions)
- Set maintenance mode
- Upload license file
- Download diagnostic bundles
- View system resource usage
- Configure storage (S3, Azure Blob for LFS, Actions artifacts)

### Key GHES CLI Commands

```bash
# Apply configuration changes made in Management Console
ghe-config-apply

# Check overall system status
ghe-check-disk-usage

# List all registered users
ghe-user-list

# Promote a user to site admin
ghe-user-promote USERNAME

# Demote a site admin
ghe-user-demote USERNAME

# Suspend a user
ghe-user-suspend USERNAME

# Generate diagnostic bundle
ghe-diagnostics

# Check license
ghe-license

# View current GHES version
/usr/local/share/enterprise/ghe-version

# Run LDAP sync
ghe-ldap-sync

# Access Rails console (advanced troubleshooting)
ghe-rails-console
```

---

## 3.3 GHES High Availability

### HA Architecture

GHES HA consists of two appliances:
1. **Primary**: Handles all read and write requests
2. **Replica**: Continuously receives replicated data from primary; handles some read requests

```
Users/Admins
     |
     v
Primary GHES (active) ---------> Replica GHES (standby)
     |                           (near-real-time replication)
     v
All data lives on primary; replica is always-ready for failover
```

### Setting Up HA Replication

```bash
# On the REPLICA appliance:
# 1. Configure the replica to replicate from primary
ghe-repl-setup PRIMARY_IP_OR_HOSTNAME

# 2. Start replication
ghe-repl-start

# 3. Check replication status
ghe-repl-status

# Output shows replication lag for each component (git, DB, storage)
```

### Failover Process

If the primary fails:
```bash
# On the replica, promote it to primary
ghe-repl-promote

# This stops replication and makes the replica the new primary
# Update DNS to point to the replica's IP
# Users can now access the (formerly replica) appliance as primary
```

### Geo-Replication

Multiple replicas in different geographic regions allow reads to be served locally:
- Reduces latency for distributed teams
- Each region has a replica
- Writes still go to the primary
- Available as part of GitHub Enterprise licensing

---

## 3.4 GHES Backup and Restore

### github-backup-utils

The official backup solution for GHES. Must be run from a separate Linux host (not the GHES appliance itself).

```bash
# Install backup utilities (on separate backup host)
git clone https://github.com/github/backup-utils.git
cd backup-utils

# Configure backup settings
cp backup.config-example backup.config
# Edit backup.config:
#   GHE_HOSTNAME="your-ghes-hostname"
#   GHE_DATA_DIR="/mnt/backup/ghes"
#   GHE_EXTRA_SSH_OPTS="-i /path/to/backup-key"

# Run a backup
./bin/ghe-backup

# Restore from backup (on a clean GHES appliance)
./bin/ghe-restore BACKUP_SNAPSHOT_DIR
```

### What Is Included in a GHES Backup

| Data | Included |
|------|---------|
| Git repository data | Yes |
| GitHub Enterprise configuration | Yes |
| MySQL database (issues, PRs, users) | Yes |
| Storage assets (LFS, attachments) | Yes |
| Actions artifacts | Optional (large, may exclude) |
| License | Yes |
| SSL certificates | Yes |

### Backup Best Practices

- Run backups to a separate host (not GHES itself)
- Minimum frequency: every 24 hours
- Test restore procedures quarterly
- Store backups off-site (separate location from GHES)
- Monitor backup job success/failure

---

## 3.5 GHES Upgrades

### Upgrade Methods

| Method | When to Use | Downtime |
|--------|-------------|---------|
| Hotpatch | Minor/patch versions (e.g., 3.10.1 -> 3.10.2) | Minimal (minutes) |
| Full upgrade package | Major/minor versions (e.g., 3.9.x -> 3.10.x) | Significant (30-60+ min) |

### Upgrade Process (Full Package)

1. Download upgrade package from `enterprise.github.com`
2. Upload package via Management Console or SCP to appliance
3. Verify upgrade prerequisites (free disk space, backup completed)
4. Enter maintenance mode (Management Console > Maintenance)
5. Apply upgrade: `ghe-upgrade PATH_TO_PACKAGE`
6. Wait for services to restart
7. Verify functionality
8. Exit maintenance mode

### Upgrade Path Rules

- **Cannot skip major versions**: To upgrade from 3.8 to 3.10, you must go 3.8 -> 3.9 -> 3.10
- Release candidates (RC) are for testing only — do not upgrade production to RC
- Always run a backup before upgrading

### Release Channels

| Channel | Stability | Use For |
|---------|-----------|---------|
| GA (General Availability) | Stable | Production |
| RC (Release Candidate) | Beta | Testing/pre-production |
| Hotpatch | Critical fixes | Apply immediately to GA release |

---

## 3.6 GitHub Licensing

### Licensing Model

GitHub Enterprise uses **per-seat licensing**. Each unique user who consumes access to GitHub resources counts as one seat.

### What Counts as a Seat?

A seat is consumed by:
- Any user who is a member of an organization in the enterprise
- Any user who is an enterprise owner or billing manager
- Outside collaborators who access private/internal repositories (may count)

A seat is NOT counted separately for:
- A user who belongs to multiple organizations (still one seat total)
- Suspended users (suspended users do not consume seats)
- Bot accounts marked as machine users (configuration-dependent)

### License Sync (GHES with GitHub Connect)

When GHES is connected to GitHub.com via GitHub Connect, license usage automatically syncs every 24 hours. This ensures accurate counting when users access both GHES and GHEC.

```bash
# Check current license usage on GHES
ghe-license
```

### GitHub Enterprise Bundle

A GitHub Enterprise license includes:
- GitHub Enterprise Cloud (GHEC) — org(s) on GitHub.com
- GitHub Enterprise Server (GHES) — self-hosted appliance

Both are covered under the same per-seat count.

---

## 3.7 GitHub Connect

### What Is GitHub Connect?

GitHub Connect establishes a secure, outbound connection from a GHES instance to GitHub.com. It does not require opening inbound ports.

### Features Enabled by GitHub Connect

| Feature | What It Does |
|---------|-------------|
| License sync | GHES license data syncs to GitHub.com (deduplicates seat counts) |
| Unified search | Search GitHub.com public repos from GHES search |
| GitHub Sponsors | Allow GHES users to access GitHub Sponsors |
| Actions version pinning | Use Actions from GitHub.com Marketplace in GHES workflows |
| Dependabot alerts | Use GitHub Advisory Database for Dependabot on GHES |

### Configuring GitHub Connect

1. On GitHub.com: Create an enterprise on GitHub.com that will be linked
2. On GHES Management Console: Enable GitHub Connect
3. Sign in with the GitHub.com enterprise account
4. Enable specific features (license sync, unified search, etc.)

---

## Common Admin Tasks

### Checking GHES System Status

```bash
# SSH into GHES admin shell
ssh -p 122 admin@GHES_HOSTNAME

# Check service status
ghe-check-disk-usage
nomad status   # If using clustering

# View resource utilization
ghe-stats
```

### Entering and Exiting Maintenance Mode

```bash
# Enter maintenance mode (via CLI)
ghe-maintenance -s

# Enter maintenance mode with a scheduled time
ghe-maintenance -s -t "2026-01-15 02:00 UTC"

# Exit maintenance mode
ghe-maintenance -u

# Or via Management Console: Admin > Maintenance
```

---

## Gotchas and Exam Tips

1. **GHES has no GitHub-hosted runners**. Self-hosted runners are the only option for Actions on GHES. If a question asks about GitHub-hosted runners and the scenario describes an on-premises deployment, the answer is "not available."

2. **Upgrade path must be sequential**. You cannot skip major versions. Questions about "upgrading from 3.7 to 3.10" require going through 3.8, 3.9.

3. **HA failover is manual by default**. The replica does not automatically become primary when the primary fails — an admin must run `ghe-repl-promote`. Automatic failover requires additional configuration with a load balancer.

4. **GitHub AE is deprecated**. If a question mentions GitHub AE as a current deployment option, it is a distractor. The current options are GHEC and GHES.

5. **License seat counting is deduplicated**. A user in 5 organizations counts as one seat. This is a common misunderstanding.

6. **Suspended users don't count as seats**. If a user needs to keep their account but stop consuming a seat, suspend them (GHES only).

7. **Management Console is port 8443**. Web (HTTP/HTTPS) is port 80/443; admin console is 8443. SSH admin shell is port 122.

8. **GitHub Connect requires outbound internet access from GHES**. Air-gapped GHES instances cannot use GitHub Connect.

---

## Practice Questions

### Question 1
**Domain**: Domain 3 — Deployment & Licensing
**Topic**: GHEC vs GHES selection
**Difficulty**: Intermediate

A financial services company requires that all source code remain within their own data center and never traverses the public internet. They also need to integrate with their existing on-premises Active Directory for authentication. Which GitHub deployment model meets these requirements?

A. GitHub Enterprise Cloud (GHEC) with SAML SSO configured
B. GitHub Enterprise Cloud (GHEC) with IP allow lists
C. GitHub Enterprise Server (GHES)
D. GitHub.com Team plan with private repositories

<details>
<summary>Answer</summary>

**Correct Answer: C**

**Explanation**: Only **GitHub Enterprise Server (GHES)** satisfies both requirements. GHES is deployed within the customer's data center, ensuring code never leaves their network. GHES also supports LDAP authentication, which can integrate directly with Active Directory. GHEC (options A and B) is hosted on GitHub's servers, so code does leave the customer's network regardless of SSO or IP allow lists. GHEC does support SAML SSO but NOT LDAP. GitHub.com Team plan (option D) is cloud-hosted and does not support LDAP.

**Reference**: https://docs.github.com/en/enterprise-server@latest/admin/overview/about-github-enterprise-server

</details>

---

### Question 2
**Domain**: Domain 3 — Deployment & Licensing
**Topic**: GHES HA and failover
**Difficulty**: Intermediate

A GHES administrator has configured high availability with a primary and replica appliance. The primary appliance experiences a hardware failure and becomes unresponsive. What must the administrator do to restore service?

A. GitHub automatically fails over to the replica; no action needed
B. Run `ghe-repl-promote` on the replica appliance to promote it to primary
C. Run `ghe-repl-failover` on the primary appliance
D. Restore from the most recent backup onto the replica appliance

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: GHES High Availability does NOT automatically fail over. When the primary fails, an administrator must manually promote the replica to primary by running `ghe-repl-promote` on the replica appliance. This command stops replication, disassociates the replica mode, and makes the appliance operate as a standalone primary. The administrator then updates DNS to point users to the replica's IP address. Option A is incorrect — failover is manual. Option C is incorrect — you cannot run commands on an unresponsive primary. Option D is incorrect — restoring from backup is a recovery method, not a failover method, and would take much longer.

**Reference**: https://docs.github.com/en/enterprise-server@latest/admin/enterprise-management/configuring-high-availability/initiating-a-failover-to-your-replica-appliance

</details>

---

### Question 3
**Domain**: Domain 3 — Deployment & Licensing
**Topic**: GHES licensing
**Difficulty**: Beginner

An enterprise has 500 licensed seats for GitHub Enterprise. They have one GHES instance and one GHEC organization. Of the 500 users, 300 use only GHES, 150 use only GHEC, and 50 use both GHES and GHEC. How many seats does this enterprise consume?

A. 550 (300 + 150 + 50 + 50)
B. 500 (300 + 150 + 50)
C. 450 (300 + 150)
D. 500 with 100 seats of overlap counted twice

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: GitHub Enterprise licensing is **per unique user**. The 50 users who use both GHES and GHEC each consume ONE seat, not two. Total seats consumed: 300 (GHES only) + 150 (GHEC only) + 50 (both) = 500 unique users = 500 seats. GitHub Connect (when configured) enables license deduplication by syncing usage data between GHES and GitHub.com, ensuring users who access both platforms are not double-counted.

**Reference**: https://docs.github.com/en/billing/managing-the-plan-for-your-github-account/about-per-user-pricing

</details>

---

### Question 4
**Domain**: Domain 3 — Deployment & Licensing
**Topic**: GitHub Connect features
**Difficulty**: Intermediate

A company runs GitHub Enterprise Server 3.10 on-premises. Their developers want to use GitHub Actions workflows that reference publicly available actions from GitHub Marketplace (e.g., `actions/checkout@v4`). The GHES instance is connected to GitHub.com via GitHub Connect. Which GitHub Connect feature enables this?

A. License sync
B. Actions version pinning
C. Unified search
D. Dependabot alerts

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: **Actions version pinning** is the GitHub Connect feature that allows GHES Actions workflows to reference and use actions from GitHub.com's Marketplace. Without GitHub Connect (or without enabling this feature), GHES workflows can only use actions hosted on that GHES instance. With Actions version pinning enabled, GHES caches copies of the referenced marketplace actions. License sync (A) is for seat count reconciliation. Unified search (C) enables searching GitHub.com repos from GHES. Dependabot alerts (D) enables the GitHub Advisory Database for GHES.

**Reference**: https://docs.github.com/en/enterprise-server@latest/admin/configuring-settings/configuring-github-connect/enabling-automatic-access-to-githubcom-actions-using-github-connect

</details>

---

### Question 5
**Domain**: Domain 3 — Deployment & Licensing
**Topic**: GHES backup
**Difficulty**: Beginner

Where should the github-backup-utils tool be installed and run from?

A. Directly on the GHES virtual appliance
B. On a separate Linux host with network access to the GHES appliance
C. On any Windows Server with SSH access to GHES
D. On the GHES replica appliance

<details>
<summary>Answer</summary>

**Correct Answer: B**

**Explanation**: The `github-backup-utils` tool must be installed and run from a **separate Linux host**, not on the GHES appliance itself. Running backups on the appliance would consume its resources and defeat the purpose of having a backup if the appliance itself fails. The backup host needs SSH access (port 122) to the GHES appliance and sufficient storage. Option A is incorrect for the reasons above. Option C is incorrect — the tool requires a Linux environment. Option D is incorrect — the replica is a replication target, not a backup host, and using it for backups would co-locate backup and replica on the same risk boundary.

**Reference**: https://github.com/github/backup-utils

</details>

---

## Official Documentation Links

- [About GitHub Enterprise Cloud](https://docs.github.com/en/enterprise-cloud@latest/admin/overview/about-github-enterprise-cloud)
- [About GitHub Enterprise Server](https://docs.github.com/en/enterprise-server@latest/admin/overview/about-github-enterprise-server)
- [GHES High Availability](https://docs.github.com/en/enterprise-server@latest/admin/enterprise-management/configuring-high-availability)
- [github-backup-utils](https://github.com/github/backup-utils)
- [Upgrading GHES](https://docs.github.com/en/enterprise-server@latest/admin/upgrading-your-instance)
- [GitHub Connect](https://docs.github.com/en/enterprise-server@latest/admin/configuring-settings/configuring-github-connect/about-github-connect)
- [GitHub per-user pricing](https://docs.github.com/en/billing/managing-the-plan-for-your-github-account/about-per-user-pricing)
