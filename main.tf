terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

locals {
  all_records = flatten([
    for zone_name, zone in var.zones : [
      for record in zone.records : {
        zone_name = zone_name
        name      = record.name
        content   = lookup(record, "content", null)
        type      = coalesce(lookup(record, "type", null), "A")
        ttl       = lookup(record, "ttl", 300)
        proxied   = lookup(record, "proxied", false)
        priority  = lookup(record, "priority", null)
        comment   = coalesce(lookup(record, "comment", null), "Managed by terraform")

        # NEW: pass-through optional 'data' map for advanced records (SRV/CAA/TLSA/LOC/etc.)
        data = lookup(record, "data", null)

        # NEW: normalized 'settings' (all optional)
        settings = {
          flatten_cname = try(record.settings.flatten_cname, null)
          ipv4_only     = try(record.settings.ipv4_only, null)
          ipv6_only     = try(record.settings.ipv6_only, null)
        }

        # include everything in the hash so changes to data/settings trigger updates
        name_content_hash = md5(jsonencode({
          zone_name = zone_name
          name      = record.name
          type      = coalesce(lookup(record, "type", null), "A")
          content   = lookup(record, "content", null)
          ttl       = lookup(record, "ttl", 300)
          proxied   = lookup(record, "proxied", false)
          priority  = lookup(record, "priority", null)
          comment   = coalesce(lookup(record, "comment", null), "Managed by terraform")
          data      = lookup(record, "data", null)
          settings = {
            flatten_cname = try(record.settings.flatten_cname, null)
            ipv4_only     = try(record.settings.ipv4_only, null)
            ipv6_only     = try(record.settings.ipv6_only, null)
          }
        }))
      }
    ]
  ])
}

resource "cloudflare_zone" "zones" {
  for_each = var.zones

  name = each.key
  account = {
    id = var.account_id
  }
  type = each.value.zone_type
}

resource "cloudflare_dns_record" "records" {
  for_each = {
    for rec in local.all_records :
    "${rec.zone_name}-${rec.name}-${rec.type}-${rec.name_content_hash}" => rec
  }

  zone_id = cloudflare_zone.zones[each.value.zone_name].id
  name    = each.value.name
  type    = each.value.type

  # For simple records (A/AAAA/CNAME/TXT/MX/etc.) use 'content' when provided.
  # For advanced types (SRV/CAA/TLSA/LOC/URI/etc.), set 'data' instead (below).
  content = each.value.content

  ttl     = each.value.ttl != null ? each.value.ttl : 300
  proxied = each.value.proxied
  comment = each.value.comment

  # MX priority only when relevant
  priority = each.value.type == "MX" && each.value.priority != null ? each.value.priority : null

  # NEW: provide 'data' only when caller supplied it
  data = each.value.data == null ? null : each.value.data

  # send `settings` only if at least one key is set
  settings = (
    length([
      for v in {
        flatten_cname = try(each.value.settings.flatten_cname, null)
        ipv4_only     = try(each.value.settings.ipv4_only, null)
        ipv6_only     = try(each.value.settings.ipv6_only, null)
      } : v if v != null
    ]) == 0
    ? null
    : {
      for k, v in {
        flatten_cname = try(each.value.settings.flatten_cname, null)
        ipv4_only     = try(each.value.settings.ipv4_only, null)
        ipv6_only     = try(each.value.settings.ipv6_only, null)
      } : k => v if v != null
    }
  )
}
