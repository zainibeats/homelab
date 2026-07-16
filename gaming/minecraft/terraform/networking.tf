resource "oci_core_vcn" "minecraft_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_subnet" "minecraft_public_subnet" {
  cidr_block     = var.public_subnet_cidr
  compartment_id = var.compartment_id
  display_name   = var.public_subnet_name
  dns_label      = var.subnet_dns_label
  route_table_id = oci_core_vcn.minecraft_vcn.default_route_table_id
  vcn_id         = oci_core_vcn.minecraft_vcn.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_internet_gateway" "minecraft_internet_gateway" {
  compartment_id = var.compartment_id
  display_name   = var.internet_gateway_name
  enabled        = true
  vcn_id         = oci_core_vcn.minecraft_vcn.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_default_route_table" "minecraft_default_route_table" {
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.minecraft_internet_gateway.id
  }
  manage_default_resource_id = oci_core_vcn.minecraft_vcn.default_route_table_id

  lifecycle {
    prevent_destroy = true
  }
}
