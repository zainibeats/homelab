resource "aws_key_pair" "dev_box" {
  key_name   = var.ssh_key_name
  public_key = local.ssh_public_key
}

locals {
  ssh_public_key = file(pathexpand(var.public_key_path))
}
