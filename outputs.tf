output "device_ips" {
  description = "Tailscale IP addresses for each device"
  value       = { for k, d in data.tailscale_device.this : k => d.addresses }
}

output "tailnet_domain" {
  description = "The tailnet DNS domain"
  value       = local.tailnet_domain
}
