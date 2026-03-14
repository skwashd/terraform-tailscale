# The tailscale_acl resource manages the entire tailnet policy file.
# Changes here affect network access for all devices.
#
# Reference: https://tailscale.com/kb/1018/acls

resource "tailscale_acl" "this" {
  acl = jsonencode({

    # Tags and their owners. Only admins may apply these tags to devices.
    tagOwners = {
      "tag:trusted" = ["autogroup:admin"]
      "tag:node"    = ["autogroup:admin"]
    }

    # Access grants - controls which devices and users can connect.
    grants = [
      # Trusted personal devices can connect to anything on any port,
      # including using exit nodes for internet egress.
      {
        src = ["tag:trusted"]
        dst = ["tag:trusted", "tag:node", "autogroup:internet"]
        ip  = ["*"]
      },
      # Infrastructure/node devices may only use exit nodes for internet egress.
      # autogroup:internet covers exit-node-routed traffic without permitting
      # direct tailnet device-to-device connections.
      {
        src = ["tag:node"]
        dst = ["autogroup:internet"]
        ip  = ["*"]
      },
    ]

    # Tailscale SSH access rules.
    # Trusted personal devices may SSH into infrastructure/node devices only.
    ssh = [
      {
        action = "accept"
        src    = ["tag:trusted"]
        dst    = ["tag:node"]
        users  = ["autogroup:nonroot", "root"]
      },
    ]
  })
}
