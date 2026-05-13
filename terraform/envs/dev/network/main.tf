provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "network" {
  source = "../../../modules/network"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_cidr = "10.10.0.0/16"

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]

  public_subnets = [
    "10.10.1.0/24",
    "10.10.2.0/24",
    "10.10.3.0/24"
  ]

  private_app_subnets = [
    "10.10.11.0/24",
    "10.10.12.0/24",
    "10.10.13.0/24"
  ]

  private_data_subnets = [
    "10.10.21.0/24",
    "10.10.22.0/24",
    "10.10.23.0/24"
  ]

  intra_subnets = [
    "10.10.31.0/24",
    "10.10.32.0/24",
    "10.10.33.0/24"
  ]

  enable_single_nat_gateway = true
  enable_flow_logs          = true
  enable_vpc_endpoints      = true

  tags = {
    CostCenter = "AI-Platform"
    DataClass  = "Internal"
  }
}
