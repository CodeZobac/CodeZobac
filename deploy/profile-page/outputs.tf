# Output bucket name, website domain and website endpoint

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "website_domain" {
  value = aws_s3_bucket_website_configuration.bucket-website-configuration.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.bucket-website-configuration.website_endpoint
}

# Output CloudFront domain name

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.distribution[*].domain_name
}
