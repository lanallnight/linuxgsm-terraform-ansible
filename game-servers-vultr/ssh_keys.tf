resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "null_resource" "add_ssh_key_to_ssh_folder" {
  provisioner "local-exec" {
    command = <<-EOF
      echo "${tls_private_key.this.private_key_openssh}" > ${local.home_dir}/.ssh/${var.game_server_type}_id_ed25519.pem
      chmod 600 ${local.home_dir}/.ssh/${var.game_server_type}_id_ed25519.pem
    EOF
  }
  depends_on = [tls_private_key.this]
}

# Add a step to upload these to an S3 bucket

locals {
  home_dir = join("/", slice(split("/", path.cwd), 0, 3))
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/ssh-config.tmpl", {
    server_instance_label     = "server_instance_${var.game_server_type}",
    server_instance_public_ip = vultr_instance.server_instance.main_ip
    game_server_type          = var.game_server_type
  })
  filename = "${local.home_dir}/.ssh/config.d/${var.game_server_type}"

  depends_on = [null_resource.add_ssh_key_to_ssh_folder]
}
