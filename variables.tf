variable "account_id" {
  type        = string
  description = "CloudFlare Account ID"
  default     = ""
}

variable "zones" {
  type = map(object({
    zone_type = string
    records = list(object({
      name = string
      content = string
      type = optional(string)
      ttl = optional(number)
      proxied = optional(bool)
      priority = optional(number)
      comment = optional(string)
    }))
  }))
}

