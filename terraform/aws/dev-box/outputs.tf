output "instance_id" {
  value       = aws_instance.dev_box_ec2.id
  description = "Instance ID for the dev-box EC2 instance"
}

output "public_ip" {
  value       = aws_eip.dev_box.public_ip
  description = "The public IP address of the dev-box EC2 instance"
}

output "ssh_command" {
  value       = "ssh -i ${var.private_key_path} ${var.ssh_username}@${aws_eip.dev_box.public_ip}"
  description = "The SSH command to connect to the dev-box EC2 instance"
}
