# Multi-Cloud Secure AI Blueprint (AWS × Google Cloud)

実務の知見をベースに、ゼロトラストとIaCによる「守りと攻めを両立するインフラ設計」のベストプラクティスを実装しています。

## 🏗️ 設計の要点

1. **キーレス・ゼロトラスト認証**: WIFを実装し、サービスアカウントキーを一切発行しないクラウド間連携を実現。GitHub ActionsからのデプロイもOIDCによる一時トークン認証で完結させます。
2. **コードによる統治（Governance as Code）**: AWS OrganizationsによるSCPの強制適用と、AWS Configによるドリフト（設定乖離）監視の枠組みをインフラコード化。
3. **セキュアなAIプラットフォーム**: Vertex AI Agent Builder × BigQueryを活用したText-to-SQL環境の構築。安全フィルターを内包し、最小権限（ReadOnly）と監査ログによるガードレールをコードで定義します。

## 📂 プロジェクト構成

本リポジトリは、以下の役割に基づいて各インフラコンポーネントをモジュール化しています。

- **providers.tf** : マルチクラウド（AWS / Google Cloud）プロバイダの一元管理設定
- **backend.tf** : S3による状態管理と、最新仕様（use_lockfile）を用いたステートロックの定義
- **gcp_wif.tf** : WIFを用いたGitHub Actionsからのキーレス・ゼロトラスト認証設定
- **aws_governance.tf** : AWS Organizations SCPやAWS Configによる統治ガードレールの設定
- **gcp_ai_agent.tf** : Vertex AI × BigQuery連携における、最小権限と監査ログのIAM設定
- **.github/workflows/terraform.yml** : OIDC認証を活用したGitOps自動化パイプライン
- **.gitignore** : プラグインや機密情報の混入を防ぐガードレール設定

## ⚙️ セットアップ手順（Bootstrap）

リモートバックエンドを使用するため、初回構築時は以下の手順が必要です。

1. **バケット作成**: `backend.tf` を一時的にコメントアウトし、`terraform init` と `apply` を実行してステート用S3バケットを作成します。
2. **ステート移行**: 作成後、`backend.tf` のコメントを解除し、再度 `terraform init` を実行することで、ローカルのステートをS3へ安全に移行（Migration）させます。
