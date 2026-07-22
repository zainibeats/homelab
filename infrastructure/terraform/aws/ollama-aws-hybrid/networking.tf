# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone_id    = var.availability_zone_id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-public-sn"
  }
}

# Internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-igw"
  }
}

# Elastic IP
resource "aws_eip" "open_webui" {
  instance = aws_instance.open_webui.id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-eip"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-rt"
  }
}

# Default route through the internet gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public route table association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
