variable "hosted_zone_id" {
  description = "The hosted zone ID to create the certificate in"
  type        = string
}

variable "domain_name_certificate" {
  description = "The domain name to create the certificate for"
  type        = string
}

variable "subject_alternative_names" {
  description = "The subject alternative names to create the certificate for"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "The region to create the certificate in"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "additional_zone_ids" {
  description = "Map of domain suffix to hosted zone ID for SANs that belong to a different Route53 zone. Example: {\"homeprimehub.com\" = \"Z09906034BPNLRMZ71TT\"}"
  type        = map(string)
  default     = {}
}
