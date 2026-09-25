# AIオーケストレーターが利用するAWS IAMロール（ECS / Lambda / EKS想定）
resource "aws_iam_role" "ai_orchestrator" {
  name        = "enterprise-ai-orchestrator-role"
  description = "Role assumed by AI workloads to request cross-cloud GCP access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Purpose     = "multi-cloud-ai"
  }
}

# 最小権限ポリシー：自身のCallerIdentity取得とCloudWatchメトリクス送信のみ許可
resource "aws_iam_policy" "orchestrator_base" {
  name        = "enterprise-ai-orchestrator-policy"
  description = "Minimal baseline policy for AWS AI workload"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "orchestrator_attach" {
  role       = aws_iam_role.ai_orchestrator.name
  policy_arn = aws_iam_policy.orchestrator_base.arn
}
