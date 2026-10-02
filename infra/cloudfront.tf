data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

# HSTS, nosniff, frame-options and referrer-policy, maintained by AWS.
data "aws_cloudfront_response_headers_policy" "security" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${var.project_name}-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 behind OAC has no notion of directory indexes, and Astro builds
# /projects/x/index.html. This maps clean URLs onto those files and sends
# www to the apex, at the edge, before the cache.
resource "aws_cloudfront_function" "router" {
  name    = "${var.project_name}-router"
  runtime = "cloudfront-js-2.0"
  comment = "www to apex, directory indexes"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var host = request.headers.host && request.headers.host.value;

      if (host && host.indexOf("www.") === 0) {
        var qs = Object.keys(request.querystring).map(function (k) {
          return k + "=" + request.querystring[k].value;
        }).join("&");
        return {
          statusCode: 301,
          statusDescription: "Moved Permanently",
          headers: {
            location: { value: "https://${var.domain_name}" + request.uri + (qs ? "?" + qs : "") }
          }
        };
      }

      var uri = request.uri;
      if (uri.endsWith("/")) {
        request.uri = uri + "index.html";
      } else if (uri.lastIndexOf(".") < uri.lastIndexOf("/")) {
        return {
          statusCode: 301,
          statusDescription: "Moved Permanently",
          headers: { location: { value: uri + "/" } }
        };
      }
      return request;
    }
  EOT
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  comment             = "${var.project_name} - static site"
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
  aliases             = [var.domain_name, "www.${var.domain_name}"]

  origin {
    origin_id                = "s3"
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  default_cache_behavior {
    target_origin_id           = "s3"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.router.arn
    }
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
