# Demo Lab 03 — GitHub Deployment Options Exploration

**Domain Coverage**: Domain 3 (Deployment, Distribution, and Licensing)
**Prerequisites**: GitHub Enterprise Cloud account, (Optional) VMware/cloud access for GHES
**Estimated Time**: 60-90 minutes

---

## Learning Objectives

After completing this lab, you will be able to:
- Compare GitHub Enterprise Cloud and GitHub Enterprise Server feature sets
- Navigate GHES Management Console (if access is available)
- Understand GHES high availability concepts
- Configure GitHub Connect
- Interpret license usage reports
- Understand GHES backup procedures

---

## Lab Options

This lab has two tracks:

**Track A** (Recommended for most candidates): GHEC exploration — available to anyone with a GHEC enterprise account.

**Track B** (Optional, requires GHES instance): GHES-specific hands-on exercises.

---

## Exercise 1 — GHEC Feature Exploration

### 1.1 Map Enterprise Settings to Feature Categories

Visit your GHEC enterprise settings and map each setting to its Domain 3 concept:

| Enterprise Setting | Domain 3 Concept |
|-------------------|-----------------|
| `Enterprise > Organizations` | Multi-org enterprise management |
| `Enterprise > Policies` | Enterprise-level policy enforcement |
| `Enterprise > Billing > License` | Per-seat licensing |
| `Enterprise > Settings > GitHub Connect` | GHES-to-GHEC bridge |
| `Enterprise > Authentication security` | Enterprise auth policies |

### 1.2 Review License Usage

1. Navigate to: `Enterprise Settings > Billing > License`
2. Review:
   - Total licensed seats
   - Seats consumed
   - Download the license usage CSV
3. Open the CSV and identify:
   - Users with "last active" dates older than 90 days (possible unused seats)
   - Users appearing in multiple organizations (correctly counted as one seat)

### 1.3 Review GitHub Connect Status

1. Navigate to: `Enterprise Settings > GitHub Connect`
2. Note which features are enabled/disabled:
   - License sync
   - Unified search
   - GitHub Sponsors

**If GitHub Connect is not configured** (common for lab environments):
Note that GitHub Connect would be configured here when linking a GHES instance to GHEC.

---

## Exercise 2 — Understanding GHES Architecture (Conceptual)

If you don't have a GHES instance, complete this exercise conceptually by reviewing the official architecture documentation.

### 2.1 Review GHES System Requirements

Reference: https://docs.github.com/en/enterprise-server@latest/admin/installation/setting-up-a-github-enterprise-server-instance

Fill in the minimum requirements:

| Resource | Minimum (1-499 users) | Production Recommended |
|----------|----------------------|----------------------|
| vCPUs | _____ | _____ |
| RAM | _____ | _____ |
| Storage (root) | _____ | _____ |
| Storage (data) | _____ | _____ |

### 2.2 Map GHES Features Not Available on GHEC

Create your own comparison matrix:

| Feature | GHEC | GHES |
|---------|------|------|
| LDAP authentication | | |
| CAS authentication | | |
| Built-in authentication | | |
| SAML SSO | | |
| GitHub-hosted Actions runners | | |
| Self-hosted Actions runners | | |
| Air-gapped deployment | | |
| Management Console | | |
| High availability replication | | |
| Data sovereignty (no GitHub cloud) | | |

---

## Exercise 3 — GHES Management Console (If Available)

If you have access to a GHES instance:

### 3.1 Access the Management Console

```bash
# GHES Management Console is at:
# https://YOUR_GHES_HOSTNAME:8443

# Default admin credentials are set during initial configuration
```

1. Navigate to `https://YOUR_GHES_HOSTNAME:8443`
2. Log in with the Management Console password

### 3.2 Explore Management Console Sections

| Section | What to Check |
|---------|-------------|
| Business information | Instance name, license |
| Authentication | SAML, LDAP, or built-in |
| Email | SMTP configuration |
| Security | TLS certificate, HTTPS settings |
| Services | Which services are enabled (Actions, GHAS, etc.) |
| Maintenance | Enable/disable maintenance mode |
| Management Console logs | Recent configuration events |

### 3.3 Check GHES Version and License

```bash
# SSH into GHES admin shell (port 122)
ssh -p 122 admin@YOUR_GHES_HOSTNAME

# Check current GHES version
/usr/local/share/enterprise/ghe-version

# Check license information
ghe-license

# Check disk usage
ghe-check-disk-usage

# List site admins
ghe-user-list | grep "site_admin"
```

### 3.4 Review High Availability Status

If HA is configured:
```bash
# Check replication status from the primary or replica
ghe-repl-status

# Sample output shows replication lag for each component:
# mysql        OK    0 seconds behind primary
# redis        OK    0 seconds behind primary
# elasticsearch OK   0 seconds behind primary
# git          OK    0 seconds behind primary
```

---

## Exercise 4 — GHES Backup Concepts

### 4.1 Understand the backup-utils Repository

Review the official backup-utils repository:
```bash
# Clone backup-utils (on a SEPARATE Linux host, not GHES)
git clone https://github.com/github/backup-utils.git
cd backup-utils

# Review the backup configuration file
cat backup.config-example
```

### 4.2 Understand Backup Components

Review what `ghe-backup` captures:
```
backup-snapshot/
├── current -> 20260303T120000
└── 20260303T120000/
    ├── audit-log/            # Audit log data
    ├── authorized-keys.json  # SSH keys
    ├── elasticsearch/        # Search index data
    ├── git/                  # All Git repository data
    ├── hookshot/             # Webhook deliveries
    ├── mysql/                # Database (users, issues, PRs, etc.)
    ├── redis/                # Cache data
    ├── repositories/         # Repository data
    ├── settings.json         # GHES configuration
    └── storage/              # LFS, attachments
```

### 4.3 Practice Backup Configuration

Even without running a backup, practice the configuration:

```bash
# Edit backup.config
cat > /tmp/sample-backup.config << 'EOF'
# backup-utils configuration

# Required: GHES hostname or IP
GHE_HOSTNAME="ghes.company.internal"

# Required: Where to store backups
GHE_DATA_DIR="/mnt/backup/ghes-backup"

# Optional: Number of backup copies to retain
GHE_NUM_SNAPSHOTS=7

# Optional: SSH key for backup connections
GHE_EXTRA_SSH_OPTS="-i /home/backup-user/.ssh/ghes_backup_key"

# Optional: Parallel backup operations
GHE_PARALLEL_RSYNC=true
EOF
cat /tmp/sample-backup.config
```

---

## Exercise 5 — GHES Upgrade Planning

### 5.1 Review Current GHES Release Notes

Visit: https://enterprise.github.com/releases

1. Note the current latest GA release
2. Identify the prior version (you would need to be on this to upgrade)
3. Check the release notes for breaking changes

### 5.2 Plan an Upgrade Path

Given: Current version 3.9.5, Target version 3.11.x

Determine the required upgrade path:
```
Step 1: 3.9.5 → 3.10.x (latest patch on 3.10)
Step 2: 3.10.x → 3.11.x
```

**Rule**: Major version upgrades must be done sequentially. You CANNOT jump from 3.9 to 3.11.

### 5.3 Pre-Upgrade Checklist

Create a mental checklist for before any GHES upgrade:
- [ ] Take a full backup with backup-utils
- [ ] Check free disk space (upgrade requires 2x the size of the upgrade package)
- [ ] Review the upgrade guide for breaking changes
- [ ] Schedule a maintenance window
- [ ] Notify users of expected downtime
- [ ] Test the upgrade in a staging environment first
- [ ] Have a rollback plan (restore from backup)

---

## Exercise 6 — GitHub Connect Configuration (Conceptual)

### 6.1 Understand GitHub Connect Requirements

For GHES to connect to GitHub.com via GitHub Connect:

| Requirement | Detail |
|-------------|--------|
| Outbound internet from GHES | TCP 443 to github.com, api.github.com |
| GitHub.com enterprise account | That the GHES license is associated with |
| GHES admin access | Site admin + Management Console |
| GHEC enterprise owner | To authorize the connection |

### 6.2 Enable GitHub Connect Features (Conceptual Walk-Through)

In GHES Management Console:
1. Go to **Settings > GitHub Connect**
2. Click **Enable GitHub Connect**
3. Authenticate with your GitHub.com enterprise account
4. Enable specific features:
   - **License sync**: Yes — ensures accurate license counting
   - **Unified search**: Optional — search GitHub.com from GHES
   - **Actions version pinning**: Yes if using marketplace actions in GHES

---

## Lab Checkpoint Questions

1. What is the minimum GHES node size for a production deployment with 500 users?
2. Which authentication methods are available on GHES but NOT on GHEC?
3. What is the purpose of the Management Console, and what port does it run on?
4. What tool is used to back up GHES, and where should it be installed?
5. If you have GHES 3.8.x and want to upgrade to 3.11.x, what is the correct upgrade path?
6. What does GitHub Connect enable? List at least 3 features.
7. In the per-seat licensing model, if a user is a member of 3 organizations in the same enterprise, how many seats do they consume?

---

## Key Takeaways

- GHEC = GitHub-managed; GHES = Customer-managed (full data sovereignty)
- GHES supports LDAP and CAS — GHEC does not
- GHES has no GitHub-hosted runners — only self-hosted
- GHES Management Console = `port 8443` (admin shell = `port 122`)
- Backups must run from a SEPARATE host, not the GHES appliance
- Major version upgrades must be sequential — cannot skip versions
- Per-seat licensing counts unique users across all orgs (no double-counting)
- GitHub Connect enables GHES to use GitHub.com features (marketplace actions, license sync)

---

## Cleanup

This lab is mostly read-only. If you:
- Modified any GHEC settings: revert them
- Created test artifacts in GHES: clean up
- Downloaded any backup config files: delete when done
