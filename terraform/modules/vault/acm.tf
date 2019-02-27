# The MIT License (MIT)
#
# Copyright (c) 2014-2019 Avant, Sean Lingren

resource "aws_acm_certificate" "acm" {
  count             = "${ var.route53_enabled ? 1 : 0 }"
  domain_name       = "${ var.route53_domain_name }"
  validation_method = "DNS"

  tags = "${ merge(
    map("Name", "${ var.name_prefix }_private"),
    var.tags ) }"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_route53_record.www"]
}

resource "aws_route53_record" "dns_acm_validation" {
  count   = "${ var.route53_enabled ? 1 : 0 }"
  name    = "${ aws_acm_certificate.acm.domain_validation_options.0.resource_record_name }"
  type    = "${ aws_acm_certificate.acm.domain_validation_options.0.resource_record_type }"
  zone_id = "${ var.zone_id }"
  records = ["${ aws_acm_certificate.acm.domain_validation_options.0.resource_record_value }"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "acm_validation" {
  count                   = "${ var.route53_enabled ? 1 : 0 }"
  certificate_arn         = "${ aws_acm_certificate.acm.arn }"
  validation_record_fqdns = ["${ aws_route53_record.dns_acm_validation.fqdn }"]
}
