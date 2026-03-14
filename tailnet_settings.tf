# Tailnet-wide settings.
# Reference: https://tailscale.com/api#tag/tailnetsettings
resource "tailscale_tailnet_settings" "this" {
  devices_approval_on      = true
  devices_auto_updates_on  = true
  users_approval_on        = true
}
