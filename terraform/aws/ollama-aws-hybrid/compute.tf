# EC2 instance hosting Open WebUI
resource "aws_instance" "open_webui" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu_server.id
  key_name               = aws_key_pair.open_webui.key_name
  vpc_security_group_ids = [aws_security_group.open_webui.id]
  subnet_id              = aws_subnet.public.id
  user_data              = file("cloud-init.yaml")

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Environment = var.environment
    Name        = "open-webui-${var.environment}-ec2-instance"
  }
}
