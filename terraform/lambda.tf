# TODO(#41): Pin image_uri to a digest instead of :latest for reproducible deploys.
# The image_uri is managed by CI (ignored in lifecycle) so the :latest tag here is
# only used on initial creation. CI should push and update with a SHA digest.
resource "aws_lambda_function" "download_tracks" {
  function_name = "${var.app_name}-download-tracks"
  description   = "Lambda Function for downloading soundcloud tracks, zipping, uploading to s3 and returning a presigned url."
  package_type  = "Image"
  architectures = ["x86_64"]
  image_uri     = "${aws_ecr_repository.download_tracks.repository_url}:latest"
  memory_size   = 1024
  timeout       = 300
  role          = aws_iam_role.lambda_role.arn
  environment {
    variables = merge(local.lambda_variables, { S3_DOWNLOAD_BUCKET_NAME = aws_s3_bucket.downloads.id })
  }

  image_config {
    command = ["lambdas.download_tracks.handler.handler"]
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-download-tracks" }))

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