resource "proxmox_download_file" "cloud_image" {
  content_type = "import"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name
  url          = var.cloud_image_url
  file_name    = var.cloud_image_file_name
  overwrite    = false
}

resource "proxmox_virtual_environment_vm" "main" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id

  # q35 + OVMF is required for PCIe GPU passthrough.
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = var.qemu_agent_enabled
  }

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  # Passthrough pins all guest memory, so ballooning is disabled.
  memory {
    dedicated = var.memory_mb
    floating  = 0
  }

  # Secure Boot keys off so the unsigned NVIDIA kernel module loads.
  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = false
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    import_from  = proxmox_download_file.cloud_image.id
    size         = var.disk_size_gb
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  # Models disk. Skipped by vzdump since models can be re-downloaded.
  disk {
    datastore_id = var.models_datastore_id
    interface    = "scsi1"
    size         = var.models_disk_size_gb
    iothread     = true
    discard      = "on"
    ssd          = true
    backup       = var.models_disk_backup
  }

  hostpci {
    device  = "hostpci0"
    mapping = var.gpu_mapping
    pcie    = true
    xvga    = false
  }

  network_device {
    bridge = var.network_bridge
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = var.ipv4_cidr
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
