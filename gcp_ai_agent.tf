# 1. AIエージェント実行専用のサービスアカウント（静的キーは発行しない）
resource "google_service_account" "ai_agent" {
  account_id   = "vertex-ai-agent-sa"
  display_name = "Vertex AI Autonomous Agent Service Account"
  description  = "Dedicated SA for cross-cloud AI execution without static keys"
}

# 2. WIFプール経由のAWS IAMロールに対してのみ「サービスアカウント借用（Impersonation）」を許可
resource "google_service_account_iam_member" "wif_impersonation" {
  service_account_id = google_service_account.ai_agent.name
  role               = "roles/iam.workloadIdentityUser"

  # AWSの特定IAMロールからのフェデレーションアクセスに限定
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.aws_pool.name}/attribute.aws_role/enterprise-ai-orchestrator-role"
}

# 3. 必要最小限のVertex AI実行権限のみを付与（Project Editor等の過剰権限を排除）
resource "google_project_iam_member" "vertex_ai_user" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.ai_agent.email}"
}
