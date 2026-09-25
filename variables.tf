variable "aws_region" {
  description = "Primary AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_account_id" {
  description = "Target AWS Account ID for cross-cloud trust"
  type        = string
  default     = "123456789012"
}

variable "gcp_project_id" {
  description = "Target Google Cloud Project ID"
  type        = string
  default     = "enterprise-ai-core"
}

variable "gcp_region" {
  description = "Primary GCP Region for AI workloads"
  type        = string
  default     = "asia-northeast1"
}
