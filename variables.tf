variable "account_id" {
  description = "Cloudflare Account ID that owns the managed zones."
  type        = string

  validation {
    condition     = length(var.account_id) > 0
    error_message = "account_id must not be empty."
  }
}

variable "zones" {
  description = "Map of Cloudflare zones to manage, keyed by zone name. Each zone defines its type and a list of DNS records."
  type = map(object({
    zone_type = string
    records = list(object({
      name     = string
      content  = string
      type     = optional(string, "A")
      ttl      = optional(number, 300)
      proxied  = optional(bool, false)
      priority = optional(number)
      comment  = optional(string, "Managed by terraform")
      data     = optional(map(any))
      tags     = optional(set(string))
    }))
  }))

  validation {
    condition = alltrue([
      for zone in var.zones : contains(["full", "partial"], zone.zone_type)
    ])
    error_message = "zone_type must be either \"full\" or \"partial\"."
  }

  validation {
    condition = alltrue(flatten([
      for zone in var.zones : [
        for record in zone.records : contains(
          ["A", "AAAA", "CNAME", "TXT", "MX", "NS", "SRV", "CAA", "PTR"],
          record.type
        )
      ]
    ]))
    error_message = "record type must be one of: A, AAAA, CNAME, TXT, MX, NS, SRV, CAA, PTR."
  }
}
