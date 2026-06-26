# Multi-Cloud Secure AI Blueprint (AWS × Google Cloud)

実務の知見をベースに、ゼロトラストとIaCによる「守りと攻めを両立するインフラ設計」のベストプラクティス（Blueprint）を構想・設計しています。近々、各クラウドに対応したインフラコード（Terraform）として公開予定です。

## 🏗️ 設計の要点

### 1. キーレス・ゼロトラスト認証
WIF (Workload Identity Federation) を実装し、サービスアカウントキーを一切発行しないクラウド間連携を実現。GitHub ActionsからのデプロイもOIDCによる一時トークン認証で完結させます。

### 2. コードによる統治（Governance as Code）
AWS OrganizationsによるSCPの強制適用と、AWS Config + SSMによるドリフト（設定乖離）の自動修復をインフラコード化。手動変更を許さないGitOps運用を前提としています。

### 3. セキュアなAIプラットフォーム
Vertex AI Agent Builder × BigQueryを活用したText-to-SQL環境の構築。安全フィルターを内包し、AIによるデータ汚染を防ぐガードレールをコードレベルで定義します。

## 📂 予定しているリポジトリ構成
- `providers.tf` : マルチプロバイダの一元管理設定
- `gcp_wif.tf` : キーレス認証（Workload Identity）の設定
- `aws_governance.tf` : SCPやAWS Config、ガードレールの設定
- `gcp_ai_agent.tf` : Vertex AI / BigQuery連携の設定
- `.github/workflows/terraform.yml` : GitHub ActionsのCI/CD設定（OIDC対応）
