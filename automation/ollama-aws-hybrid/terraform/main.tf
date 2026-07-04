# VPC
resource "aws_vpc" "open_webui_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-vpc"
  }
}

# EC2 Instance
resource "aws_instance" "open_webui_ec2_instance" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.open_webui_kp.key_name
  vpc_security_group_ids = [aws_security_group.open_webui_sg.id]
  subnet_id              = aws_subnet.open_webui_public_sn.id

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-ec2-instance"
  }
}
