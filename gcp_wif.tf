# 1. Workload Identity プール（AWSワークロード用の信頼境界）
resource "google_iam_workload_identity_pool" "aws_pool" {
  workload_identity_pool_id = "aws-ai-identity-pool"
  display_name              = "AWS AI Identity Pool"
  description               = "Identity pool for federating AWS AI orchestrator workloads"
}

# 2. AWS OIDC プロバイダー（AWS STSトークンを直接検証）
resource "google_iam_workload_identity_pool_provider" "aws_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "aws-sts-provider"
  display_name                       = "AWS STS Provider"

  aws {
    account_id = var.aws_account_id
  }

  # AWSのクレームをGCPの属性にマッピング
  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.aws_role"    = "assertion.arn.extract('/assumed-role/{role}/')"
  }

  # 指定したAWSアカウントIDからのアクセスのみに厳格制限（セキュリティ境界）
  attribute_condition = "attribute.aws_account == '${var.aws_account_id}'"
}
