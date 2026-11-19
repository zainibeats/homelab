resource "proxmox_virtual_environment_vm" "node" {
  for_each = var.nodes

  name      = each.key
  node_name = var.node_name
  vm_id     = each.value.vm_id
  tags      = ["k3s-lab", each.value.role]

  on_boot         = var.start_on_boot
  stop_on_destroy = !var.qemu_agent_enabled

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = var.qemu_agent_enabled
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_datastore_id
    interface    = var.disk_interface
    size         = each.value.disk_gb
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge  = var.network_bridge
    vlan_id = var.vlan_id
  }

  # Debian cloud images log their console to the serial port.
  serial_device {}

  operating_system {
    type = "l26"
  }

  # Native Proxmox cloud-init only (no custom snippet), so the provider
  # needs just the API token, not SSH access to the Proxmox host.
  initialization {
    datastore_id = var.vm_datastore_id

    ip_config {
      ipv4 {
        address = each.value.ipv4_cidr
        gateway = var.ipv4_gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = var.admin_username
      keys     = [trimspace(file(pathexpand(var.public_key_path)))]
    }
  }
}
