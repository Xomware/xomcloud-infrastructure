# ECR Repositories for Lambda container images

resource "aws_ecr_repository" "authorizer" {
  name                 = "${var.app_name}-authorizer"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-authorizer" }))

  lifecycle { ignore_changes = [tags, tags_all] }
}

resource "aws_ecr_repository" "download_tracks" {
  name                 = "${var.app_name}-download-tracks"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-download-tracks" }))

  lifecycle { ignore_changes = [tags, tags_all] }
}

# Lifecycle policy to keep only last 5 images
resource "aws_ecr_lifecycle_policy" "authorizer" {
  repository = aws_ecr_repository.authorizer.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "download_tracks" {
  repository = aws_ecr_repository.download_tracks.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}


