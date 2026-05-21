# AWS
# TODO(#39): Remove static AWS keys after OIDC migration is complete.
# These SSM params store static IAM credentials used by the Lambda functions.
# Once CI and Lambda auth are migrated to OIDC/IAM roles, delete these params
# and the corresponding variables in variables.tf.
resource "aws_ssm_parameter" "access_key" {
  name        = "/${var.app_name}/aws/ACCESS_KEY"
  description = "AWS Access Key"
  type        = "SecureString"
  value       = var.access_key

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}
resource "aws_ssm_parameter" "secret_key" {
  name        = "/${var.app_name}/aws/SECRET_KEY"
  description = "AWS Secret Key"
  type        = "SecureString"
  value       = var.secret_key

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

# SOUNDCLOUD
# CLIENT_ID is the public OAuth client identifier — stored as a plain String.
# CLIENT_SECRET is the confidential half — stored as SecureString.
resource "aws_ssm_parameter" "soundcloud_client_id" {
  name        = "/${var.app_name}/soundcloud/CLIENT_ID"
  description = "Soundcloud Web API Client ID"
  type        = "String"
  value       = var.soundcloud_client_id

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}
resource "aws_ssm_parameter" "soundcloud_client_secret" {
  name        = "/${var.app_name}/soundcloud/CLIENT_SECRET"
  description = "SoundCloud API Client Secret"
  type        = "SecureString"
  value       = var.soundcloud_client_secret

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

# API
resource "aws_ssm_parameter" "api_auth_token" {
  name        = "/${var.app_name}/api/API_AUTH_TOKEN"
  description = "Soundcloud Web API Auth Token"
  type        = "SecureString"
  value       = var.api_auth_token

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

resource "aws_ssm_parameter" "api_secret_key" {
  name        = "/${var.app_name}/api/API_SECRET_KEY"
  description = "Soundcloud Web API Secret Key"
  type        = "SecureString"
  value       = var.api_secret_key

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

resource "aws_ssm_parameter" "api_id" {
  name        = "/${var.app_name}/api/API_ID"
  description = "Soundcloud Web API ID"
  type        = "SecureString"
  value       = module.api.rest_api_id

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}
