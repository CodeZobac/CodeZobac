output "landing_pages" {
  value = {
    for domain, certificate in aws_acm_certificate.certificate : domain => {
      bucket_name               = module.landing_page[domain].bucket_name
      website_domain            = module.landing_page[domain].website_domain
      website_endpoint          = module.landing_page[domain].website_endpoint
      cloudfront_domain         = module.landing_page[domain].cloudfront_domain_name
      domain_validation_options = certificate.domain_validation_options
    }
  }
}
