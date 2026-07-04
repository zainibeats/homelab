# Public Subnet
resource "aws_subnet" "open_webui_public_sn" {
  vpc_id                  = aws_vpc.open_webui_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-public-sn"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "open_webui_igw" {
  vpc_id = aws_vpc.open_webui_vpc.id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-igw"
  }
}

# Elastic IP
resource "aws_eip" "open_webui_eip" {
  instance = aws_instance.open_webui_ec2_instance.id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-eip"
  }
}

# Route Table
resource "aws_route_table" "open_webui_rt" {
  vpc_id = aws_vpc.open_webui_vpc.id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-rt"
  }
}

# Default Route: IGW next hop to public internet
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.open_webui_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.open_webui_igw.id
}

# Route Table Association
resource "aws_route_table_association" "open_webui_rt_assoc" {
  subnet_id      = aws_subnet.open_webui_public_sn.id
  route_table_id = aws_route_table.open_webui_rt.id
}
