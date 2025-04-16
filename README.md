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
          name  = "example.com"
          content = "192.168.1.2"
        },
        {
          name  = "*.example.com"
          content = "192.168.1.3"
        },
        {
          name        = "voip"
          record_type = "CNAME"
          value       = "external.something.com"
          proxied     = true
        }
      ]
    }
  }
}
```
