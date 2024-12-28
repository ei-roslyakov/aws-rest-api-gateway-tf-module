# REST API Gateway Terraform Module

This Terraform module automates the creation and management of an API Gateway in AWS. The module includes features for creating VPC links, API stages, methods, integrations, and custom domain names.

Key features of the module include:

* **VPC Links**: Establishes secure connections between API Gateway and private resources in your VPC.
* **API Gateway Stages**: Manages different stages of your API (e.g., development, testing, production), each with its own configuration.
* **REST API Deployment**: Automatically deploys your API Gateway using a provided OpenAPI specification.
* **Method and Resource Configuration**: Allows detailed configuration of methods and resources, including support for parent-child resource relationships.
* **Integrations**: Supports HTTP, HTTP Proxy, and MOCK integrations, with the option to link to VPC resources.
* **Custom Domain Names**: Configures custom domains for your API Gateway, including SSL certificates.
* **Route 53 DNS Records**: Automatically creates Route 53 DNS records for your API Gateway custom domains, pointing to the correct regional or CloudFront endpoint.
* **Logging and Monitoring**: Sets up CloudWatch log groups and integrates with AWS X-Ray for tracing.

This module is designed to be flexible, allowing for extensive customization while adhering to best practices for API Gateway deployments in AWS.

## Usage

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "path"
}

locals {
  lb_balancer_arn = "arn"
  allow_origin    = "[\"https://example.com\"]"
}

inputs = {

  api_gateway_name = "${basename(get_terragrunt_dir())}"

  private_links = {
    lb_dev = {
      name        = "lb_dev"
      description = "Internal Load Balancer"
      target_arns = [
        local.lb_balancer_arn
      ]
    }
  }

  authorizers = {
    "dev" = {
      name            = "dev"
      identity_source = "method.request.header.Authorization"
      provider_arns = [
        "arn"
      ]
      type = "COGNITO_USER_POOLS"
    }
  }

  resources = {
    "user" = {
      "users" = {
        "{userName}" = {
          "sync" = {
            methods = {
              "ANY" = {
                http_method   = "ANY"
                authorization = "NONE"
                request_parameters = {
                  "method.request.path.proxy" = true
                }
                method_response = {
                  status_code = "200"
                  response_models = {
                    "application/json" = "Empty"
                  }
                }
                integration = {
                  type                    = "HTTP_PROXY"
                  uri                     = "${local.k8s_infra_internal_balancer_url}/user/{proxy}"
                  integration_http_method = "ANY"
                  connection_type         = "VPC_LINK"
                  vpc_link_name           = local.vpc_link_name
                  cache_key_parameters    = ["method.request.path.proxy"]
                  request_parameters = {
                    "integration.request.path.proxy" = "method.request.path.proxy"
                  }
                }
              }
            }
          }
        }
      }
      "{proxy+}" = {
        methods = {
          "ANY" = {
            http_method   = "ANY"
            authorization = "NONE"
            request_parameters = {
              "method.request.path.proxy" = true
            }
            method_response = {
              status_code = "200"
              response_models = {
                "application/json" = "Empty"
              }
            }
            integration = {
              type                    = "HTTP_PROXY"
              uri                     = "${local.k8s_infra_internal_balancer_url}/user/{proxy}"
              integration_http_method = "ANY"
              connection_type         = "VPC_LINK"
              vpc_link_name           = "lb_dev"
              cache_key_parameters    = ["method.request.path.proxy"]
              request_parameters = {
                "integration.request.path.proxy" = "method.request.path.proxy"
              }
            }
          },
          "OPTIONS" = {
            http_method        = "OPTIONS"
            authorization      = "NONE"
            request_parameters = {}
            method_response = {
              status_code = "200"
              response_models = {
                "application/json" = "Empty"
              }
              response_parameters = {
                "method.response.header.Access-Control-Allow-Headers" = true
                "method.response.header.Access-Control-Allow-Methods" = true
                "method.response.header.Access-Control-Allow-Origin"  = true
              }
            }
            integration = {
              type                    = "MOCK"
              integration_http_method = "OPTIONS"
              integration_response = {
                status_code = "200"
                response_templates = {
                  "application/json" = <<-EOT
                    $input.json("$")
                    #set($domains = [${local.allow_origin}])
                    #set($origin = $input.params("origin"))
                    #if($domains.contains($origin))
                    #set($context.responseOverride.header.Access-Control-Allow-Origin="$origin")
                    #end
                  EOT
                }
                response_parameters = {
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
                }
              }
              request_templates = {
                "application/json" = "{\"statusCode\": 200}"
              }
            }
          }
        }
      },
      "swagger" = {
        "{proxy+}" = {
          methods = {
            "ANY" = {
              http_method   = "ANY"
              authorization = "NONE"
              request_parameters = {
                "method.request.path.proxy" = true
              }
              method_response = {}
              integration = {
                type                    = "HTTP_PROXY"
                uri                     = "${local.k8s_infra_internal_balancer_url}/user/swagger/{proxy}"
                integration_http_method = "ANY"
                connection_type         = "VPC_LINK"
                vpc_link_name           = local.vpc_link_name
                cache_key_parameters    = ["method.request.path.proxy"]
                request_parameters = {
                  "integration.request.path.proxy" = "method.request.path.proxy"
                }
                integration_response = {}
              }
            }
          }
        }
      }
    },
    "api" = {
      "{proxy+}" = {
        methods = {
          "ANY" = {
            http_method            = "ANY"
            authorization          = "COGNITO_USER_POOLS"
            cognito_user_pool_name = "dev"
            request_parameters = {
              "method.request.path.proxy" = true
            }
            method_response = {
              status_code = "200"
              response_models = {
                "application/json" = "Empty"
              }
              response_parameters = {
                "method.response.header.Access-Control-Allow-Methods" = true
                "method.response.header.Access-Control-Allow-Origin"  = true
              }
            }
            integration = {
              type                    = "HTTP_PROXY"
              uri                     = "${local.k8s_infra_internal_balancer_url}/api/{proxy}"
              integration_http_method = "ANY"
              connection_type         = "VPC_LINK"
              vpc_link_name           = local.vpc_link_name
              cache_key_parameters    = ["method.request.path.proxy"]
              request_parameters = {
                "integration.request.path.proxy" = "method.request.path.proxy"
              }
            }
          }
        }
      },
      "swagger" = {
        "{proxy+}" = {
          methods = {
            "ANY" = {
              http_method   = "ANY"
              authorization = "NONE"
              request_parameters = {
                "method.request.path.proxy" = true
              }
              method_response = {}
              integration = {
                type                    = "HTTP_PROXY"
                uri                     = "${local.k8s_infra_internal_balancer_url}/api/swagger/{proxy+}"
                integration_http_method = "ANY"
                connection_type         = "VPC_LINK"
                vpc_link_name           = local.vpc_link_name
                request_parameters = {
                  "integration.request.path.proxy" = "method.request.path.proxy"
                }
                integration_response = {}
              }
            }
          }
        }
      }
    },
    "service" = {
      "{proxy+}" = {
        methods = {
          "ANY" = {
            http_method            = "ANY"
            authorization          = "COGNITO_USER_POOLS"
            cognito_user_pool_name = "dev"
            request_parameters = {
              "method.request.path.proxy" = true
            }
            method_response = {
              status_code = "200"
              response_models = {
                "application/json" = "Empty"
              }
            }
            integration = {
              type                    = "HTTP_PROXY"
              uri                     = "${local.k8s_infra_internal_balancer_url}/service/{proxy}"
              integration_http_method = "ANY"
              connection_type         = "VPC_LINK"
              vpc_link_name           = local.vpc_link_name
              cache_key_parameters    = ["method.request.path.proxy"]
              request_parameters = {
                "integration.request.path.proxy" = "method.request.path.proxy"
              }
            }
          }
        }
      },
      "swagger" = {
        "{proxy+}" = {
          methods = {
            "ANY" = {
              http_method   = "ANY"
              authorization = "NONE"
              request_parameters = {
                "method.request.path.proxy" = true
              }
              method_response = {}
              integration = {
                type                    = "HTTP_PROXY"
                uri                     = "${local.k8s_infra_internal_balancer_url}/service/swagger/{proxy+}"
                integration_http_method = "ANY"
                connection_type         = "VPC_LINK"
                vpc_link_name           = local.vpc_link_name
                request_parameters = {
                  "integration.request.path.proxy" = "method.request.path.proxy"
                }
                integration_response = {}
              }
            }
          }
        }
      }
    }
    "data" = {
      "{proxy+}" = {
        methods = {
          "ANY" = {
            http_method            = "ANY"
            authorization          = "COGNITO_USER_POOLS"
            cognito_user_pool_name = "dev"
            request_parameters = {
              "method.request.path.proxy" = true
            }
            method_response = {
              status_code = "200"
              response_models = {
                "application/json" = "Empty"
              }
            }
            integration = {
              type                    = "HTTP_PROXY"
              uri                     = "${local.k8s_infra_internal_balancer_url}/data/{proxy}"
              integration_http_method = "ANY"
              connection_type         = "VPC_LINK"
              vpc_link_name           = local.vpc_link_name
              cache_key_parameters    = ["method.request.path.proxy"]
              request_parameters = {
                "integration.request.path.proxy" = "method.request.path.proxy"
              }
            }
          }
        }
      },
      "swagger" = {
        "{proxy+}" = {
          methods = {
            "ANY" = {
              http_method   = "ANY"
              authorization = "NONE"
              request_parameters = {
                "method.request.path.proxy" = true
              }
              method_response = {}
              integration = {
                type                    = "HTTP_PROXY"
                uri                     = "${local.k8s_infra_internal_balancer_url}/data/swagger/{proxy+}"
                integration_http_method = "ANY"
                connection_type         = "VPC_LINK"
                vpc_link_name           = local.vpc_link_name
                request_parameters = {
                  "integration.request.path.proxy" = "method.request.path.proxy"
                }
                integration_response = {}
              }
            }
          }
        }
      }
    }
    "get-cookies" = {
      methods = {
        "GET" = {
          http_method            = "GET"
          authorization          = "COGNITO_USER_POOLS"
          cognito_user_pool_name = "dev"
          request_parameters = {
            "method.request.path.proxy" = true
          }
          method_response = {
            status_code = "200"
            response_models = {
              "application/json" = "Empty"
            }
          }
          integration = {
            type                    = "AWS_PROXY"
            integration_http_method = "POST"
            connection_type         = "LAMBDA"
            lambda_arn              = local.get_signed_cookies_lambda_arn
            cache_key_parameters    = ["method.request.path.proxy"]
          }
        }
      }
    }
  }

  stages = {
    dev = {
      name                  = "dev"
      description           = "My owesom description dev"
      cache_cluster_enabled = "false"
      vpc_link_name         = "lb_dev"
      variables = {
        "var1" = "value1"
      }
      xray_tracing_enabled = "false"
      custom_domain = {
        domain_name     = "api.example.com"
        certificate_arn = "arn"
        route53_zone_id = "zone_id"
        endpoint_configuration = {
          types = ["REGIONAL"]
        }
      }
      logging_config = {
        retention_in_days = 30
      }
      method_settings = {
        "*/*" = {
          method_path                                = "*/*"
          metrics_enabled                            = true
          data_trace_enabled                         = true
          log_level                                  = "INFO"
          throttling_burst_limit                     = 5000
          throttling_rate_limit                      = 10000
          caching_enabled                            = true
          cache_data_encrypted                       = false
          cache_ttl_in_seconds                       = 300
          require_authorization_for_cache_control    = true
          unauthorized_cache_control_header_strategy = "SUCCEED_WITH_RESPONSE_HEADER"
        }
      }
    }
    test = {
      name                  = "test"
      description           = "My owesom description test"
      cache_cluster_enabled = "false"
      variables = {
        "var1" = "value1"
      }
      xray_tracing_enabled = "false"
      custom_domain        = {}
      logging_config = {
        retention_in_days = 30
        kms_key_id        = "arn"
      }
    }
  }
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.62 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.62 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_route53_record"></a> [route53\_record](#module\_route53\_record) | git::https://github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records | e3e35482b7d8d430b505c8dba858b95b9a379601 |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_authorizer.cognito_user_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_base_path_mapping.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_integration.lambda_child](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.lambda_grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.lambda_great_grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.lambda_parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.mock_child](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.mock_grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.mock_great_grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.mock_parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.vpc_link_child](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.vpc_link_grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.vpc_link_great_grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.vpc_link_parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.child](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.great_grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.child_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.grandchild_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.great_grandchild_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.parent_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.child_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.grandchild_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.great_grandchild_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.parent_methods](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.child](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.great-grandchild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_rest_api_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api_policy) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_vpc_link.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_gateway_name"></a> [api\_gateway\_name](#input\_api\_gateway\_name) | The name of the API Gateway | `string` | `""` | no |
| <a name="input_authorizers"></a> [authorizers](#input\_authorizers) | Map of API Gateway authorizers | <pre>map(object({<br/>    name                             = string<br/>    provider_arns                    = list(string)<br/>    identity_source                  = string<br/>    type                             = string<br/>    authorizer_result_ttl_in_seconds = optional(number, 300)<br/>  }))</pre> | `{}` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The type of the endpoint. One of - PUBLIC, PRIVATE, REGIONAL | `string` | `"REGIONAL"` | no |
| <a name="input_private_links"></a> [private\_links](#input\_private\_links) | A map of private link target ARNs to create VPC links for | <pre>map(object({<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    target_arns = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | A map of API Gateway resources to create | `any` | `{}` | no |
| <a name="input_rest_api_policy"></a> [rest\_api\_policy](#input\_rest\_api\_policy) | The IAM policy document for the API. | `string` | `null` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | A map of API Gateway stages to create | <pre>map(object({<br/>    name                  = optional(string)<br/>    description           = optional(string)<br/>    web_acl_arn           = optional(string)<br/>    cache_cluster_enabled = optional(bool)<br/>    cache_cluster_size    = optional(string)<br/>    client_certificate_id = optional(string)<br/>    vpc_link_name         = optional(string)<br/>    variables             = optional(map(string))<br/>    xray_tracing_enabled  = optional(bool)<br/>    custom_domain = optional(object({<br/>      certificate_arn = optional(string)<br/>      security_policy = optional(string, "TLS_1_2")<br/>      zone_name       = optional(string)<br/>      name            = optional(string)<br/>      endpoint_configuration = optional(object({<br/>        types = list(string)<br/>      }))<br/>      route_53_record_params = optional(object({<br/>        allow_overwrite              = optional(bool)<br/>        private_zone                 = optional(bool)<br/>        alias_evaluate_target_health = optional(bool, false)<br/>        tags                         = optional(map(string), {})<br/>      }))<br/>    }))<br/>    logging_config = optional(object({<br/>      retention_in_days = optional(number)<br/>      kms_key_id        = optional(string)<br/>      access_log_format = optional(string)<br/>    }))<br/>    canary_settings = optional(object({<br/>      canary_percent_traffic          = optional(number)<br/>      canary_stage_variable_overrides = optional(map(string))<br/>      canary_use_stage_cache          = optional(bool)<br/>    }))<br/>    method_settings = optional(map(object({<br/>      method_path                                = optional(string)<br/>      metrics_enabled                            = optional(bool)<br/>      data_trace_enabled                         = optional(bool)<br/>      log_level                                  = optional(string)<br/>      throttling_burst_limit                     = optional(number)<br/>      throttling_rate_limit                      = optional(number)<br/>      caching_enabled                            = optional(bool)<br/>      cache_data_encrypted                       = optional(bool)<br/>      cache_ttl_in_seconds                       = optional(number)<br/>      require_authorization_for_cache_control    = optional(bool)<br/>      unauthorized_cache_control_header_strategy = optional(string)<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_custom_domains"></a> [api\_gateway\_custom\_domains](#output\_api\_gateway\_custom\_domains) | Map of custom domains associated with the API Gateway stages. |
| <a name="output_authorizer_ids"></a> [authorizer\_ids](#output\_authorizer\_ids) | The IDs of the API Gateway authorizers |
| <a name="output_child_integration_ids"></a> [child\_integration\_ids](#output\_child\_integration\_ids) | The IDs of the API Gateway child integrations |
| <a name="output_child_method_ids"></a> [child\_method\_ids](#output\_child\_method\_ids) | The IDs of the API Gateway child methods |
| <a name="output_deployment_ids"></a> [deployment\_ids](#output\_deployment\_ids) | The IDs of the deployments |
| <a name="output_grandchild_integration_ids"></a> [grandchild\_integration\_ids](#output\_grandchild\_integration\_ids) | The IDs of the API Gateway grandchild integrations |
| <a name="output_grandchild_method_ids"></a> [grandchild\_method\_ids](#output\_grandchild\_method\_ids) | The IDs of the API Gateway grandchild methods |
| <a name="output_great_grandchild_integration_ids"></a> [great\_grandchild\_integration\_ids](#output\_great\_grandchild\_integration\_ids) | The IDs of the API Gateway great grandchild integrations |
| <a name="output_great_grandchild_method_ids"></a> [great\_grandchild\_method\_ids](#output\_great\_grandchild\_method\_ids) | The IDs of the API Gateway great grandchild methods |
| <a name="output_log_group_names"></a> [log\_group\_names](#output\_log\_group\_names) | The names of the CloudWatch Log Groups |
| <a name="output_parent_integration_ids"></a> [parent\_integration\_ids](#output\_parent\_integration\_ids) | The IDs of the API Gateway parent integrations |
| <a name="output_parent_method_ids"></a> [parent\_method\_ids](#output\_parent\_method\_ids) | The IDs of the API Gateway parent methods |
| <a name="output_resource_child_ids"></a> [resource\_child\_ids](#output\_resource\_child\_ids) | The IDs of the API Gateway child resources |
| <a name="output_resource_grandchild_ids"></a> [resource\_grandchild\_ids](#output\_resource\_grandchild\_ids) | The IDs of the API Gateway grandchild resources |
| <a name="output_resource_great_grandchild_ids"></a> [resource\_great\_grandchild\_ids](#output\_resource\_great\_grandchild\_ids) | The IDs of the API Gateway great grandchild resources |
| <a name="output_resource_parent_ids"></a> [resource\_parent\_ids](#output\_resource\_parent\_ids) | The IDs of the API Gateway parent resources |
| <a name="output_rest_api_arn"></a> [rest\_api\_arn](#output\_rest\_api\_arn) | The ARN of the API Gateway REST API |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | The ID of the API Gateway REST API |
| <a name="output_route53_record_fqdn"></a> [route53\_record\_fqdn](#output\_route53\_record\_fqdn) | FQDN built using the zone domain and name |
| <a name="output_route53_record_name"></a> [route53\_record\_name](#output\_route53\_record\_name) | The name of the Route53 record |
| <a name="output_stage_names"></a> [stage\_names](#output\_stage\_names) | The names of the API Gateway stages |
| <a name="output_vpc_link_ids"></a> [vpc\_link\_ids](#output\_vpc\_link\_ids) | The IDs of the created VPC links |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
