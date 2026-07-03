# Security Group
resource "aws_security_group" "ollama-gluetun-SG" {
  vpc_id = aws_vpc.ollama-gluetun.id

  ingress = {

  }

  egress = {

  }

  tags = {
    name = "pre-prod-1"
  }
}

# Keypair
resource "aws_key_pair" "ollama-gluetun-KP" {
  key_name = "ollama-key"
  public_key = file("~/.ssh/ollama-key.pub")
}
