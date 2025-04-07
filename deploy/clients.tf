locals {
  clients = {
    "codezobac.me" = {
      account_id                    = var.account_id
      client                        = "Afonso"
      contact                       = "000000000000"
      domain_provider               = "namecheap"
      email                         = "afonso.caboz@gmail.com"
      enable_faster_deliver_content = false
      region                        = var.region
      restriction_locations         = ["PT"]
      acm_certificate_is_issued     = true
    }
  }
}
