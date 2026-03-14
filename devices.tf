# =============================================================================
# Device data sources
# =============================================================================
# Data sources look up devices by their FQDN to get stable node_id references.

locals {
  tailnet_domain = "tail8bf2d.ts.net"

  # Trusted personal devices: full access to all tailnet devices and ports.
  trusted_devices = toset(["skwashd_ipad_a4", "skwashd_iphone17pm", "skwashd_mbp_m4m"])

  # Infrastructure/node devices: exit-node internet egress only.
  node_devices = toset(["homeassistant", "homeassistant_home", "cc_node1", "gl_axt1800", "nas1", "skwashd_mbp14m2"])

  devices = {
    homeassistant      = "homeassistant"
    homeassistant_home = "homeassistant-home"
    cc_node1           = "cc-node1"
    gl_axt1800         = "gl-axt1800"
    nas1               = "nas1"
    skwashd_ipad_a4    = "skwashd-ipad-a4"
    skwashd_iphone17pm = "skwashd-iphone17pm"
    skwashd_mbp_m4m    = "skwashd-mbp-m4m"
    skwashd_mbp14m2    = "skwashd-mbp14m2"
  }
}

data "tailscale_device" "this" {
  for_each = local.devices
  name     = "${each.value}.${local.tailnet_domain}"
  wait_for = "30s"
}

# =============================================================================
# Device authorization
# =============================================================================
# All existing devices are authorized. New devices require manual approval
# (devices_approval_on = true in tailnet_settings).

resource "tailscale_device_authorization" "this" {
  for_each   = local.devices
  device_id  = data.tailscale_device.this[each.key].node_id
  authorized = true
}

# =============================================================================
# Subnet routes and exit nodes
# =============================================================================
# Routes must be both advertised by the device AND approved here.
# Advertised routes are managed on the device itself, not through Terraform.

# homeassistant - exit node (approved)
# NOTE: This device also advertises 172.16.66.0/23 and fdb5:1c81:e08:4c37::/64
# but those routes are currently UNAPPROVED. Uncomment below to approve them.
resource "tailscale_device_subnet_routes" "homeassistant" {
  device_id = data.tailscale_device.this["homeassistant"].node_id
  routes = [
    # Exit node routes (currently approved)
    "0.0.0.0/0",
    "::/0",
    # Subnet routes (currently unapproved - uncomment to approve)
    # "172.16.66.0/23",
    # "fdb5:1c81:e08:4c37::/64",
  ]
}

# homeassistant-home - subnet router + exit node (all approved)
resource "tailscale_device_subnet_routes" "homeassistant_home" {
  device_id = data.tailscale_device.this["homeassistant_home"].node_id
  routes = [
    "192.168.243.0/24",
    # Exit node routes
    "0.0.0.0/0",
    "::/0",
  ]
}

# =============================================================================
# Device key management
# =============================================================================

# homeassistant - key expiry disabled (device cannot re-authenticate)
resource "tailscale_device_key" "homeassistant" {
  device_id           = data.tailscale_device.this["homeassistant"].node_id
  key_expiry_disabled = true
}

# =============================================================================
# Device tags
# =============================================================================
# Tags are used to control access via the ACL policy in acl.tf.
# depends_on ensures the tagOwners policy is committed before devices are tagged.

resource "tailscale_device_tags" "trusted" {
  for_each  = local.trusted_devices
  device_id = data.tailscale_device.this[each.key].node_id
  tags      = ["tag:trusted"]

  depends_on = [tailscale_acl.this]
}

resource "tailscale_device_tags" "node" {
  for_each  = local.node_devices
  device_id = data.tailscale_device.this[each.key].node_id
  tags      = ["tag:node"]

  depends_on = [tailscale_acl.this]
}
