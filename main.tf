
resource "aws_api_gateway_vpc_link" "this" {
  for_each = var.private_links

  name        = each.value["name"]
  description = try(each.value["description"], "Created by Terraform")
  target_arns = each.value["target_arns"]
  tags        = var.tags
}

resource "aws_api_gateway_rest_api" "this" {
  name = var.api_gateway_name

  tags = var.tags

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_rest_api_policy" "this" {
  count = local.create_rest_api_policy ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = var.rest_api_policy
}

resource "aws_api_gateway_deployment" "this" {
  for_each = var.stages

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode({
      great_grandchild_methods = sha1(jsonencode({ for k, v in aws_api_gateway_method.great_grandchild_methods : k => {
        http_method        = v["http_method"]
        authorization      = v["authorization"]
        request_parameters = v["request_parameters"]
      } }))
      child_methods = { for k, v in aws_api_gateway_method.child_methods : k => {
        http_method        = v["http_method"]
        authorization      = v["authorization"]
        request_parameters = v["request_parameters"]
      } }
      grandchild_methods = sha1(jsonencode({ for k, v in aws_api_gateway_method.grandchild_methods : k => {
        http_method        = v["http_method"]
        authorization      = v["authorization"]
        request_parameters = v["request_parameters"]
      } }))
      parent_methods = sha1(jsonencode({ for k, v in aws_api_gateway_method.parent_methods : k => {
        http_method        = v["http_method"]
        authorization      = v["authorization"]
        request_parameters = v["request_parameters"]
      } }))
      vpc_link_integrations_great_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_integration.vpc_link_great_grandchild : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
        connection_id           = v["connection_id"]
      } }))
      vpc_link_integrations_child = sha1(jsonencode({ for k, v in aws_api_gateway_integration.vpc_link_child : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
        connection_id           = v["connection_id"]
      } }))
      vpc_link_integrations_grandchild = { for k, v in aws_api_gateway_integration.vpc_link_grandchild : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
        connection_id           = v["connection_id"]
      } }
      vpc_link_integrations_parent = sha1(jsonencode({ for k, v in aws_api_gateway_integration.vpc_link_parent : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
        connection_id           = v["connection_id"]
      } }))
      mock_integrations_great_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_integration.mock_great_grandchild : k => {
        type                 = v["type"]
        passthrough_behavior = v["passthrough_behavior"]
        content_handling     = v["content_handling"]
      } }))
      mock_integrations_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_integration.mock_grandchild : k => {
        type                 = v["type"]
        passthrough_behavior = v["passthrough_behavior"]
        content_handling     = v["content_handling"]
      } }))
      mock_integrations_parent = sha1(jsonencode({ for k, v in aws_api_gateway_integration.mock_parent : k => {
        type                 = v["type"]
        passthrough_behavior = v["passthrough_behavior"]
        content_handling     = v["content_handling"]
      } }))
      mock_integrations_child = sha1(jsonencode({ for k, v in aws_api_gateway_integration.mock_child : k => {
        type                 = v["type"]
        passthrough_behavior = v["passthrough_behavior"]
        content_handling     = v["content_handling"]
      } }))
      lambda_integrations_great_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_integration.lambda_great_grandchild : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
      } }))
      lambda_grandchild_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_integration.lambda_grandchild : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
      } }))
      lambda_integrations_parent = sha1(jsonencode({ for k, v in aws_api_gateway_integration.lambda_parent : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
      } }))
      lambda_integrations_child = sha1(jsonencode({ for k, v in aws_api_gateway_integration.lambda_child : k => {
        type                    = v["type"]
        uri                     = v["uri"]
        integration_http_method = v["integration_http_method"]
        passthrough_behavior    = v["passthrough_behavior"]
        content_handling        = v["content_handling"]
      } }))
      stage_variables = sha1(jsonencode(var.stages[each.key].variables))
      method_response_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_method_response.grandchild_methods : k => {
        status_code         = v["status_code"]
        response_models     = v["response_models"]
        response_parameters = v["response_parameters"]
      } }))
      method_response_parent = sha1(jsonencode({ for k, v in aws_api_gateway_method_response.parent_methods : k => {
        status_code         = v["status_code"]
        response_models     = v["response_models"]
        response_parameters = v["response_parameters"]
      } }))
      method_response_child = sha1(jsonencode({ for k, v in aws_api_gateway_method_response.child_methods : k => {
        status_code         = v["status_code"]
        response_models     = v["response_models"]
        response_parameters = v["response_parameters"]
      } }))
      authorizers = sha1(jsonencode({ for k, v in aws_api_gateway_authorizer.cognito_user_pool : k => {
        name                             = v["name"]
        type                             = v["type"]
        provider_arns                    = v["provider_arns"]
        identity_source                  = v["identity_source"]
        authorizer_result_ttl_in_seconds = v["authorizer_result_ttl_in_seconds"]
      } }))
      aws_api_gateway_integration_response_great_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_integration_response.great_grandchild : k => {
        response_templates  = v["response_templates"]
        response_parameters = v["response_parameters"]
      } }))
      aws_api_gateway_integration_response_grandchild = sha1(jsonencode({ for k, v in aws_api_gateway_integration_response.grandchild : k => {
        response_templates  = v["response_templates"]
        response_parameters = v["response_parameters"]
      } }))
      aws_api_gateway_integration_response_parent = sha1(jsonencode({ for k, v in aws_api_gateway_integration_response.parent : k => {
        response_templates  = v["response_templates"]
        response_parameters = v["response_parameters"]
      } }))
    }))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.vpc_link_child,
    aws_api_gateway_integration.mock_child,
    aws_api_gateway_integration.lambda_child,
    aws_api_gateway_integration.vpc_link_parent,
    aws_api_gateway_integration.mock_parent,
    aws_api_gateway_integration.lambda_parent
  ]

}

resource "aws_cloudwatch_log_group" "this" {
  for_each = local.stages_with_logging

  name = "/aws/apigateway/${var.api_gateway_name}-${each.key}"

  retention_in_days = try(each.value["retention_in_days"], 30)
  kms_key_id        = try(each.value["kms_key_id"], null)

  tags = var.tags
}

resource "aws_api_gateway_stage" "this" {
  for_each = var.stages

  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = try(each.value["name"], each.key)
  description   = try(each.value["description"], "Created by Terraform")
  deployment_id = aws_api_gateway_deployment.this[try(each.value["name"], each.key)].id
  #checkov:skip=CKV_AWS_120:Ensure API Gateway caching is enabled
  cache_cluster_enabled = try(each.value["cache_cluster_enabled"], false)
  cache_cluster_size    = try(each.value["cache_cluster_size"], null)
  client_certificate_id = try(each.value["client_certificate_id"], null)
  variables = merge(
    try(each.value["variables"], {}),
    each.value["vpc_link_name"] != null ? { vpc_link_id = aws_api_gateway_vpc_link.this[each.value["vpc_link_name"]].id } : {}
  )
  #checkov:skip=CKV_AWS_73:Ensure API Gateway has X-Ray Tracing enabled
  xray_tracing_enabled = try(each.value["xray_tracing_enabled"], false)

  #checkov:skip=CKV2_AWS_4:Ensure API Gateway stage have logging level defined as appropriate
  dynamic "access_log_settings" {
    for_each = each.value["logging_config"] != null ? [each.value["logging_config"]] : []

    content {
      destination_arn = aws_cloudwatch_log_group.this[each.key].arn
      format          = each.value["logging_config"]["access_log_format"] != null ? each.value["logging_config"]["access_log_format"] : local.access_log_format_default
    }
  }

  dynamic "canary_settings" {
    for_each = each.value["canary_settings"] == true ? [each.value["canary_settings"]] : []

    content {
      percent_traffic          = each.value["canary_percent_traffic"]
      stage_variable_overrides = each.value["canary_stage_variable_overrides"]
      use_stage_cache          = each.value["canary_use_stage_cache"]
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_api_gateway_method_settings" "this" {
  for_each = local.stages_with_method_settings

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = each.value.stage_name
  method_path = each.value.method_path

  #checkov:skip=CKV_AWS_225:Ensure API Gateway method setting caching is enabled
  #checkov:skip=CKV2_AWS_4:Ensure API Gateway stage have logging level defined as appropriate
  settings {
    metrics_enabled                            = each.value.settings["metrics_enabled"]
    logging_level                              = each.value.settings["log_level"]
    data_trace_enabled                         = each.value.settings["data_trace_enabled"]
    throttling_burst_limit                     = each.value.settings["throttling_burst_limit"]
    throttling_rate_limit                      = each.value.settings["throttling_rate_limit"]
    caching_enabled                            = each.value.settings["caching_enabled"]
    cache_ttl_in_seconds                       = each.value.settings["cache_ttl_in_seconds"]
    cache_data_encrypted                       = each.value.settings["cache_data_encrypted"]
    require_authorization_for_cache_control    = each.value.settings["require_authorization_for_cache_control"]
    unauthorized_cache_control_header_strategy = each.value.settings["unauthorized_cache_control_header_strategy"]
  }

  depends_on = [
    aws_api_gateway_stage.this,
  ]
}

########RESOURCES########

resource "aws_api_gateway_resource" "parent" {
  for_each = { for parent in local.parent_resources : parent => parent }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value
}

resource "aws_api_gateway_resource" "child" {
  for_each = { for res in local.child_resources : "${res.parent}-${res.child_key}" => res }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.parent[each.value.parent].id
  path_part   = each.value.child_key
}

resource "aws_api_gateway_resource" "grandchild" {
  for_each = { for res in local.grandchild_resources : "${res.parent}-${res.child_key}-${res.grandchild_key}" => res }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.child["${each.value.parent}-${each.value.child_key}"].id
  path_part   = each.value.grandchild_key
}

resource "aws_api_gateway_resource" "great-grandchild" {
  for_each = { for res in local.great_grandchild_resources : "${res.parent}-${res.child_key}-${res.grandchild_key}-${res.great_grandchild_key}" => res }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}"].id
  path_part   = each.value.great_grandchild_key
}

########METHODS########

resource "aws_api_gateway_method" "great_grandchild_methods" {
  for_each = {
    for res in local.great_grandchild_resources_with_methods :
    "${res.parent}-${res.child_key}-${res.grandchild_key}-${res.great_grandchild_key}-${res.method}" => res
  }

  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.great-grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}"].id
  http_method          = each.value.method
  authorization        = each.value.method_data.authorization
  authorizer_id        = each.value.method_data.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.cognito_user_pool[each.value.method_data.cognito_user_pool_name].id : null
  authorization_scopes = try(each.value.method_data.authorization_scopes, null)
  request_parameters   = each.value.method_data.request_parameters
  request_validator_id = each.value.method_data.request_validator_id
}

resource "aws_api_gateway_method" "grandchild_methods" {
  for_each = {
    for res in local.grandchild_resources_with_methods :
    "${res.parent}-${res.child_key}-${res.grandchild_key}-${res.method}" => res
  }

  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}"].id
  http_method          = each.value.method
  authorization        = each.value.method_data.authorization
  authorizer_id        = each.value.method_data.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.cognito_user_pool[each.value.method_data.cognito_user_pool_name].id : null
  authorization_scopes = try(each.value.method_data.authorization_scopes, null)
  request_parameters   = each.value.method_data.request_parameters
  request_validator_id = each.value.method_data.request_validator_id
}

resource "aws_api_gateway_method" "child_methods" {
  for_each = {
    for res in local.child_resources_with_methods :
    "${res.parent}-${res.child_key}-${res.method}" => res
  }

  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.child["${each.value.parent}-${each.value.child_key}"].id
  http_method          = each.value.method
  authorization        = each.value.method_data.authorization
  authorizer_id        = each.value.method_data.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.cognito_user_pool[each.value.method_data.cognito_user_pool_name].id : null
  authorization_scopes = try(each.value.method_data.authorization_scopes, null)
  request_parameters   = each.value.method_data.request_parameters
  request_validator_id = each.value.method_data.request_validator_id
}

resource "aws_api_gateway_method" "parent_methods" {
  for_each = {
    for res in local.parent_resources_with_methods : "${res.parent}-${res.method}" => res
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.parent[each.value.resource_key].id

  http_method          = each.value.method
  authorization        = each.value.method_data.authorization
  authorizer_id        = each.value.method_data.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.cognito_user_pool[each.value.method_data.cognito_user_pool_name].id : null
  authorization_scopes = try(each.value.method_data.authorization_scopes, null)
  request_parameters   = each.value.method_data.request_parameters
  request_validator_id = each.value.method_data.request_validator_id
}

########METHOD_RESPONSES########

resource "aws_api_gateway_method_response" "great_grandchild_methods" {
  for_each = {
    for res in local.great_grandchild_resources_with_methods : "${res.child_key}-${res.grandchild_key}-${res.great_grandchild_key}-${res.method}" => res
    if res.method_data.method_response != null && length(keys(res.method_data.method_response)) > 0
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.great-grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}"].id
  http_method = each.value.method
  status_code = each.value.method_data.method_response.status_code

  response_models     = try(each.value.method_data.method_response.response_models, {})
  response_parameters = try(each.value.method_data.method_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_method.great_grandchild_methods
  ]
}

resource "aws_api_gateway_method_response" "grandchild_methods" {
  for_each = {
    for res in local.grandchild_resources_with_methods : "${res.child_key}-${res.grandchild_key}-${res.method}" => res
    if res.method_data.method_response != null && length(keys(res.method_data.method_response)) > 0
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}"].id
  http_method = each.value.method
  status_code = each.value.method_data.method_response.status_code

  response_models     = try(each.value.method_data.method_response.response_models, {})
  response_parameters = try(each.value.method_data.method_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_method.grandchild_methods
  ]
}

resource "aws_api_gateway_method_response" "child_methods" {
  for_each = {
    for item in local.child_resources_with_method_responses : "${item.resource_key}_${item.resource_path}_${item.http_method}" => item
    if item.method_response != null && length(keys(item.method_response)) > 0
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.is_child ? aws_api_gateway_resource.child[each.value.resource_key].id : aws_api_gateway_resource.parent[each.value.resource_key].id
  http_method = each.value.http_method
  status_code = each.value.method_response.status_code

  response_models     = try(each.value.method_response.response_models, {})
  response_parameters = try(each.value.method_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_method.child_methods
  ]
}

resource "aws_api_gateway_method_response" "parent_methods" {
  for_each = {
    for res in local.parent_resources_with_method_responses : "${res.resource_key}_${res.method}" => res
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.parent[each.value.resource_key].id
  http_method = each.value.method_data.http_method
  status_code = each.value.method_response.status_code

  response_models     = try(each.value.method_response.response_models, {})
  response_parameters = try(each.value.method_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_method.parent_methods
  ]
}

########INTEGRATION_RESPONSES########

resource "aws_api_gateway_integration_response" "great_grandchild" {
  for_each = {
    for integration in local.great_grandchild_resources_with_methods :
    "${integration.child_key}-${integration.grandchild_key}-${integration.great_grandchild_key}-${integration.method}" => integration
    if try(integration.method_data.integration.integration_response, null) != null && try(integration.method_data.integration.integration_response.status_code, null) != null
  }

  rest_api_id = aws_api_gateway_rest_api.this.id

  resource_id = aws_api_gateway_resource.great-grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}"].id
  http_method = aws_api_gateway_method.great_grandchild_methods["${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}-${each.value.method_data.http_method}"].http_method
  status_code = each.value.method_data.integration.integration_response.status_code

  response_templates  = try(each.value.method_data.integration.integration_response.response_templates, {})
  response_parameters = try(each.value.method_data.integration.integration_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_integration.vpc_link_great_grandchild,
    aws_api_gateway_integration.mock_great_grandchild,
    aws_api_gateway_integration.lambda_great_grandchild,
    aws_api_gateway_method_response.great_grandchild_methods
  ]
}

resource "aws_api_gateway_integration_response" "grandchild" {
  for_each = {
    for integration in local.grandchild_resources_with_methods :
    "${integration.child_key}-${integration.grandchild_key}-${integration.method}" => integration
    if try(integration.method_data.integration.integration_response, null) != null && try(integration.method_data.integration.integration_response.status_code, null) != null
  }

  rest_api_id = aws_api_gateway_rest_api.this.id

  resource_id = aws_api_gateway_resource.grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}"].id
  http_method = aws_api_gateway_method.grandchild_methods["${each.value.child_key}-${each.value.grandchild_key}-${each.value.method_data.http_method}"].http_method
  status_code = each.value.method_data.integration.integration_response.status_code

  response_templates  = try(each.value.method_data.integration.integration_response.response_templates, {})
  response_parameters = try(each.value.method_data.integration.integration_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_integration.vpc_link_grandchild,
    aws_api_gateway_integration.mock_grandchild,
    aws_api_gateway_integration.lambda_grandchild,
    aws_api_gateway_method_response.grandchild_methods
  ]
}

resource "aws_api_gateway_integration_response" "child" {
  for_each = {
    for idx, item in local.integration_responses_child : "${item.resource_key}_${item.method}" => item
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.child[each.value.resource_key].id

  http_method = aws_api_gateway_method.child_methods["${each.value.resource_key}-${each.value.method}"].http_method
  status_code = each.value.integration_response.status_code

  response_templates  = try(each.value.integration_response.response_templates, {})
  response_parameters = try(each.value.integration_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_integration.vpc_link_child,
    aws_api_gateway_integration.mock_child,
    aws_api_gateway_integration.lambda_child,
    aws_api_gateway_method_response.child_methods
  ]
}

resource "aws_api_gateway_integration_response" "parent" {
  for_each = {
    for integration in local.integration_responses_parent :
    "${integration.resource_key}_${integration.http_method}" => integration
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.parent[each.value.resource_key].id

  http_method = aws_api_gateway_method.parent_methods["${each.value.resource_key}-${each.value.http_method}"].http_method
  status_code = each.value.integration_response.status_code

  response_templates  = try(each.value.integration.integration_response.response_templates, {})
  response_parameters = try(each.value.integration.integration_response.response_parameters, {})

  depends_on = [
    aws_api_gateway_integration.vpc_link_parent,
    aws_api_gateway_integration.mock_parent,
    aws_api_gateway_integration.lambda_parent,
    aws_api_gateway_method_response.parent_methods
  ]
}

########INTEGRATIONS_VPC_LINK########

resource "aws_api_gateway_integration" "vpc_link_great_grandchild" {
  for_each = {
    for integration in local.great_grandchild_resources_with_methods :
    "${integration.parent}-${integration.child_key}-${integration.grandchild_key}-${integration.great_grandchild_key}-${integration.method}" => integration
    if integration.method_data.integration.connection_type == "VPC_LINK"
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.great-grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}"].id
  http_method = aws_api_gateway_method.great_grandchild_methods["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}-${each.value.method_data.http_method}"].http_method

  type                    = each.value.method_data.integration.type
  uri                     = each.value.method_data.integration.uri
  integration_http_method = each.value.method_data.integration.integration_http_method
  passthrough_behavior    = try(each.value.method_data.integration.passthrough_behavior, null)
  content_handling        = try(each.value.method_data.integration.content_handling, null)

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.this[each.value.method_data.integration.vpc_link_name].id

  cache_key_parameters = try(each.value.method_data.integration.cache_key_parameters, [])

  request_parameters = try(each.value.method_data.integration.request_parameters, {})
  request_templates  = try(each.value.method_data.integration.request_templates, {})
}


resource "aws_api_gateway_integration" "vpc_link_grandchild" {
  for_each = {
    for integration in local.grandchild_resources_with_methods :
    "${integration.parent}-${integration.child_key}-${integration.grandchild_key}-${integration.method}" => integration
    if integration.method_data.integration.connection_type == "VPC_LINK"
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}"].id
  http_method = aws_api_gateway_method.grandchild_methods["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.method_data.http_method}"].http_method

  type                    = each.value.method_data.integration.type
  uri                     = each.value.method_data.integration.uri
  integration_http_method = each.value.method_data.integration.integration_http_method
  passthrough_behavior    = try(each.value.method_data.integration.passthrough_behavior, null)
  content_handling        = try(each.value.method_data.integration.content_handling, null)

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.this[each.value.method_data.integration.vpc_link_name].id

  cache_key_parameters = try(each.value.method_data.integration.cache_key_parameters, [])

  request_parameters = try(each.value.method_data.integration.request_parameters, {})
  request_templates  = try(each.value.method_data.integration.request_templates, {})
}

resource "aws_api_gateway_integration" "vpc_link_child" {
  for_each = {
    for integration in local.vpc_link_integrations_child :
    "${integration.parent_key}-${integration.child_key}-${integration.method_name}" => integration
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.child[each.value.resource_key].id
  http_method = aws_api_gateway_method.child_methods["${each.value.resource_key}-${each.value.method.http_method}"].http_method

  type                    = each.value.integration.type
  uri                     = each.value.integration.uri
  integration_http_method = each.value.integration.integration_http_method
  passthrough_behavior    = try(each.value.integration.passthrough_behavior, null)
  content_handling        = try(each.value.integration.content_handling, null)

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.this[each.value.integration.vpc_link_name].id

  cache_key_parameters = try(each.value.integration.cache_key_parameters, [])

  request_parameters = try(each.value.integration.request_parameters, {})
  request_templates  = try(each.value.integration.request_templates, {})
}

resource "aws_api_gateway_integration" "vpc_link_parent" {
  for_each = {
    for integration in local.vpc_link_integrations_parents :
    "${integration.parent_key}-${integration.method_name}" => integration
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.parent[each.value.resource_key].id
  http_method = aws_api_gateway_method.parent_methods["${each.value.resource_key}-${each.value.method.http_method}"].http_method

  type                    = each.value.integration.type
  uri                     = each.value.integration.uri
  integration_http_method = each.value.integration.integration_http_method
  passthrough_behavior    = try(each.value.integration.passthrough_behavior, null)
  content_handling        = try(each.value.integration.content_handling, null)

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.this[each.value.integration.vpc_link_name].id

  cache_key_parameters = try(each.value.integration.cache_key_parameters, [])
  request_parameters   = try(each.value.integration.request_parameters, {})
  request_templates    = try(each.value.integration.request_templates, {})
}

########INTEGRATIONS_MOCK########

resource "aws_api_gateway_integration" "mock_great_grandchild" {
  for_each = {
    for integration in local.great_grandchild_resources_with_methods :
    "${integration.child_key}-${integration.grandchild_key}-${integration.great_grandchild_key}-${integration.method}" => integration
    if integration.method_data.integration.connection_type == "MOCK"
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.great-grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}"].id
  http_method = aws_api_gateway_method.great_grandchild_methods["${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}-${each.value.method_data.http_method}"].http_method

  type                 = each.value.method_data.integration.type
  passthrough_behavior = try(each.value.method_data.integration.passthrough_behavior, null)
  content_handling     = try(each.value.method_data.integration.content_handling, null)

  request_templates  = try(each.value.method_data.integration.request_templates, {})
  request_parameters = try(each.value.method_data.integration.request_parameters, {})
}

resource "aws_api_gateway_integration" "mock_grandchild" {
  for_each = {
    for integration in local.grandchild_resources_with_methods :
    "${integration.child_key}-${integration.grandchild_key}-${integration.method}" => integration
    if integration.method_data.integration.connection_type == "MOCK"
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}"].id
  http_method = aws_api_gateway_method.grandchild_methods["${each.value.child_key}-${each.value.grandchild_key}-${each.value.method_data.http_method}"].http_method

  type                 = each.value.method_data.integration.type
  passthrough_behavior = try(each.value.method_data.integration.passthrough_behavior, null)
  content_handling     = try(each.value.method_data.integration.content_handling, null)

  request_templates  = try(each.value.method_data.integration.request_templates, {})
  request_parameters = try(each.value.method_data.integration.request_parameters, {})
}

resource "aws_api_gateway_integration" "mock_child" {
  for_each = {
    for item in local.mock_integrations_chaid : "${item.resource_key}_${item.resource_path}_${item.method_name}" => item
    if item.integration.type == "MOCK"
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.child[each.value.resource_key].id
  http_method = aws_api_gateway_method.child_methods["${each.value.resource_key}-${each.value.http_method}"].http_method

  type                 = each.value.integration.type
  passthrough_behavior = try(each.value.integration.passthrough_behavior, null)
  content_handling     = try(each.value.integration.content_handling, null)

  request_templates  = try(each.value.integration.request_templates, {})
  request_parameters = try(each.value.integration.request_parameters, {})
}

resource "aws_api_gateway_integration" "mock_parent" {
  for_each = {
    for integration in local.mock_integrations_parents :
    "${integration.parent_key}-${integration.method_name}" => integration
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.parent[each.value.resource_key].id
  http_method = aws_api_gateway_method.parent_methods["${each.value.resource_key}-${each.value.http_method}"].http_method

  type                 = each.value.integration.type
  passthrough_behavior = try(each.value.integration.passthrough_behavior, null)
  content_handling     = try(each.value.integration.content_handling, null)

  request_templates  = try(each.value.integration.request_templates, {})
  request_parameters = try(each.value.integration.request_parameters, {})
}

########INTEGRATIONS_LAMBDA########

resource "aws_api_gateway_integration" "lambda_great_grandchild" {
  for_each = {
    for integration in local.great_grandchild_resources_with_methods :
    "${integration.child_key}-${integration.grandchild_key}-${integration.great_grandchild_key}-${integration.method}" => integration
    if integration.method_data.integration.connection_type == "LAMBDA"
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.great-grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}"].id
  http_method = aws_api_gateway_method.great_grandchild_methods["${each.value.child_key}-${each.value.grandchild_key}-${each.value.great_grandchild_key}-${each.value.method_data.http_method}"].http_method

  type                    = each.value.method_data.integration.type
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${each.value.method_data.integration.lambda_arn}/invocations"
  integration_http_method = each.value.method_data.integration.integration_http_method
  passthrough_behavior    = lookup(each.value.method_data.integration, "passthrough_behavior", null)
  content_handling        = lookup(each.value.method_data.integration, "content_handling", null)

  request_templates  = lookup(each.value.method_data.integration, "request_templates", null)
  request_parameters = lookup(each.value.method_data.integration, "request_parameters", null)
}

resource "aws_api_gateway_integration" "lambda_grandchild" {
  for_each = {
    for integration in local.grandchild_resources_with_methods :
    "${integration.child_key}-${integration.grandchild_key}-${integration.method}" => integration
    if integration.method_data.integration.connection_type == "LAMBDA"
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.grandchild["${each.value.parent}-${each.value.child_key}-${each.value.grandchild_key}"].id
  http_method = aws_api_gateway_method.grandchild_methods["${each.value.child_key}-${each.value.grandchild_key}-${each.value.method_data.http_method}"].http_method

  type                    = each.value.method_data.integration.type
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${each.value.method_data.integration.lambda_arn}/invocations"
  integration_http_method = each.value.method_data.integration.integration_http_method
  passthrough_behavior    = lookup(each.value.method_data.integration, "passthrough_behavior", null)
  content_handling        = lookup(each.value.method_data.integration, "content_handling", null)

  request_templates  = lookup(each.value.method_data.integration, "request_templates", null)
  request_parameters = lookup(each.value.method_data.integration, "request_parameters", null)
}

resource "aws_api_gateway_integration" "lambda_child" {
  for_each = {
    for integration in local.lambda_integrations_child :
    "${integration.parent_key}-${integration.child_key}-${integration.method_name}" => integration
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.child[each.value.resource_key].id
  http_method = aws_api_gateway_method.child_methods["${each.value.resource_key}-${each.value.method.http_method}"].http_method

  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${each.value.integration.lambda_arn}/invocations"
  integration_http_method = each.value.integration.integration_http_method
  type                    = each.value.method_data.integration.type
  passthrough_behavior    = try(each.value.method_data.integration.passthrough_behavior, null)
  content_handling        = try(each.value.method_data.integration.content_handling, null)

  request_templates  = try(each.value.method_data.integration.request_templates, {})
  request_parameters = try(each.value.method_data.integration.request_parameters, {})
}

resource "aws_api_gateway_integration" "lambda_parent" {
  for_each = {
    for integration in local.lambda_integrations_parents :
    "${integration.parent_key}-${integration.method_name}" => integration
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.parent[each.value.resource_key].id
  http_method = aws_api_gateway_method.parent_methods["${each.value.resource_key}-${each.value.method.http_method}"].http_method

  type                    = each.value.integration.type
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${each.value.integration.lambda_arn}/invocations"
  integration_http_method = each.value.integration.integration_http_method
  passthrough_behavior    = lookup(each.value.integration, "passthrough_behavior", null)
  content_handling        = lookup(each.value.integration, "content_handling", null)

  request_templates  = lookup(each.value.integration, "request_templates", null)
  request_parameters = lookup(each.value.integration, "request_parameters", null)
}

########AUTHORIZERS########

resource "aws_api_gateway_authorizer" "cognito_user_pool" {
  for_each = var.authorizers

  name                             = each.value.name
  rest_api_id                      = aws_api_gateway_rest_api.this.id
  type                             = "COGNITO_USER_POOLS"
  provider_arns                    = each.value["provider_arns"]
  identity_source                  = each.value["identity_source"]
  authorizer_result_ttl_in_seconds = each.value["authorizer_result_ttl_in_seconds"]
}

########DOMAIN_NAME########

resource "aws_api_gateway_domain_name" "this" {
  for_each = {
    for stage_name, stage_config in var.stages : stage_name => stage_config
    if stage_config.custom_domain != null && stage_config.custom_domain.certificate_arn != null
  }

  domain_name              = "${each.value.custom_domain.name}.${each.value.custom_domain.zone_name}"
  regional_certificate_arn = each.value.custom_domain.certificate_arn
  #checkov:skip=CKV_AWS_206:Ensure API Gateway Domain uses a modern security Policy
  security_policy = each.value.custom_domain.security_policy

  endpoint_configuration {
    types = try(each.value.custom_domain.endpoint_configuration.types, [])
  }
  tags = var.tags
}

########BASE_PATH_MAPPING########

resource "aws_api_gateway_base_path_mapping" "this" {
  for_each = {
    for stage_name, stage_config in var.stages :
    stage_name => stage_config
    if stage_config.custom_domain != null && stage_config.custom_domain.name != null
  }

  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this[each.key].stage_name
  domain_name = aws_api_gateway_domain_name.this[each.key].domain_name
}

########WAF########

resource "aws_wafv2_web_acl_association" "this" {
  for_each = {
    for stage_name, stage_config in var.stages :
    stage_name => stage_config
    if contains(keys(stage_config), "web_acl_arn") && stage_config.web_acl_arn != null
  }

  resource_arn = aws_api_gateway_stage.this[each.key].execution_arn
  web_acl_arn  = each.value.web_acl_arn
}
