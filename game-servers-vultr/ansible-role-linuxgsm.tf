## ansible-gha-runner.tf ###
resource "null_resource" "linuxgsm_install" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    environment = {
      GAME_SERVER_TYPE             = var.game_server_type,
      STEAM_USERNAME               = data.onepassword_item.steam_login.username,
      STEAM_PASSWORD               = data.onepassword_item.steam_login.password,
      GAME_SERVER_PRIVATE_PASSWORD = data.onepassword_item.server_login.password,
      CS2SERVER_ID_HASH            = data.onepassword_item.cs2server_id_hash.password,
      CSGO_ID_HASH                 = data.onepassword_item.csgo_id_hash.password,
      TF2_ID_HASH                  = data.onepassword_item.tf2_id_hash.password,
      DISCORD_WEBHOOK              = data.onepassword_item.discord_webhook.password
    }

    command = <<EOF
      cd ${path.module}/playbooks && \
      ansible-galaxy install -p roles/ -r roles/requirements.yml -f ansible-role-linuxgsm && \
      ansible-playbook -vvv \
        linuxgsm-role.yml \
          -i inventory.ini \
          -e '{"install_essentials": true}' \
          -e '{"linuxgsm": true}' \
          -e '{"load_configs": true}' \
          -e '{"start_services": true}'
EOF
  }
  depends_on = [
    local_file.ansible_inventory,
    vultr_instance.server_instance,
    null_resource.app-instance-ready,
    null_resource.setup-sudo,
    null_resource.add_ssh_key_to_ssh_folder
  ]
}

variable "run_tags" {
  type    = string
  default = ""
}

#          --tags "${var.run_tags}" \
