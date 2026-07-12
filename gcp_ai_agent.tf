resource "google_bigquery_dataset" "ai_knowledge_base" {
  dataset_id                 = "corporate_knowledge_db"
  friendly_name              = "Corporate Knowledge Base"
  location                   = "asia-northeast1"
  delete_contents_on_destroy = false
}

resource "google_service_account" "ai_agent_sa" {
  account_id   = "vertex-ai-agent-sa"
  display_name = "Vertex AI Agent Builder Service Account"
}

resource "google_project_iam_member" "ai_agent_vertex_user" {
  project = "multi-cloud-secure-ai-project"
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.ai_agent_sa.email}"
}

resource "google_storage_bucket" "audit_logs" {
  name     = "multi-cloud-secure-ai-blueprint-audit-logs"
  location = "asia-northeast1"
}

resource "google_logging_project_sink" "ai_audit_sink" {
  name                   = "vertex-ai-audit-logs-sink"
  destination            = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"
  filter                 = "resource.type=\"aiplatform.googleapis.com/Endpoint\" OR resource.type=\"bigquery_dataset\""
  unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "sink_writer" {
  bucket = google_storage_bucket.audit_logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.ai_audit_sink.writer_identity
}
