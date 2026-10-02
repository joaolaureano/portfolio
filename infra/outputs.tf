output "name_servers" {
  description = "Set these at the registrar so the domain resolves through this zone."
  value       = aws_route53_zone.site.name_servers
}

output "bucket" {
  value = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  value = aws_cloudfront_distribution.site.id
}

output "deploy_role_arn" {
  description = "Goes into the AWS_DEPLOY_ROLE_ARN repository variable."
  value       = aws_iam_role.deploy.arn
}

output "url" {
  value = "https://${var.domain_name}"
}
