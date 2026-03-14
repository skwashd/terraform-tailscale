# Tailscale Terraform Configuration

Manages the `tail8bf2d.ts.net` tailnet (ID: `TW2aHhRyS151CNTRL`) using the
[official Tailscale Terraform provider](https://registry.terraform.io/providers/tailscale/tailscale/latest).

## What's managed

| Resource | File | Description |
|---|---|---|
| ACL policy | `acl.tf` | Grants, SSH rules |
| DNS | `dns.tf` | NextDNS (DoH) nameservers, MagicDNS, override local DNS, use with exit node |
| Tailnet settings | `tailnet_settings.tf` | Device/user approval, auto-updates |
| Device authorization | `devices.tf` | All 9 devices authorized |
| Device tags | `devices.tf` | `tag:trusted` — personal devices (full tailnet + exit node access); `tag:node` — infrastructure devices (exit node egress only) |
| Subnet routes | `devices.tf` | homeassistant (exit node), homeassistant-home (subnet + exit) |
| Device keys | `devices.tf` | homeassistant key expiry disabled |

## Prerequisites

1. **Terraform >= 1.5.0**
2. **OAuth client** — create one in the [admin console](https://login.tailscale.com/admin/settings/oauth) with scopes: `acl`, `devices`, `dns`, `settings` (read+write)
3. **1Password CLI (beta)** — used to inject credentials as environment variables via `op run`

## Getting started

```bash
# 1. Initialize
terraform init

# 2. Preview the  any diffs
op run --environment <ENV-ID> -- terraform plan

# 3. Apply changes
op run --environment <ENV-ID> -- terraform apply
```

## New Devices

- New devices still need to be added to `devices.tf` manually (or use `for_each` over a variable).

## Manual steps required

- **homeassistant subnet routes**: The routes `172.16.66.0/23` and `fdb5:1c81:e08:4c37::/64` are advertised but currently unapproved. Uncomment them in `devices.tf` to approve.
- **dns_configuration fallback**: If `tailscale_dns_configuration` produces schema errors during plan, fall back to the individual resources commented out in `dns.tf` and set "Override local DNS" + "Use with exit node" via the admin console.