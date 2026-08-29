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
