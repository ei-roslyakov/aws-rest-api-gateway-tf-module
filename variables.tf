variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "endpoint_type" {
  type        = string
  description = "The type of the endpoint. One of - PUBLIC, PRIVATE, REGIONAL"
  default     = "REGIONAL"

  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_type)
    error_message = "Valid values for var: endpoint_type are (EDGE, REGIONAL, PRIVATE)."
  }
}

variable "private_links" {
  description = "A map of private link target ARNs to create VPC links for"
  type = map(object({
    name        = optional(string)
    description = optional(string)
    target_arns = list(string)
  }))
  default = {}
}

variable "rest_api_policy" {
  description = "The IAM policy document for the API."
  type        = string
  default     = null
}


variable "authorizers" {
  description = "Map of API Gateway authorizers"
  type = map(object({
    name                             = string
    provider_arns                    = list(string)
    identity_source                  = string
    type                             = string
    authorizer_result_ttl_in_seconds = optional(number, 300)
  }))
  default = {}
}

variable "resources" {
  description = "A map of API Gateway resources to create"
  type        = any
  default     = {}
}

variable "stages" {
  description = "A map of API Gateway stages to create"
  type = map(object({
    name                  = optional(string)
    description           = optional(string)
    web_acl_arn           = optional(string)
    cache_cluster_enabled = optional(bool)
    cache_cluster_size    = optional(string)
    client_certificate_id = optional(string)
    vpc_link_name         = optional(string)
    variables             = optional(map(string))
    xray_tracing_enabled  = optional(bool)
    custom_domain = optional(object({
      certificate_arn = optional(string)
      security_policy = optional(string, "TLS_1_2")
      zone_name       = optional(string)
      name            = optional(string)
      endpoint_configuration = optional(object({
        types = list(string)
      }))
      route_53_record_params = optional(object({
        allow_overwrite              = optional(bool)
        private_zone                 = optional(bool)
        alias_evaluate_target_health = optional(bool, false)
        tags                         = optional(map(string), {})
      }))
    }))
    logging_config = optional(object({
      retention_in_days = optional(number)
      kms_key_id        = optional(string)
      access_log_format = optional(string)
    }))
    canary_settings = optional(object({
      canary_percent_traffic          = optional(number)
      canary_stage_variable_overrides = optional(map(string))
      canary_use_stage_cache          = optional(bool)
    }))
    method_settings = optional(map(object({
      method_path                                = optional(string)
      metrics_enabled                            = optional(bool)
      data_trace_enabled                         = optional(bool)
      log_level                                  = optional(string)
      throttling_burst_limit                     = optional(number)
      throttling_rate_limit                      = optional(number)
      caching_enabled                            = optional(bool)
      cache_data_encrypted                       = optional(bool)
      cache_ttl_in_seconds                       = optional(number)
      require_authorization_for_cache_control    = optional(bool)
      unauthorized_cache_control_header_strategy = optional(string)
    })))
  }))
  default = {}
}
