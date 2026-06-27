# Multi-Cloud Secure AI Blueprint (AWS × Google Cloud)

実務の知見をベースに、ゼロトラストとIaCによる「守りと攻めを両立するインフラ設計」のベストプラクティス（Blueprint）を構想・設計しています。近々、各クラウドに対応したインフラコード（Terraform）として公開予定です。

## 🏗️ 設計の要点

### 1. キーレス・ゼロトラスト認証
WIF (Workload Identity Federation) を実装し、サービスアカウントキーを一切発行しないクラウド間連携を実現。GitHub ActionsからのデプロイもOIDCによる一時トークン認証で完結させます。

### 2. コードによる統治（Governance as Code）
AWS OrganizationsによるSCPの強制適用と、AWS Config + SSMによるドリフト（設定乖離）の自動修復をインフラコード化。手動変更を許さないGitOps運用を前提としています。

### 3. セキュアなAIプラットフォーム
Vertex AI Agent Builder × BigQueryを活用したText-to-SQL環境の構築。安全フィルターを内包し、AIによるデータ汚染を防ぐガードレールをコードレベルで定義します。

## 📂 プロジェクト構成
本リポジトリは、以下の役割に基づいて各インフラコンポーネントをモジュール化・配置しています。

- `providers.tf` : マルチクラウド（AWS / Google Cloud）プロバイダの一元管理設定
- `backend.tf` : Amazon S3による状態管理と、最新仕様（`use_lockfile`）を用いたステートロック（排他制御）の定義
- `gcp_wif.tf` : WIF（Workload Identity Federation）を用いたキーレス・ゼロトラスト認証の設定
- `aws_governance.tf` : AWS Organizations SCPやAWS Configによる統治ガードレールの設定
- `gcp_ai_agent.tf` : Vertex AI Agent Builder × BigQuery連携における、最小権限（ReadOnly）と監査ログの設定
- `.github/workflows/terraform.yml` : OIDC認証を活用した、安全なGitOps自動化パイプラインの設定
- `.gitignore` : プラグインバイナリや機密情報（tfstate等）の混入を防ぐ、構成管理のガードレール設定
