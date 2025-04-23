output "cloudfront_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.bucket
}

output "website_url" {
  description = "The URL of the website"
  value       = "https://${aws_cloudfront_distribution.website_distribution.domain_name}"
}