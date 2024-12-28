output "vpc_link_ids" {
  description = "The IDs of the created VPC links"
  value       = { for k, v in aws_api_gateway_vpc_link.this : k => v.id }
}

output "rest_api_id" {
  description = "The ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "rest_api_arn" {
  description = "The ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "deployment_ids" {
  description = "The IDs of the deployments"
  value       = { for k, v in aws_api_gateway_deployment.this : k => v.id }
}

output "log_group_names" {
  description = "The names of the CloudWatch Log Groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "stage_names" {
  description = "The names of the API Gateway stages"
  value       = { for k, v in aws_api_gateway_stage.this : k => v.stage_name }
}

output "parent_method_ids" {
  description = "The IDs of the API Gateway parent methods"
  value       = { for k, v in aws_api_gateway_method.parent_methods : k => v.id }
}

output "child_method_ids" {
  description = "The IDs of the API Gateway child methods"
  value       = { for k, v in aws_api_gateway_method.child_methods : k => v.id }
}

output "grandchild_method_ids" {
  description = "The IDs of the API Gateway grandchild methods"
  value       = { for k, v in aws_api_gateway_method.grandchild_methods : k => v.id }
}

output "great_grandchild_method_ids" {
  description = "The IDs of the API Gateway great grandchild methods"
  value       = { for k, v in aws_api_gateway_method.great_grandchild_methods : k => v.id }
}

output "parent_integration_ids" {
  description = "The IDs of the API Gateway parent integrations"
  value = merge(
    { for k, v in aws_api_gateway_integration.vpc_link_parent : k => v.id },
    { for k, v in aws_api_gateway_integration.mock_parent : k => v.id },
    { for k, v in aws_api_gateway_integration.lambda_parent : k => v.id }
  )
}

output "child_integration_ids" {
  description = "The IDs of the API Gateway child integrations"
  value = merge(
    { for k, v in aws_api_gateway_integration.vpc_link_child : k => v.id },
    { for k, v in aws_api_gateway_integration.mock_child : k => v.id },
    { for k, v in aws_api_gateway_integration.lambda_child : k => v.id }
  )
}

output "grandchild_integration_ids" {
  description = "The IDs of the API Gateway grandchild integrations"
  value = merge(
    { for k, v in aws_api_gateway_integration.vpc_link_grandchild : k => v.id },
    { for k, v in aws_api_gateway_integration.mock_grandchild : k => v.id },
    { for k, v in aws_api_gateway_integration.lambda_grandchild : k => v.id }
  )
}

output "great_grandchild_integration_ids" {
  description = "The IDs of the API Gateway great grandchild integrations"
  value = merge(
    { for k, v in aws_api_gateway_integration.vpc_link_great_grandchild : k => v.id },
    { for k, v in aws_api_gateway_integration.mock_great_grandchild : k => v.id },
    { for k, v in aws_api_gateway_integration.lambda_great_grandchild : k => v.id }
  )
}

output "authorizer_ids" {
  description = "The IDs of the API Gateway authorizers"
  value       = { for k, v in aws_api_gateway_authorizer.cognito_user_pool : k => v.id }
}

output "resource_parent_ids" {
  description = "The IDs of the API Gateway parent resources"
  value       = { for k, v in aws_api_gateway_resource.parent : k => v.id }
}

output "resource_child_ids" {
  description = "The IDs of the API Gateway child resources"
  value       = { for k, v in aws_api_gateway_resource.child : k => v.id }
}

output "resource_grandchild_ids" {
  description = "The IDs of the API Gateway grandchild resources"
  value       = { for k, v in aws_api_gateway_resource.grandchild : k => v.id }
}

output "resource_great_grandchild_ids" {
  description = "The IDs of the API Gateway great grandchild resources"
  value       = { for k, v in aws_api_gateway_resource.great-grandchild : k => v.id }
}

output "api_gateway_custom_domains" {
  description = "Map of custom domains associated with the API Gateway stages."
  value = {
    for stage_name, domain in aws_api_gateway_domain_name.this :
    stage_name => {
      domain_name            = domain.domain_name
      regional_domain_name   = domain.regional_domain_name
      regional_zone_id       = domain.regional_zone_id
      cloudfront_domain_name = domain.cloudfront_domain_name
      cloudfront_zone_id     = domain.cloudfront_zone_id
      endpoint_configuration = domain.endpoint_configuration
    }
  }
}

output "route53_record_name" {
  description = "The name of the Route53 record"
  value       = try(module.route53_record[0].route53_record_name, "")
}

output "route53_record_fqdn" {
  description = "FQDN built using the zone domain and name"
  value       = try(module.route53_record[0].route53_record_fqdn, "")
}
