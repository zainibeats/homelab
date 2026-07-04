variable "region" {
  type        = string
  description = "Region for VPC"
  default     = "us-west-2"
}

variable "profile" {
  type        = string
  description = "AWS profile"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.100.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ingress_public_ip_cidr" {
  type        = list(string)
  description = "CIDR block(s) for ip address allowed for ingress in security group"

  validation {
    condition = alltrue([
      for cidr_block in var.ingress_public_ip_cidr :
      can(cidrnetmask(cidr_block)) &&
      endswith(cidr_block, "/32")
    ])
    error_message = "Address must be a list of strings in CIDR notation and must end in /32 (e.g. ['8.8.8.8/32'])"
  }
}

variable "key_name" {
  description = "Public key name"
  type        = string
  default     = "open-webui-key"
}

variable "public_key_path" {
  description = "Public key path"
  type        = string
  default     = "~/.ssh/open-webui-key.pub"
}

variable "private_key_path" {
  description = "Private key path"
  type        = string
  default     = "~/.ssh/open-webui-key"
}

variable "username" {
  description = "Username for the EC2 instance"
  type        = string
  default     = "ubuntu"
}
