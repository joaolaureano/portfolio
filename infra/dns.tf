# The domain is registered at Cloudflare, which keeps its DNS, so the records
# live in the existing Cloudflare zone. They stay DNS-only: CloudFront already
# terminates TLS with the ACM certificate, and a second proxy in front of it
# would only get in the way.
data "cloudflare_zone" "site" {
  filter = {
    name = var.domain_name
  }
}

resource "aws_acm_certificate" "site" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "cert_validation" {
  for_each = {
    for o in aws_acm_certificate.site.domain_validation_options : o.domain_name => {
      name   = trimsuffix(o.resource_record_name, ".")
      type   = o.resource_record_type
      record = trimsuffix(o.resource_record_value, ".")
    }
  }

  zone_id = data.cloudflare_zone.site.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.record
  ttl     = 300
  proxied = false
}

resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in cloudflare_dns_record.cert_validation : r.name]
}

# A CNAME at the apex is fine here: Cloudflare flattens it into A/AAAA answers.
resource "cloudflare_dns_record" "site" {
  for_each = toset([var.domain_name, "www.${var.domain_name}"])

  zone_id = data.cloudflare_zone.site.zone_id
  name    = each.value
  type    = "CNAME"
  content = aws_cloudfront_distribution.site.domain_name
  ttl     = 1 # automatic
  proxied = false
}
