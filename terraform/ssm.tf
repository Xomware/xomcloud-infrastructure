# AWS
resource "aws_ssm_parameter" "access_key" {
  name        = "/${var.app_name}/aws/ACCESS_KEY"
  description = "AWS Access Key"
  type        = "SecureString"
  value       = var.access_key
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-aws-access-key" }))
}
resource "aws_ssm_parameter" "secret_key" {
  name        = "/${var.app_name}/aws/SECRET_KEY"
  description = "AWS Secret Key"
  type        = "SecureString"
  value       = var.secret_key
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-aws-secret-key" }))
}

# SOUNDCLOUD
resource "aws_ssm_parameter" "soundcloud_client_id" {
  name        = "/${var.app_name}/soundcloud/CLIENT_ID"
  description = "Soundcloud Web API Client ID"
  type        = "SecureString"
  value       = var.soundcloud_client_id
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-soundcloud-client-id" }))
}
resource "aws_ssm_parameter" "soundcloud_client_secret" {
  name        = "/${var.app_name}/soundcloud/CLIENT_SECRET"
  description = "SoundCloud API Client Secret"
  type        = "SecureString"
  value       = var.soundcloud_client_secret
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-soundcloud-client-secret" }))
}

# API
resource "aws_ssm_parameter" "api_auth_token" {
  name        = "/${var.app_name}/api/API_AUTH_TOKEN"
  description = "Soundcloud Web API Auth Token"
  type        = "SecureString"
  value       = var.api_auth_token
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-api-auth-token" }))
}

resource "aws_ssm_parameter" "api_secret_key" {
  name        = "/${var.app_name}/api/API_SECRET_KEY"
  description = "Soundcloud Web API Secret Key"
  type        = "SecureString"
  value       = var.api_secret_key
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-api-secret-key" }))
}

resource "aws_ssm_parameter" "api_id" {
  name        = "/${var.app_name}/api/API_ID"
  description = "Soundcloud Web API ID"
  type        = "SecureString"
  value       = module.api.rest_api_id
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-api-id" }))
}
