# Multi-Cloud Secure AI Blueprint
> **Keyless Cross-Cloud Workload Identity Federation (AWS & GCP) for Autonomous AI Agents**

[![Terraform Security & Validate](https://github.com/ceur50eubt-beep/multi-cloud-secure-ai-blueprint/actions/workflows/terraform_ci.yml/badge.svg)]([https://github.com/ceur50eubt-beep/multi-cloud-secure-ai-blueprint/actions/workflows/terraform_ci.yml](https://github.com/ceur50eubt-beep/multi-cloud-secure-ai-blueprint/actions/workflows/terraform_ci.yml))
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An enterprise-grade Multi-Cloud Infrastructure as Code (IaC) blueprint that enables secure, keyless cross-cloud communication between **Amazon Web Services (AWS)** and **Google Cloud Platform (GCP)**. Utilizing **Workload Identity Federation (WIF)**, AWS-hosted AI orchestration services invoke GCP Vertex AI and Cloud Run agents without generating, storing, or rotating long-lived service account keys.

---

## 1. Architectural Challenge & Solution

| Challenge in Traditional Multi-Cloud | Workload Identity Federation (This Blueprint) |
|---|---|
| **Static Credential Sprawl**: Exporting GCP Service Account JSON keys to AWS introduces high leak risks. | **Zero Static Secrets**: Short-lived, cryptographic OIDC tokens eliminate stored credentials entirely. |
| **Operational Secret Toil**: Manual key rotation schedules (e.g., 90 days) risk service downtime. | **Fully Automated Expiration**: Federated STS tokens automatically expire (TTL: 15–60 mins). |
| **Fragmented Audit Trails**: Disconnected access logs prevent unified incident investigation. | **Unified Identity Federation**: Native Cloud Audit Logs capture the exact AWS IAM Principal ARN. |

---

## 2. Cross-Cloud Identity Flow

```text
[ AWS Workload ] (ECS / EKS / Lambda AI Orchestrator)
       │
       ▼ 1. Authenticate & Obtain AWS Signed Identity Token
[ AWS STS ] (GetCallerIdentity / OIDC Token)
       │
       │ 2. Exchange AWS Token via STS API
       ▼
[ GCP Workload Identity Pool / Provider ] (gcp_wif.tf)
       │
       │ 3. Validate AWS Signature & Map Subject/Claims
       ▼
[ GCP Service Account Impersonation ] (gcp_ai_agent.tf)
       │
       │ 4. Issue Short-Lived GCP OAuth2 Access Token
       ▼
[ Target AI Workload ] (Vertex AI / Model Endpoints / Gemini API)
```

---

## 3. Key Design Highlights

* **Keyless Cross-Cloud Bridge (WIF)**: Eliminates long-lived JSON credentials. AWS workloads exchange cryptographically signed STS tokens directly for ephemeral GCP OAuth2 tokens.
* **Strict IAM Boundary & Claim Mapping**: Restricts impersonation strictly to specific AWS IAM Roles and AWS Account IDs via custom attribute conditions (`attribute.aws_account`).
* **Multi-Cloud Governance**: AWS governance policies and GCP IAM policies are decoupled into dedicated declarative Terraform configurations to prevent cross-cloud blast radius expansion.
* **Least-Privilege Scoping**: GCP Service Accounts are mapped strictly to fine-grained AI roles (`roles/aiplatform.user`) rather than broad Project Editor permissions.

---

## 4. Directory Structure

```text
multi-cloud-secure-ai-blueprint/
├── README.md
├── providers.tf                       # AWS and Google Cloud provider configurations
├── backend.tf                         # State backend declaration
├── aws_governance.tf                  # AWS IAM roles, OIDC token policies, and guardrails
├── gcp_wif.tf                         # GCP Workload Identity Pool & AWS OIDC Provider
├── gcp_ai_agent.tf                    # GCP Service Account, IAM bindings, and AI permissions
└── .github/
    └── workflows/
        └── terraform_ci.yml           # Automated CI validation pipeline
```

---

## 5. Verification & Deployment

### Prerequisites
* Terraform >= 1.5.0
* AWS CLI and Google Cloud SDK (`gcloud`) configured with administrative permissions

```bash
# Initialize Terraform
terraform init

# Validate configuration format and syntax
terraform fmt -check
terraform validate

# Review multi-cloud resource graph
terraform plan
```

---

## 6. SRE & Compliance Takeaways

* **Elimination of Secret Rotation Toil**: Eradicates 100% of human overhead and operational outages associated with static credential expiry and key rotation.
* **Audit-Proof Compliance**: Adheres to Zero Standing Privileges (ZSP) and CIS Benchmark standards for multi-cloud security, satisfying external SOC 2 and ISO 27001 requirements.
