# Unified DNS configuration (provider v0.22.0+).
# Manages nameservers, MagicDNS, override local DNS, and exit node
# behaviour in a single resource. Replaces the older separate resources
# (tailscale_dns_nameservers + tailscale_dns_preferences).
#
# NextDNS profile: 4d9ce5
# Tailscale automatically upgrades these IPv6 addresses to DNS-over-HTTPS.
# Reference: https://tailscale.com/docs/integrations/nextdns
#
# NOTE: tailscale_dns_configuration is relatively new. If `terraform plan`
# shows schema errors, check the provider docs and fall back to the
# commented-out individual resources below.
#
# This resource conflicts with tailscale_dns_nameservers,
# tailscale_dns_preferences, tailscale_dns_search_paths, and
# tailscale_dns_split_nameservers — do not use them simultaneously.

resource "tailscale_dns_configuration" "this" {
  override_local_dns = true
  magic_dns          = true

  nameservers {
    address            = "2a07:a8c0::4d:9ce5"
    use_with_exit_node = true
  }

  nameservers {
    address            = "2a07:a8c1::4d:9ce5"
    use_with_exit_node = true
  }
}

# --- Fallback: individual resources (uncomment if dns_configuration fails) ---
#
# resource "tailscale_dns_nameservers" "nextdns" {
#   nameservers = [
#     "2a07:a8c0::4d:9ce5",
#     "2a07:a8c1::4d:9ce5",
#   ]
# }
#
# resource "tailscale_dns_preferences" "this" {
#   magic_dns = true
# }
#
# The fallback resources do NOT support override_local_dns or
# use_with_exit_node — set those via the admin console if needed:
#   https://login.tailscale.com/admin/dns
