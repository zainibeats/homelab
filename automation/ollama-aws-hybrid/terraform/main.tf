# VPC
resource "aws_vpc" "ollama-gluetun" {
  cidr_block = "10.100.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    name = "pre-prod-1"
  }
}

# EC2 Instance
resource "aws_instance" "name" {
  instance_type = "t3.micro"
  ami =
  key_name = aws_key_pair.ollama-gluetun-KP.id
  vpc_security_group_ids = [aws_security_group.ollama-gluetun-SG.id]
  subnet_id = aws_subnet.ollama-gluetun-SN.id

  tags = {
    name = "pre-prod-1"
  }
}
