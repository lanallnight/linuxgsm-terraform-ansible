output "ssh-connection-string" {
  value     = "ssh app_server_instance_${var.game_server_type}"
}

output "server-connect-link" {
  value     = "steam://connect/${vultr_instance.server_instance.main_ip}:${ local.game_server_ports[var.game_server_type][0] }"
}
