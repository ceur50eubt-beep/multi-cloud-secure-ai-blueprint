terraform {
  backend "s3" {
    bucket       = "multi-cloud-secure-ai-blueprint-tfstate"
    key          = "prod/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
