# The zone is created here; the registrar only needs to point at its name
# servers (see the name_servers output). Route 53 Domains does that on its own.
resource "aws_route53_zone" "site" {
  name = var.domain_name
}

resource "aws_acm_certificate" "site" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for o in aws_acm_certificate.site.domain_validation_options : o.domain_name => {
      name   = o.resource_record_name
      type   = o.resource_record_type
      record = o.resource_record_value
    }
  }

  zone_id         = aws_route53_zone.site.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 300
  allow_overwrite = true
}

# Blocks until ACM sees the records, which only happens once the registrar
# delegates to this zone. Set the name servers first, then apply.
resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

resource "aws_route53_record" "alias" {
  for_each = toset(flatten([
    for name in [var.domain_name, "www.${var.domain_name}"] : [
      for type in ["A", "AAAA"] : "${name}|${type}"
    ]
  ]))

  zone_id = aws_route53_zone.site.zone_id
  name    = split("|", each.value)[0]
  type    = split("|", each.value)[1]

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
