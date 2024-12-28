locals {
  create_rest_api_policy = var.rest_api_policy != null
  stages_with_logging = {
    for stage_key, stage in var.stages : stage_key => stage.logging_config
    if stage.logging_config != null
  }

  flattened_method_settings = {
    for stage_name, stage in var.stages :
    stage_name => {
      for method_path, method_settings in stage.method_settings :
      "${stage_name}#${method_path}" => {
        stage_name  = stage_name
        method_path = method_path
        settings    = method_settings
      }
    }
    if stage.method_settings != null
  }

  stages_with_method_settings = { for stage_method, method in flatten([for stage_name, methods in local.flattened_method_settings : [for method_name, method_settings in methods : method_settings]]) :
    stage_method => method
  }

  parent_resources = keys(var.resources)

  child_resources = flatten([
    for parent, children in var.resources : [
      for child_key, child_value in children : {
        parent    = parent
        child_key = child_key
        methods   = try(child_value.methods, null)
      }
      if child_key != "methods"
    ]
  ])

  child_resources_with_methods = flatten([
    for res in local.child_resources : [
      for method_key, method_value in res.methods : {
        parent      = res.parent,
        child_key   = res.child_key,
        method      = method_key,
        method_data = method_value
      }
      if length(res.methods) > 0
    ] if res.methods != null
  ])

  parent_resources_with_methods = flatten([
    for parent_key, parent_value in var.resources : [
      for method_key, method_value in try(parent_value.methods, {}) : {
        parent       = parent_key,
        method       = method_key,
        method_data  = method_value,
        resource_key = parent_key,
        http_method  = try(method_value.http_method, null)
      }
      if try(method_value.http_method, null) != null
    ]
  ])

  child_resources_with_method_responses = flatten([
    for parent_key, parent_value in var.resources : [
      for child_key, child_value in parent_value : [
        for method_name, method in try(child_value.methods, {}) :
        {
          parent_key      = parent_key,
          child_key       = child_key,
          resource_key    = "${parent_key}-${child_key}",
          resource_path   = child_key,
          http_method     = method_name,
          method_response = lookup(method, "method_response", null),
          is_child        = child_key != null
        }
        if try(method.method_response, null) != null
      ]
    ]
  ])

  parent_resources_with_method_responses = flatten([
    for parent_key, parent_value in var.resources : [
      for method_key, method_value in try(parent_value.methods, {}) : {
        parent          = parent_key,
        method          = method_key,
        method_data     = method_value,
        resource_key    = parent_key,
        method_response = try(method_value.method_response, null)
      }
      if try(method_value.method_response, null) != null && length(keys(method_value.method_response)) > 0
    ]
  ])

  integration_responses_child = flatten([
    for parent_key, parent_value in var.resources : [
      for child_key, child_value in parent_value : [
        for method_name, method in try(child_value.methods, {}) : {
          parent               = parent_key,
          child                = child_key,
          method               = method_name,
          http_method          = method.http_method,
          resource_key         = "${replace(parent_key, "/", "-")}-${replace(child_key, "/", "-")}",
          integration_response = lookup(method.integration, "integration_response", null)
        }
        if try(method.integration.integration_response, null) != null && try(method.integration.integration_response.status_code, null) != null
      ]
    ]
  ])

  integration_responses_parent = flatten([
    for parent_key, parent_value in var.resources : [
      for method_name, method in try(parent_value.methods, {}) : {
        parent_key           = parent_key,
        method_name          = method_name,
        http_method          = method.http_method,
        method               = method,
        integration          = lookup(method, "integration", {}),
        resource_key         = parent_key,
        integration_response = try(method.integration.integration_response, null)
      }
      if try(method.integration.integration_response, null) != null && try(method.integration.integration_response.status_code, null) != null
    ]
  ])

  vpc_link_integrations_child = flatten([
    for parent_key, parent_value in var.resources : [
      for child_key, child_value in parent_value : [
        for method_name, method in try(child_value.methods, {}) :
        {
          parent_key   = parent_key,
          child_key    = child_key,
          method_name  = method_name,
          method       = method,
          http_method  = method.http_method,
          integration  = lookup(method, "integration", {}),
          resource_key = "${parent_key}-${child_key}",
          is_child     = child_key != null
        }
        if try(lookup(method, "integration", {}), null) != null && lookup(try(method.integration, {}), "connection_type", "") == "VPC_LINK"
      ]
    ]
  ])

  vpc_link_integrations_parents = flatten([
    for parent_key, parent_value in var.resources : [
      for method_name, method in try(parent_value.methods, {}) :
      {
        parent_key   = parent_key,
        method_name  = method_name,
        method       = method,
        http_method  = method.http_method,
        integration  = lookup(method, "integration", {}),
        resource_key = parent_key
      }
      if try(lookup(method, "integration", {}), null) != null &&
      lookup(try(method.integration, {}), "connection_type", "") == "VPC_LINK"
    ]
  ])

  mock_integrations_chaid = flatten([
    for parent_key, parent_value in var.resources : [
      for child_key, child_value in parent_value : [
        for method_name, method in try(child_value.methods, {}) : {
          parent_key    = parent_key,
          child_key     = child_key,
          resource_key  = "${parent_key}-${child_key}",
          resource_path = child_key,
          method_name   = method_name,
          http_method   = method.http_method
          integration   = lookup(method, "integration", {}),
          is_child      = child_key != null
        }
        if lookup(method, "integration", null) != null && lookup(try(method.integration, {}), "type", "") == "MOCK"
      ]
    ]
  ])

  mock_integrations_parents = flatten([
    for parent_key, parent_value in var.resources : [
      for method_name, method in try(parent_value.methods, {}) :
      {
        parent_key   = parent_key,
        method_name  = method_name,
        method       = method,
        http_method  = method.http_method
        integration  = lookup(method, "integration", {}),
        resource_key = parent_key
      }
      if try(lookup(method, "integration", {}), null) != null &&
      lookup(try(method.integration, {}), "connection_type", "") == "MOCK"
    ]
  ])

  lambda_integrations_child = flatten([
    for parent_key, parent_value in var.resources : [
      for child_key, child_value in parent_value : [
        for method_name, method in try(child_value.methods, {}) :
        {
          parent_key   = parent_key,
          child_key    = child_key,
          method_name  = method_name,
          method       = method,
          integration  = lookup(method, "integration", {}),
          resource_key = "${parent_key}-${child_key}",
          is_child     = child_key != null
        }
        if lookup(method, "integration", null) != null && lookup(try(method.integration, {}), "connection_type", "") == "LAMBDA"
      ]
    ]
  ])

  lambda_integrations_parents = flatten([
    for parent_key, parent_value in var.resources : [
      for method_name, method in try(parent_value.methods, {}) :
      {
        parent_key   = parent_key,
        method_name  = method_name,
        method       = method,
        integration  = lookup(method, "integration", {}),
        resource_key = parent_key
      }
      if try(lookup(method, "integration", {}), null) != null &&
      lookup(try(method.integration, {}), "connection_type", "") == "LAMBDA"
    ]
  ])

  grandchild_resources = flatten([
    for parent, children in var.resources : [
      for child_key, child_value in children : [
        for grandchild_key, grandchild_value in child_value : {
          parent         = parent
          child_key      = child_key
          grandchild_key = grandchild_key
          methods        = try(grandchild_value.methods, null)
        }
        if grandchild_key != "methods"
      ]
      if child_key != "methods" && length(try(keys(child_value), [])) > 0
    ]
  ])

  grandchild_resources_with_methods = flatten([
    for res in local.grandchild_resources : [
      for method_key, method_value in res.methods : {
        grandchild_key = res.grandchild_key,
        parent         = res.parent,
        child_key      = res.child_key,
        method         = method_key,
        method_data    = method_value
      }
      if length(res.methods) > 0
    ] if res.methods != null
  ])

  great_grandchild_resources = flatten([
    for parent, children in var.resources : [
      for child_key, child_value in children : [
        for grandchild_key, grandchild_value in child_value : [
          for great_grandchild_key, great_grandchild_value in grandchild_value : {
            parent               = parent
            child_key            = child_key
            grandchild_key       = grandchild_key
            great_grandchild_key = great_grandchild_key
            methods              = try(great_grandchild_value.methods, null)
          }
          if great_grandchild_key != "methods"
        ]
        if grandchild_key != "methods" && length(try(keys(grandchild_value), [])) > 0
      ]
      if child_key != "methods" && length(try(keys(child_value), [])) > 0
    ]
  ])

  great_grandchild_resources_with_methods = flatten([
    for res in local.great_grandchild_resources : [
      for method_key, method_value in res.methods : {
        great_grandchild_key = res.great_grandchild_key,
        grandchild_key       = res.grandchild_key,
        parent               = res.parent,
        child_key            = res.child_key,
        method               = method_key,
        method_data          = method_value
      }
      if length(res.methods) > 0
    ] if res.methods != null
  ])

  access_log_format_default = jsonencode({
    requestTime              = "$context.requestTime"
    requestId                = "$context.requestId"
    httpMethod               = "$context.httpMethod"
    path                     = "$context.path"
    resourcePath             = "$context.resourcePath"
    status                   = "$context.status"
    responseLatency          = "$context.responseLatency"
    xrayTraceId              = "$context.xrayTraceId"
    integrationRequestId     = "$context.integration.requestId"
    functionResponseStatus   = "$context.integration.status"
    integrationLatency       = "$context.integration.latency"
    integrationServiceStatus = "$context.integration.integrationStatus"
    authorizeResultStatus    = "$context.authorize.status"
    authorizerServiceStatus  = "$context.authorizer.status"
    authorizerLatency        = "$context.authorizer.latency"
    authorizerRequestId      = "$context.authorizer.requestId"
    ip                       = "$context.identity.sourceIp"
    userAgent                = "$context.identity.userAgent"
    principalId              = "$context.authorizer.principalId"
    cognitoUser              = "$context.identity.cognitoIdentityId"
    user                     = "$context.identity.user"
  })
}
