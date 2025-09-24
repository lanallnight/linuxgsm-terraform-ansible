resource "onepassword_item" "this" {
  vault = var.lan_vault

  title    = "${ var.game_server_type } Instance Password"
  category = "password"

  password_recipe {
    length  = 27
    symbols = true
  }

  section {
    label = "Credential metadata"
  }

  lifecycle {
    # Ignore conflicts during destroy operations
    ignore_changes = [vault]
  }
}

resource "onepassword_item" "server_config" {
  vault = var.lan_vault

  title    = "${ var.game_server_type } SSH Config & Key"
  category = "password"

  password = "${ tls_private_key.this.private_key_openssh }"

  section {
    label = "Credential metadata"

    field {
      label = "NOTE"
      type  = "STRING"
      value = <<-EOT
        Host "app_server_instance_${var.game_server_type}"
            HostName ${vultr_instance.server_instance.main_ip}
            User root
            IdentityFile ~/.ssh/${var.game_server_type}_id_ed25519.pem
            IdentitiesOnly yes
            PasswordAuthentication no
      EOT
    }
  }

  lifecycle {
    # Ignore conflicts during destroy operations
    ignore_changes = [vault]
  }

  depends_on = [onepassword_item.this]
}

data "onepassword_item" "steam_login" {
  vault = var.lan_vault
  uuid  = var.steam_login
}

data "onepassword_item" "server_login" {
  vault = var.lan_vault
  uuid  = var.server_login
}

data "onepassword_item" "cs2server_id_hash" {
  vault = var.lan_vault
  uuid  = var.cs2server_id_hash
}

data "onepassword_item" "csgo_id_hash" {
  vault = var.lan_vault
  uuid  = var.csgo_id_hash
}

data "onepassword_item" "tf2_id_hash" {
  vault = var.lan_vault
  uuid  = var.tf2_id_hash
}

data "onepassword_item" "discord_webhook" {
  vault = var.lan_vault
  uuid  = var.discord_webhook
}

/* output "test123" {
  value = data.onepassword_item.example
  sensitive = true
}

output "example_username" {
  value = data.onepassword_item.steam_login.username
  sensitive = true
}

output "example_password" {
  value = data.onepassword_item.steam_login.password
  sensitive = true
} */

variable "lan_vault" {
  default = "pysa6uhnfonaxmix5o23rqedxi"
}
variable "steam_login" {
  default = "aid2674ucgezvu3r3okztdgzrq"
}
variable "server_login" {
  default = "hfxuyxhvvcrblku3pidt7a2upq"
}
variable "cs2server_id_hash" {
  default = "wczkgki6v67bse7h7yc2lj2sru"
}
variable "csgo_id_hash" {
  default = "pdw27eba4t3w2mu7stxna2ner4"
}
variable "tf2_id_hash" {
  default = "thvrhsvcbwpyo6t7qldwqra2ay"
}
variable "discord_webhook" {
  default = "25z4vdjlrcd6voq6c4a6oasjsy"
}
