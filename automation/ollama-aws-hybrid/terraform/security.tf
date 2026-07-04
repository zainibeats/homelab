# Security Group
resource "aws_security_group" "open_webui_sg" {
  name        = "open-webui-sg"
  description = "allow HTTPS from specified public IP only"
  vpc_id      = aws_vpc.open_webui_vpc.id

  ingress {
    description = "HTTPS from specified public IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_public_ip_cidr
  }

  ingress {
    description = "SSH from specified public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_public_ip_cidr
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-sg"
  }
}

# Keypair
resource "aws_key_pair" "open_webui_kp" {
  key_name   = var.key_name
  public_key = local.public_key_content
}

locals {
  public_key_content = file(pathexpand(var.public_key_path))
}
