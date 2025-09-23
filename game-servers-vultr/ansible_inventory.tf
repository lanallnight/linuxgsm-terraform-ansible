# Create the Ansible inventory file
resource "local_file" "ansible_inventory" {
  filename = "./playbooks/inventory.ini"
  content = templatefile("${path.module}/playbooks/inventory.tmpl", {
    server_instance_label     = "server_instance_${var.game_server_type}",
    server_instance_key       = "${local.home_dir}/.ssh/${var.game_server_type}_id_ed25519.pem"
    server_instance_public_ip = vultr_instance.server_instance.main_ip
  })
}

### --- variables.tf --- ###

### --- outputs.tf --- ###
