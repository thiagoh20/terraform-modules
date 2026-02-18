
data "aws_iam_openid_connect_provider" "github" {
  arn = var.oidc_provider_arn
}
# IAM Role para GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-${replace(var.github_repository, "/", "-")}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name   = var.role_name
      Module = "github-oidc-role"
    }
  )
}


resource "aws_iam_role_policy_attachment" "github_actions" {
  count      = length(var.role_policy_arns)
  role       = aws_iam_role.github_actions.name
  policy_arn = var.role_policy_arns[count.index]
}

resource "aws_iam_role_policy" "github_actions_inline" {
  count  = var.inline_policy_json != null ? 1 : 0
  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.github_actions.id
  policy = var.inline_policy_json
} 