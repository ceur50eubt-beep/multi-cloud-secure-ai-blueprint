# ==========================================================================
# Google Cloud Secure AI Platform (Vertex AI & BigQuery) Configuration
# ==========================================================================
# Vertex AI Agent Builderを活用したText-to-SQL環境をセキュアに構築。
# AIによるデータ汚染を防ぐガードレールと、最小権限の原則に基づくIAM制御を定義。

# 1. AIエージェントが参照する社内データベ―ス（BigQuery データセット）
resource "google_bigquery_dataset" "ai_knowledge_base" {
  dataset_id                  = "corporate_knowledge_db"
  friendly_name               = "Corporate Knowledge Base"
  description                 = "Secure data repository accessible by Vertex AI Agent"
  location                    = "asia-northeast1" # 東京リージョン
  delete_contents_on_destroy = false
}

# 2. AIエージェント専用の独立したサービスアカウント（最小権限の原則）
resource "google_service_account" "ai_agent_sa" {
  account_id   = "vertex-ai-agent-sa"
  display_name = "Vertex AI Agent Builder Execution Service Account"
}

# 3. ガードレール：AIエージェントには「BigQueryの読み取り専用権限」のみを付与（データ汚染防止）
resource "google_bigquery_dataset_iam_member" "ai_agent_bq_reader" {
  dataset_id = google_bigquery_dataset.ai_knowledge_base.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.ai_agent_sa.email}"
}

# 4. Vertex AIの実行権限をエージェントSAに付与
resource "google_project_iam_member" "ai_agent_vertex_user" {
  project = "multi-cloud-secure-ai-project" # デモ用のプロジェクトID
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.ai_agent_sa.email}"
}

# 5. セキュリティログ監査用のCloud Loggingバケットの枠組み（AIの挙動の追跡用）
resource "google_logging_project_sink" "ai_audit_sink" {
  name        = "vertex-ai-audit-logs-sink"
  description = "Audit log sink for tracking Vertex AI Agent interactions and Text-to-SQL queries"
  destination = "storage.googleapis.com/multi-cloud-secure-ai-blueprint-audit-logs" # 宛先バケット（モック）
  filter      = "resource.type=\"aiplatform.googleapis.com/Endpoint\" OR resource.type=\"bigquery_dataset\""

  unique_writer_identity = true
}
