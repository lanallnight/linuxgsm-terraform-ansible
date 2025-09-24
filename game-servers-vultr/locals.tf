locals {
  # Define game ports based on game server type. During the output this assumes
  game_server_ports = {
    "mcserver"     = ["25565"]                   # Working
    "tf2server"    = ["27015", "27036", "27020"] # Working
    "qlserver"     = ["27960", "5222"]           # Working
    "pwserver"     = ["8211", "27015"]           # Working #PalWorld
    "csgoserver"   = ["27015", "27036", "27020", "27031-27036"]
    "cs2server"    = ["27015", "27036", "27020", "27031-27036"]
    "utserver"     = ["27015", "27036"]
    "rtcwserver"   = ["28960", "27960"]
    "ut99server"   = ["7787", "28902", "7777", "7778"]
    "bf1942server" = ["14567", "23000"]
    "ut2k4server"  = ["7787", "28902", "7777", "7778"]
  }
}
