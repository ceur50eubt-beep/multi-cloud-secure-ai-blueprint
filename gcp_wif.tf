# ==========================================================================
# Google Cloud Workload Identity Federation (WIF) Configuration
# ==========================================================================
# サービスアカウントキーの不発行（キーレス認証）を実現するため、
# AWS（またはGitHub Actions）のOIDCアイデンティティプロバイダを信頼するプールとプロバイダを定義。

# 1. 外部アイデンティティを管理するWorkload Identity プール
resource "google_iam_workload_identity_pool" "main_pool" {
  workload_index_pool_id = "multi-cloud-secure-pool"
  display_name          = "Multi-Cloud Secure AI Blueprint Pool"
  description           = "AWS or GitHub Actions integration for zero-trust authentication"
  disabled              = false
}

# 2. AWSを認証先として接続するためのOIDCプロバイダ設定
resource "google_iam_workload_identity_pool_provider" "aws_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.main_pool.workload_index_pool_id
  workload_identity_pool_provider_id = "aws-identity-provider"
  display_name                       = "AWS OIDC Provider"
  
  # AWS向けの設定（GitHub Actionsにする場合はoidcブロックに切り替えます）
  aws {
    account_id = "123456789012" # デモ用のAWSアカウントID（必要に応じて変数化）
  }

  # 属性マッピング：AWSのIAMロールARNをGoogle側の属性にマッピング
  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.aws_role" = "assertion.arn"
  }
}

# 3. WIF経由でのみ借用（Impersonate）を許可するサービスアカウントの定義
resource "google_service_account" "wif_executor" {
  account_id   = "wif-executor-sa"
  display_name = "Workload Identity Federation Executor"
}

# 4. サービスアカウントに対するWIFトークン作成者の権限付与（IAMバインディング）
resource "google_service_account_iam_binding" "wif_impersonation" {
  service_account_id = google_service_account.wif_executor.name
  role               = "roles/iam.workloadIdentityUser"

  # 特定のプール・特定のAWSロールからのみ借用を許可する厳格な制約（ゼロトラスト）
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main_pool.name}/attribute.aws_role/arn:aws:iam::123456789012:role/multi-cloud-ai-runner"
  ]
}
