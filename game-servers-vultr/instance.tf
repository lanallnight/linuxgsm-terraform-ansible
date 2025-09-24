locals {
  required_tags = {
    project     = var.game_server_type,
    environment = var.region,
    workspace   = terraform.workspace
  }

  tags         = merge({ "name" = "My Custom Var" }, local.required_tags)
  tags_as_list = [for k, v in local.tags : "${k}=${v}"]
}

resource "vultr_firewall_group" "this" {
  description = "base firewall"
}

# External data source to fetch public IP
data "external" "get_public_ip" {
  program = ["bash", "-c", "curl -s ifconfig.me | jq -n --arg ip $(cat) '{output: $ip}'"]
}

# Combine the dynamically fetched IP with the predefined allowed IPs
variable "allowed_ips" {
  type    = list(string)
  default = []
}

# Create a list that includes both the allowed IPs and the dynamically fetched public IP
locals {
  all_allowed_ips = concat(var.allowed_ips, [data.external.get_public_ip.result["output"]])
}

resource "vultr_firewall_rule" "ssh_security_group" {
  for_each          = toset(local.all_allowed_ips)
  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = each.value
  subnet_size       = 32
  port              = "22"
  notes             = "SSH access for IP ${each.value}"
}

resource "vultr_firewall_rule" "game_security_group_tcp" {
  count = length(local.game_server_ports[var.game_server_type])

  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0

  port  = local.game_server_ports[var.game_server_type][count.index]
  notes = "Open ${local.game_server_ports[var.game_server_type][count.index]} port to the world for ${var.game_server_type}"
}

resource "vultr_firewall_rule" "game_security_group_udp" {
  count = length(local.game_server_ports[var.game_server_type])

  firewall_group_id = vultr_firewall_group.this.id
  protocol          = "udp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0

  port  = local.game_server_ports[var.game_server_type][count.index]
  notes = "Open ${local.game_server_ports[var.game_server_type][count.index]} port to the world for ${var.game_server_type}"
}

resource "vultr_ssh_key" "this" {
  name    = "ec2-key-${var.game_server_type}"
  ssh_key = tls_private_key.this.public_key_openssh
}

resource "vultr_instance" "server_instance" {
  label  = "instance-${var.game_server_type}"
  plan   = var.instance_size
  region = var.region
  # Conditionally select snapshot_id or os_id
  os_id             = var.snapshot_id != "" ? null : var.os_id
  snapshot_id       = var.snapshot_id != "" ? var.snapshot_id : null
  enable_ipv6       = true
  firewall_group_id = vultr_firewall_group.this.id
  ssh_key_ids       = [vultr_ssh_key.this.id]
  tags              = local.tags_as_list
  #script_id         = var.snapshot_id != "" ? null : vultr_startup_script.this.id
}

resource "null_resource" "app-instance-ready" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
    echo "Checking SSH port open on ${vultr_instance.server_instance.main_ip}"
    while ! timeout 2 bash -c '</dev/tcp/${vultr_instance.server_instance.main_ip}/22' 2>/dev/null; do
      echo "${vultr_instance.server_instance.main_ip}/22: connection timeout"
      sleep 5
    done
    echo "${vultr_instance.server_instance.main_ip}/22: port open"
    
    sleep 60 # Wait for the cloud-init
    
    echo "Checking SSH login on ${vultr_instance.server_instance.main_ip}"
    ssh -i "${local.home_dir}/.ssh/${var.game_server_type}_id_ed25519.pem" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${var.ssh_user}@${vultr_instance.server_instance.main_ip} 'echo -e "$(id)\n$(whoami)@$(hostname) is ready!"'
    EOT
  }

  depends_on = [
    local_file.ansible_inventory,
    vultr_instance.server_instance,
  ]
}

resource "null_resource" "setup-sudo" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.ssh_user} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${var.ssh_user}",
      "sudo chmod 440 /etc/sudoers.d/${var.ssh_user}",
      "echo '${var.game_server_type} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${var.game_server_type}",
      "sudo chmod 440 /etc/sudoers.d/${var.game_server_type}"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file("${local.home_dir}/.ssh/${var.game_server_type}_id_ed25519.pem")
      host        = vultr_instance.server_instance.main_ip
      #bastion_host = "${var.bastion_host}" # Optional if you're using a bastion
    }
  }

  depends_on = [
    vultr_instance.server_instance,
    null_resource.app-instance-ready
  ]
}

variable "ssh_user" {
  type    = string
  default = "root"
}

# Related API Request for regions/sizes https://www.vultr.com/api/#tag/os/operation/list-os

variable "instance_size" {}
variable "region" {
  default = "dfw"
}
variable "os_id" {
  default = "1743"
}
variable "snapshot_id" {}
