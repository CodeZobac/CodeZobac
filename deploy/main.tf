# The domain should have a trusted certificate

resource "aws_acm_certificate" "certificate" {
  for_each = local.clients
  provider = aws.acm

  domain_name               = each.key
  subject_alternative_names = ["www.${each.key}"]
  # LINK: https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Client          = each.value.client
    Contact         = each.value.contact
    Domain          = each.key
    Domain-Provider = each.value.domain_provider
    Email           = each.value.email
    Managed-by      = "Terraform"
  }
}

module "landing_page" {
  for_each = local.clients

  source                        = "./profile-page"
  account_id                    = each.value.account_id
  client                        = each.value.client
  contact                       = each.value.contact
  domain                        = each.key
  domain_provider               = each.value.domain_provider
  email                         = each.value.email
  enable_faster_deliver_content = each.value.enable_faster_deliver_content
  region                        = each.value.region
  restriction_locations         = each.value.restriction_locations
  acm_certificate_is_issued     = each.value.acm_certificate_is_issued
  acm_certificate_arn           = aws_acm_certificate.certificate[each.key].arn

  providers = {
    aws = aws
  }
}
