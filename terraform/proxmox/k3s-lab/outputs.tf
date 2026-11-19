locals {
  node_ips = { for name, n in var.nodes : name => split("/", n.ipv4_cidr)[0] }
}

output "node_ips" {
  value       = local.node_ips
  description = "Static IPv4 address of each lab node."
}

output "ansible_inventory" {
  description = "Inventory for ansible/k3s. Write it with: tofu output -raw ansible_inventory > ../../../ansible/k3s/inventory/lab/hosts.yml"
  value = yamlencode({
    k3s_cluster = {
      children = {
        server = {
          hosts = { for name, n in var.nodes : name => { ansible_host = local.node_ips[name] } if n.role == "server" }
        }
        agent = {
          hosts = { for name, n in var.nodes : name => { ansible_host = local.node_ips[name] } if n.role == "agent" }
        }
      }
    }
  })
}
