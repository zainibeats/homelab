# Public Subnet
resource "aws_subnet" "ollama-gluetun-public-SN" {
  vpc_id = aws_vpc.ollama-gluetun.id
  cidr_block = "10.100.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"

  tags = {
    name = "pre-prod-1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ollama-gluetun-IGW" {
  vpc_id = aws_vpc.ollama-gluetun.id

  tags = {
    name = "pre-prod-1"
  }
}

# Route Table
resource "aws_route_table" "ollama-gluetun-RT" {
  vpc_id = aws_vpc.ollama-gluetun.id

  tags = {
    name = "pre-prod-1"
  }
}

# Default Route: IGW next hop to public internet
resource "aws_route" "default_route" {
  route_table_id = aws_route_table.ollama-gluetun-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ollama-gluetun-IGW.id
}

# Route Table Association
resource "aws_route_table_association" "ollama-gluetun-RT-assoc" {
  subnet_id = aws_subnet.ollama-gluetun-SN.id
  route_table_id = aws_route_table.ollama-gluetun-RT.id
}
