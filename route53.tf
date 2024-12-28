module "route53_record" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=e3e35482b7d8d430b505c8dba858b95b9a379601"

  for_each = {
    for stage_name, stage_config in var.stages :
    stage_name => stage_config
    if stage_config.custom_domain != null &&
    stage_config.custom_domain.route_53_record_params != null &&
    contains(try(stage_config.custom_domain.endpoint_configuration.types, []), "REGIONAL")
  }

  zone_name    = each.value.custom_domain.zone_name
  private_zone = try(each.value.custom_domain.route_53_record_params.private_zone, false)
  records = [
    {
      name            = each.value.custom_domain.name
      type            = try(each.value.custom_domain.route_53_record_params.type, "A")
      allow_overwrite = try(each.value.custom_domain.route_53_record_params.allow_overwrite, false)
      alias = {
        evaluate_target_health = try(each.value.custom_domain.route_53_record_params.alias_evaluate_target_health, false)
        name                   = aws_api_gateway_domain_name.this[each.key].regional_domain_name
        zone_id                = aws_api_gateway_domain_name.this[each.key].regional_zone_id
      }
    }
  ]
}
