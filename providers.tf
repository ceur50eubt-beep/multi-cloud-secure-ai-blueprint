# ==========================================================================
# Multi-Cloud Terraform Providers Configuration
# ==========================================================================

terraform {
  # 1. 使用するプロバイダー（プラグイン）の宣言
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # バージョン5.x系を使用（実務での予期せぬアップデート防止）
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# 2. AWS プロバイダーの個別設定
provider "aws" {
  region = "ap-northeast-1" # 東京リージョンをデフォルトに設定
}

# 3. Google Cloud プロバイダーの個別設定
provider "google" {
  project = "multi-cloud-secure-ai-project" # 操作対象のGCPプロジェクトID
  region  = "asia-northeast1"             # 東京リージョンをデフォルトに設定
}
