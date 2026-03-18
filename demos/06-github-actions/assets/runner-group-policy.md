# Runner Group Policy Example

- Group name: `prod-runners`
- Scope: Enterprise
- Allowed organizations: `org-platform`, `org-payments`
- Default visibility: Selected organizations only
- Runner type: Ephemeral Linux x64
- Network policy: Outbound HTTPS only through enterprise proxy
- Usage rule: No public repositories
