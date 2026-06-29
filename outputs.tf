output "zone_ids" {
  description = "Map of zone name => Cloudflare zone ID."
  value       = { for name, zone in cloudflare_zone.zones : name => zone.id }
}

output "name_servers" {
  description = "Map of zone name => Cloudflare-assigned name servers (set these at your registrar)."
  value       = { for name, zone in cloudflare_zone.zones : name => zone.name_servers }
}

output "record_ids" {
  description = "Map of record key => Cloudflare DNS record ID."
  value       = { for key, record in cloudflare_dns_record.records : key => record.id }
}
