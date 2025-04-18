terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.2.0"
    }
  }
}

locals {
  all_records = flatten([
    for zone_name, zone in var.zones : [
      for record in zone.records : {
        zone_name = zone_name
        name      = record.name
        content   = record.content
        type      = coalesce(record.type, "A")
        ttl       = lookup(record, "ttl", 300)
        proxied   = lookup(record, "proxied", false)
        priority  = lookup(record, "priority", null)
        comment   = coalesce(record.comment, "Managed by terraform" )
        name_content_hash = md5("${record.name}-${record.content}")
      }
    ]
  ])
}

resource "cloudflare_zone" "zones" {
  for_each = var.zones
  name       = each.key
  account = {
    id = var.account_id
  }
  type       = each.value.zone_type
}

resource "cloudflare_dns_record" "records" {
  for_each = {
    for idx, rec in local.all_records :
    "${rec.zone_name}-${rec.name}-${rec.type}-${rec.name_content_hash}" => rec
  }

  zone_id = cloudflare_zone.zones[each.value.zone_name].id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = each.value.ttl != null ? each.value.ttl : 300
  proxied = each.value.proxied
  comment = each.value.comment
  priority = each.value.type == "MX" && each.value.priority != null ? each.value.priority : null
}
