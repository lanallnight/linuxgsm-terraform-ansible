/* resource "vultr_startup_script" "this" {
  name   = "deploy_linux_gsm"
  script = base64encode(templatefile("${path.module}/game_script.sh.tpl", {
    game_server_type             = var.game_server_type,
    steam_username               = data.onepassword_item.steam_login.username,
    steam_password               = data.onepassword_item.steam_login.password,
    game_server_private_password = data.onepassword_item.server_login.password,
    cs2server_id_hash            = data.onepassword_item.cs2server_id_hash.password,
    csgo_id_hash                 = data.onepassword_item.csgo_id_hash.password,
    tf2_id_hash                  = data.onepassword_item.tf2_id_hash.password,
    discord_webhook              = data.onepassword_item.discord_webhook.password
  }))
}
 */
variable "game_server_type" {}
variable "steampass" {}
