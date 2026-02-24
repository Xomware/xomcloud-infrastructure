variable "app_name" {
  description = "The name for the application."
  default     = "xomcloud"
}

variable "domain_suffix" {
  description = "Suffix for the domain of the app."
  default     = ".xomware.com"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "api_auth_token" {
  description = "API Auth token"
  sensitive   = true
}

variable "api_secret_key" {
  description = "API secret key"
  sensitive   = true
}

variable "cloudfront_origin_path" {
  type        = string
  default     = ""
  description = "Optional element for cloudfront distribution that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin."
}

variable "us_canada_only" {
  type        = bool
  default     = true
  description = "If a georestriction should be placed on the distribution to only provide access to the US and Canada"
}

variable "custom_error_response_page_path" {
  type        = string
  default     = "/index.html"
  description = "custom error response page path."
}

variable "retain_on_delete" {
  type        = bool
  default     = false
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform."
}


variable "minimum_tls_version" {
  type        = string
  default     = "TLSv1.2_2018"
  description = "minimum tls version"
}

variable "enable_cloudfront_cache" {
  type        = bool
  default     = true
  description = "This variable controls the cloudfront cache. Setting this to false will set the default_ttl and max_ttl values to zero"
}

# Lambda
variable "lambda_runtime" {
  type    = string
  default = "python3.10"
}

variable "lambda_trace_mode" {
  type    = string
  default = "Active"
}

variable "lambda_aiohttp_active" {
  type    = bool
  default = false
}

# ========================================
# SoundCloud API Variables
# ========================================

variable "soundcloud_client_id" {
  description = "SoundCloud API Client ID"
  type        = string
  sensitive   = true
}

variable "soundcloud_client_secret" {
  description = "SoundCloud API Client Secret"
  type        = string
  sensitive   = true
}
