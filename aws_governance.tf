# ==========================================================================
# AWS Governance & Remote State Backend Resources
# ==========================================================================
# 実務運用を見据えた「守り」の基盤設定。
# AWS Organizationsによる統治と、安全なTerraform状態管理を実現します。

# 1. 状態管理用S3バケット（backend.tfで使用）
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "multi-cloud-secure-ai-blueprint-tfstate"
  force_destroy = false
}

# 2. 統治：AWS Organizations SCP（ガバナンスガードレール）
# 例：信頼できないリージョンへのアクセス制限などをここに記述
resource "aws_organizations_policy" "governance_scp" {
  name        = "StrictGovernancePolicy"
  description = "SCP to enforce security guardrails across AWS accounts"
  content     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "s3:DeleteBucket",
      "Resource": "*"
    }
  ]
}
POLICY
}

# 3. コンプライアンス：AWS Configルール（ドリフト監視の枠組み）
resource "aws_config_config_rule" "drift_detection" {
  name = "terraform-drift-detection"
  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
}
