## Resources for API Gateway Lambda Authorization
# TODO(#41): Pin image_uri to a digest instead of :latest for reproducible deploys.
resource "aws_lambda_function" "authorizer" {
  function_name = "${var.app_name}-authorizer"
  description   = "Lambda Authorizer for ${var.app_name}"
  package_type  = "Image"
  architectures = ["x86_64"]
  image_uri     = "${aws_ecr_repository.authorizer.repository_url}:latest"
  memory_size   = 256
  timeout       = 30
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = local.lambda_variables
  }

  image_config {
    command = ["lambdas.authorizer.handler.handler"]
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-authorizer" }))

  tracing_config {
    mode = var.lambda_trace_mode
  }

  lifecycle {
    ignore_changes = [
      description,
      filename,
      source_code_hash,
      layers,
      image_uri
    ]
  }
  depends_on = [
    aws_iam_role_policy.lambda_role_policy,
    aws_iam_role.lambda_role
  ]

}
