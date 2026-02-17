# Hosted Zone Data Source

data "aws_route53_zone" "web_zone" {
  private_zone = false
  zone_id      = "Z07413232K3KBJ6OKSA9B"
}
