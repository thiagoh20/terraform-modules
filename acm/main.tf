provider "aws" {
  alias  = "acm"
  region = var.region
}

provider "aws" {
  alias  = "dns"
  region = var.region
}

resource "aws_acm_certificate" "multi_domain_certificate" {
  domain_name               = var.domain_name_certificate
  validation_method         = "DNS"
  provider                  = aws.acm
  subject_alternative_names = var.subject_alternative_names

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Crear registros DNS para validación
resource "aws_route53_record" "cert_validation" {
  provider = aws.dns

  for_each = {
    for dvo in aws_acm_certificate.multi_domain_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = coalesce(concat(
        [for suffix, zone in var.additional_zone_ids : zone if endswith(dvo.domain_name, ".${suffix}") || dvo.domain_name == suffix],
        [var.hosted_zone_id]
      )...)
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# Validación del certificado
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.multi_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "10m"
  }
}


