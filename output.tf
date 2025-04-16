output "debug_flattened_records" {
  value = local.all_records
}

output "debug_zones" {
  value = var.zones
}

output "zone_names" {
  value = [for name, zone in var.zones : name]
}
