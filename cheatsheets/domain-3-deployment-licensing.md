# Domain 3 Cheatsheet

- GHES is a virtual appliance and uses the Management Console on port `8443`.
- HA uses primary plus replica; promotion is manual unless additional failover design is added.
- Backups use `github-backup-utils` from a separate host.
- GitHub Connect enables license sync, unified search, and Actions version pinning.
- GHEC and GHES both consume enterprise seats; unique users count once with sync.
- Know GHEC vs GHES trade-offs: control, sovereignty, auth models, maintenance.
