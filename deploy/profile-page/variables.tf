variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  type        = string
}

variable "acm_certificate_is_issued" {
  description = "The ACM certificate is issued"
  type        = bool
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "client" {
  description = "The client name"
  type        = string
}

variable "contact" {
  description = "The client contact number"
  type        = string
}

variable "domain" {
  description = "The domain name"
  type        = string
}

variable "domain_provider" {
  description = "The domain provider"
  type        = string

  validation {
    condition     = contains(["godaddy"], var.domain_provider)
    error_message = "The domain provider must be godaddy"
  }
}

variable "email" {
  description = "The client email address"
  type        = string
}

variable "enable_faster_deliver_content" {
  description = "Enable faster delivery of content"
  type        = bool
}

variable "region" {
  description = "The region in which the resources will be deployed"
  type        = string
}

variable "restriction_locations" {
  description = "The list of locations that the client is restricted to. # LINK: https://www.iso.org/obp/ui/#search"
  type        = list(string)
}
