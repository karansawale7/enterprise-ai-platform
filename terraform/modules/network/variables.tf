variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, stage, or prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "Main VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones used for high availability."
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_app_subnets" {
  description = "Private application subnet CIDRs."
  type        = list(string)
}

variable "private_data_subnets" {
  description = "Private data subnet CIDRs."
  type        = list(string)
}

variable "intra_subnets" {
  description = "Internal-only subnet CIDRs."
  type        = list(string)
}

variable "enable_single_nat_gateway" {
  description = "Use one NAT gateway instead of one per AZ. Cheaper but less available."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints."
  type        = bool
  default     = false
}
