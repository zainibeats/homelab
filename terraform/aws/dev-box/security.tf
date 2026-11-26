# Dev box security group
resource "aws_security_group" "dev_box" {
  name        = "dev-box-${var.environment}-sg"
  description = "Allow SSH from trusted IPv4 addresses"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from trusted IPv4 addresses"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.trusted_ipv4_cidrs
  }

  # Add further ingress blocks here as services come online, e.g.:
  # ingress {
  #   description = "HTTPS from trusted IPv4 addresses"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = var.trusted_ipv4_cidrs
  # }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Name        = "dev-box-${var.environment}-sg"
  }
}
