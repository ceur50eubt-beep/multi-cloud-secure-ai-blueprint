resource "google_iam_workload_identity_pool" "main_pool" {
  workload_identity_pool_id = "multi-cloud-secure-pool"
  display_name              = "Multi-Cloud Secure AI Blueprint Pool"
  description               = "GitHub Actions integration for zero-trust authentication"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.main_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
}

resource "google_service_account" "wif_executor" {
  account_id   = "wif-executor-sa"
  display_name = "Workload Identity Federation Executor"
}

resource "google_service_account_iam_binding" "wif_impersonation" {
  service_account_id = google_service_account.wif_executor.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main_pool.name}/attribute.repository_owner/ceur50eubt-beep"
  ]
}
