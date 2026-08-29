# API Gateway Account (account-level singleton)
## API Gateway Account (account-level singleton) — INTENTIONALLY NOT MANAGED HERE
#
# `aws_api_gateway_account` is ONE setting per AWS account per region. Seven app
# repos in this account were each managing it and each pointing
# `cloudwatch_role_arn` at their OWN `<app>-api_gateway-logs` role, so every
# apply flipped the account's logging role and the next repo's plan flipped it
# back — perpetual drift on every plan, in every repo.
#
# A shared singleton needs a single owner. `xomware-infrastructure` owns it now
# (its `api_gateway_account.tf`), which is where xomtracks and today-in-sports
# had already said it belonged. This repo defers.
#
# Removing the resource is safe: the provider's destroy of
# `aws_api_gateway_account` is a no-op, because there is no AWS API to reset
# account settings. The live setting is left intact and simply drops out of this
# repo's state. The `api_gateway_cloudwatch` role is retained — the live pointer
# may still name it, and deleting a role that is still pointed at would break
# account-wide API Gateway logging.

#**********************
# API Gateway (via reusable module)
#**********************

locals {
  download_endpoints = [
    {
      name        = "tracks"
      path_part   = "tracks"
      http_method = "POST"
      invoke_arn  = aws_lambda_function.download_tracks.invoke_arn
    }
  ]
}

module "api" {
  source = "git::https://github.com/domgiordano/api-gateway-service.git?ref=v2.8.0"

  app_name              = var.app_name
  stage_name            = "dev"
  authorizer_invoke_arn = aws_lambda_function.authorizer.invoke_arn
  authorizer_role_arn   = aws_iam_role.lambda_role.arn
  tags                  = local.standard_tags
  allow_headers         = local.api_allow_headers
  allow_origin          = "https://xomcloud.xomware.com"

  # Custom domain
  domain_name     = local.api_domain_name
  certificate_arn = aws_acm_certificate_validation.api.certificate_arn

  services = {
    download = { path_prefix = "download", endpoints = local.download_endpoints }
  }
}
