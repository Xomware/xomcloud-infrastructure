# /auth routes — defined OUTSIDE module.api because the api-gateway-service
# module (v2.2.0) hardcodes `authorization = var.authorization` on every
# endpoint it manages and does NOT expose a per-service `skip_authorizer`
# escape hatch.
#
# The /auth/token and /auth/refresh routes MUST be callable WITHOUT a Bearer
# token — they ARE the auth bootstrap that mints the token the Lambda
# authorizer later validates. So we attach them directly to the REST API
# created by the module via its `rest_api_root_resource_id` output and set
# `authorization = "NONE"` on each method.
#
# CORS / OPTIONS preflight mirrors the pattern in the module's cors.tf.

locals {
  auth_endpoints = [
    {
      name        = "token"
      path_part   = "token"
      http_method = "POST"
      invoke_arn  = aws_lambda_function.auth_token.invoke_arn
    },
    {
      name        = "refresh"
      path_part   = "refresh"
      http_method = "POST"
      invoke_arn  = aws_lambda_function.auth_token.invoke_arn
    },
  ]

  auth_endpoints_map = { for ep in local.auth_endpoints : ep.name => ep }

  # Single-origin: re-use the value passed to the module so behaviour stays
  # consistent with /download/* routes.
  auth_allow_origin = "https://xomcloud.xomware.com"
}

#######################################
# /auth parent resource
#######################################

resource "aws_api_gateway_resource" "auth" {
  rest_api_id = module.api.rest_api_id
  parent_id   = module.api.rest_api_root_resource_id
  path_part   = "auth"
}

#######################################
# Per-endpoint child resources (/auth/token, /auth/refresh)
#######################################

resource "aws_api_gateway_resource" "auth_endpoint" {
  for_each    = local.auth_endpoints_map
  rest_api_id = module.api.rest_api_id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = each.value.path_part
}

#######################################
# POST methods — UNAUTHENTICATED on purpose
#######################################

resource "aws_api_gateway_method" "auth_endpoint" {
  for_each      = local.auth_endpoints_map
  rest_api_id   = module.api.rest_api_id
  resource_id   = aws_api_gateway_resource.auth_endpoint[each.key].id
  http_method   = each.value.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_endpoint" {
  for_each                = local.auth_endpoints_map
  rest_api_id             = module.api.rest_api_id
  resource_id             = aws_api_gateway_resource.auth_endpoint[each.key].id
  http_method             = aws_api_gateway_method.auth_endpoint[each.key].http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = each.value.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_lambda_permission" "auth_endpoint" {
  for_each      = local.auth_endpoints_map
  statement_id  = "AllowAuth${title(each.value.name)}Api"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_token.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.rest_api_execution_arn}/*/*"
}

#######################################
# CORS — OPTIONS preflight per endpoint
#######################################

resource "aws_api_gateway_method" "auth_options" {
  for_each      = local.auth_endpoints_map
  rest_api_id   = module.api.rest_api_id
  resource_id   = aws_api_gateway_resource.auth_endpoint[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_options" {
  for_each    = local.auth_endpoints_map
  rest_api_id = module.api.rest_api_id
  resource_id = aws_api_gateway_resource.auth_endpoint[each.key].id
  http_method = aws_api_gateway_method.auth_options[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }

  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "auth_options" {
  for_each    = local.auth_endpoints_map
  rest_api_id = module.api.rest_api_id
  resource_id = aws_api_gateway_resource.auth_endpoint[each.key].id
  http_method = aws_api_gateway_method.auth_options[each.key].http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_integration_response" "auth_options" {
  for_each    = local.auth_endpoints_map
  rest_api_id = module.api.rest_api_id
  resource_id = aws_api_gateway_resource.auth_endpoint[each.key].id
  http_method = aws_api_gateway_method.auth_options[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'${join(",", local.api_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods"     = "'${each.value.http_method},OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"      = "'${local.auth_allow_origin}'"
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }

  depends_on = [aws_api_gateway_method_response.auth_options]
}
