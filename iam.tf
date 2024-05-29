resource "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "1b511abead59c6ce207077c0bf0e0043b1382612"
  ]

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "tf-role" {
  name = "tf-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:eusouodaniel/rocketseat.ci.iac:ref:refs/heads/main"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::403429280851:oidc-provider/token.actions.githubusercontent.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "app-runner-role" {
  name = app-runner-role

  assume_role_policy = jsondecode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "Service" = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:eusouodaniel/rocketseat.ci.api:ref:refs/heads/main"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::403429280851:oidc-provider/token.actions.githubusercontent.com"
        }
      }
    ]
    Version = "2012-10-17"
  })

  inline_policy {
    name = "ecr-app-permissions"
    policy = jsonencode({
      Statement = [{
        Sid      = "Statement1"
        Action   = "apprunner:*"
        Effect   = "Allow"
        Resource = "*"
        },
        {
          Sid = "Statement2"
          Action = [
            "iam:PassRole",
            "iam:CreateServiceLinkedRole",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid = "Statement3"
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    IAC = "True"
  }
}
