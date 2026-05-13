locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Platform-Team"
    },
    var.tags
  )
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-igw"
  })
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "${local.name}-public-${var.availability_zones[count.index]}"
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_app_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name                              = "${local.name}-private-app-${var.availability_zones[count.index]}"
    Tier                              = "private-app"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "private_data" {
  count = length(var.private_data_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_data_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name}-private-data-${var.availability_zones[count.index]}"
    Tier = "private-data"
  })
}

resource "aws_subnet" "intra" {
  count = length(var.intra_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.intra_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name}-intra-${var.availability_zones[count.index]}"
    Tier = "intra"
  })
}

resource "aws_eip" "nat" {
  count = var.enable_single_nat_gateway ? 1 : length(var.public_subnets)

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "this" {
  count = var.enable_single_nat_gateway ? 1 : length(var.public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(local.common_tags, {
    Name = "${local.name}-nat-${count.index + 1}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  count = length(var.private_app_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-private-app-rt-${count.index + 1}"
  })
}

resource "aws_route" "private_app_nat" {
  count = length(var.private_app_subnets)

  route_table_id         = aws_route_table.private_app[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.enable_single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

resource "aws_route_table" "private_data" {
  count = length(var.private_data_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-private-data-rt-${count.index + 1}"
  })
}

resource "aws_route" "private_data_nat" {
  count = length(var.private_data_subnets)

  route_table_id         = aws_route_table.private_data[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.enable_single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private_data" {
  count = length(aws_subnet.private_data)

  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data[count.index].id
}

resource "aws_route_table" "intra" {
  count = length(var.intra_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-intra-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "intra" {
  count = length(aws_subnet.intra)

  subnet_id      = aws_subnet.intra[count.index].id
  route_table_id = aws_route_table.intra[count.index].id
}
