variable "account_id" {
  type        = string
  description = "Cloudflare Account ID"
  default     = ""
}

variable "zones" {
  description = "Zones and their DNS records"
  type = map(object({
    zone_type = string
    records = list(object({
      # core
      name     = string
      content  = optional(string) # optional to allow data-only records
      type     = optional(string)
      ttl      = optional(number)
      proxied  = optional(bool)
      priority = optional(number)
      comment  = optional(string)

      # advanced record payload (SRV/CAA/TLSA/LOC/URI/etc.)
      data = optional(object({
        algorithm      = optional(number)
        altitude       = optional(number)
        certificate    = optional(string)
        digest         = optional(string)
        digest_type    = optional(number)
        fingerprint    = optional(string)
        flags          = optional(any) # CAA flags often a small map/int
        key_tag        = optional(number)
        lat_degrees    = optional(number)
        lat_direction  = optional(string) # "N" | "S"
        lat_minutes    = optional(number)
        lat_seconds    = optional(number)
        long_degrees   = optional(number)
        long_direction = optional(string) # "E" | "W"
        long_minutes   = optional(number)
        long_seconds   = optional(number)
        matching_type  = optional(number)
        order          = optional(number)
        port           = optional(number)
        precision_horz = optional(number)
        precision_vert = optional(number)
        preference     = optional(number)
        priority       = optional(number)
        protocol       = optional(number)
        public_key     = optional(string)
        regex          = optional(string)
        replacement    = optional(string)
        selector       = optional(number)
        service        = optional(string)
        size           = optional(number)
        tag            = optional(string)
        target         = optional(string)
        type           = optional(number)
        usage          = optional(number)
        value          = optional(string)
        weight         = optional(number)
      }))

      # per-record resolver settings
      settings = optional(object({
        flatten_cname = optional(bool)
        ipv4_only     = optional(bool)
        ipv6_only     = optional(bool)
      }))
    }))
  }))

  # Basic safety: every record must have at least content or data
  validation {
    condition = alltrue([
      for z in values(var.zones) : alltrue([
        for r in z.records : (
          contains(keys(r), "content") ||
          contains(keys(r), "data")
        )
      ])
    ])
    error_message = "Each record must provide either `content` or `data`."
  }
}
