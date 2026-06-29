# terraform module for managing DNS zones and their records on CloudFlare

## Example usage
```hcl
module "cloudflare_dns" {
  source = "git@github.com:FessAectan/terraform-cloudflare-dns.git"
  account_id = var.cloudflare_account_id

  zones = {
    "example.com" = {
      zone_type = "full"
      records = [
        {
          name    = "example.com"
          content = "192.168.1.2"
        },
        {
          name    = "*.example.com"
          content = "192.168.1.3"
        },
        {
          name    = "voip"
          type    = "CNAME"
          content = "external.something.com"
          proxied = true
        }
      ]
    }
  }
}
```

## Stable record identity (`slug`)

By default a record's identity is derived from its `name` + `content`, so changing
`content` recreates the record (destroy + create). Set an optional `slug` to give a
record a stable identity that is decoupled from its content — then changing `content`
becomes an in-place update. A `slug` is also required to disambiguate multiple records
that share the same `name` and `type` (e.g. round-robin records).

```hcl
records = [
  { slug = "web",    name = "example.com", content = "1.2.3.4" },
  { slug = "web-bk", name = "example.com", content = "9.8.7.6" }, # same name/type, distinct slug
]
```

> Note: the `slug` becomes the permanent handle for the record. Changing a `slug`
> recreates that record.
