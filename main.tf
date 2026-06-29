locals {
  all_records = flatten([
    for zone_name, zone in var.zones : [
      for record in zone.records : {
        zone_name         = zone_name
        slug              = record.slug
        name              = record.name
        content           = record.content
        type              = record.type
        ttl               = record.ttl
        proxied           = record.proxied
        priority          = record.priority
        comment           = record.comment
        data              = record.data
        tags              = record.tags
        name_content_hash = md5("${record.name}-${record.content}")
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
    "${rec.zone_name}-${rec.name}-${rec.type}-${coalesce(rec.slug, rec.name_content_hash)}" => rec
  }

  zone_id  = cloudflare_zone.zones[each.value.zone_name].id
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  comment  = each.value.comment
  priority = each.value.type == "MX" ? each.value.priority : null
  data     = each.value.data != null ? tomap({ for k, v in each.value.data : k => tostring(v) }) : null
  tags     = each.value.tags
}
