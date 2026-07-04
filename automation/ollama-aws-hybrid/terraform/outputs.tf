output "instance_id" {
  value       = aws_instance.open_webui_ec2_instance.id
  description = "Instance ID for the Open WebUI EC2 instance"
}

output "open_webui_ec2_instance_public_ip" {
  value       = aws_eip.open_webui_eip.public_ip
  description = "The public IP address of the Open WebUI EC2 instance"
}

output "ssh_command" {
  value       = "ssh -i ${var.private_key_path} ${var.username}@${aws_eip.open_webui_eip.public_ip}"
  description = "The SSH command to connect to the Open WebUI EC2 instance"
}
