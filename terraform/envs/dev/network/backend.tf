terraform {
  backend "s3" {
    bucket       = "enterprise-ai-tfstate"
    key          = "dev/network/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
