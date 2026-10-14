locals {
  service_dns_label     = replace(var.service_name, "-", "")
  instance_name         = coalesce(var.instance_name, "${var.service_name}-01")
  vnic_name             = coalesce(var.vnic_name, "${var.service_name}-vnic")
  vcn_display_name      = coalesce(var.vcn_display_name, "${var.service_name}-vcn")
  vcn_dns_label         = coalesce(var.vcn_dns_label, "${local.service_dns_label}vcn")
  subnet_dns_label      = coalesce(var.subnet_dns_label, "${local.service_dns_label}subnet")
  public_subnet_name    = coalesce(var.public_subnet_name, "${var.service_name}-public-subnet")
  internet_gateway_name = coalesce(var.internet_gateway_name, "Internet Gateway ${var.service_name}-vcn")
}
