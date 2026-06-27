# ==========================================================================
# Terraform Remote State Backend Configuration
# ==========================================================================
# 複数人開発やCI/CD環境からの実行を想定し、Amazon S3による状態管理と
# DynamoDBによるステートロック（排他制御）を実装。

terraform {
  backend "s3" {
    bucket       = "multi-cloud-secure-ai-blueprint-tfstate"
    key          = "prod/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true # 最新仕様のネイティブステートロックを有効化
  }
}
