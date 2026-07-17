terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

variable "tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy used for provider authentication."
}

variable "user_ocid" {
  type        = string
  description = "OCID of the OCI user used for provider authentication."
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint of the OCI API signing key."
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key file for the OCI API signing key."
}

variable "region" {
  type        = string
  description = "OCI region where resources will be managed."
  default     = "us-sanjose-1"
}
