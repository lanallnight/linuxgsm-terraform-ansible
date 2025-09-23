#!/bin/bash
# <UDF name="user" label="System Package to Install" example="sdtdserver" default="sdtdserver">

# Disable firewall
ufw disable

#Set this in the tfvars
dpkg --add-architecture i386
apt-get update
apt install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 libcurl4-gnutls-dev:i386 openjdk-17-jre pigz -y

echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
dpkg --configure -a
apt install steamcmd -y --allow-unauthenticated

# Above for the Packer Image
# Below on server startup

# Setup the server
USER=${ game_server_type }
useradd -m -s /bin/bash -c linuxgsm $USER 
sudo -iu $USER wget -O linuxgsm.sh https://linuxgsm.sh 
sudo -iu $USER chmod +x linuxgsm.sh 
sudo -iu $USER bash linuxgsm.sh $USER 

### Custom Steps
if [ $USER == "terrariaserver" ]; then
   echo "steamuser=${steam_username}" |tee -a $dir/lgsm/config-lgsm/terrariaserver/common.cfg
   echo "steampass=${steam_password}" |tee -a $dir/lgsm/config-lgsm/terrariaserver/common.cfg
   sudo -iu $USER ./$USER auto-install
   sudo -iu $USER ./$USER validate
fi

export dir=$(getent passwd $USER | cut -f6 -d:) 
$dir/$USER auto-install | tee error_ai.log
sudo -iu $USER ./$USER auto-install

# Set server password sv_password "" |tee -a /home/$USER/lgsm/config-lgsm/$USER/common.cfg
# Set hostname for the server hostname "LinuxGSM" |tee -a /home/$USER/lgsm/config-lgsm/$USER/common.cfg
# Set email for server sv_contact "" |tee -a /home/$USER/lgsm/config-lgsm/$USER/common.cfg

#echo "sv_password='${game_server_private_password}'" |tee -a /home/$USER/lgsm/config-lgsm/$USER/common.cfg
echo "hostname 'LANallNIGHT'" |tee -a /home/$USER/lgsm/config-lgsm/$USER/common.cfg
#echo "sv_contact='info@lanallnight.com'" |tee -a /home/$USER/lgsm/config-lgsm/$USER/common.cfg

GAME_SERVER_USER="${steam_username}"
GAME_SERVER_PASSWORD="'${steam_password}'"

if [ $USER == "cs2server" ]; then 
   # App ID 730
   echo "sv_setsteamaccount ${cs2server_id_hash}" |tee -a /home/cs2server/serverfiles/game/csgo/cfg/csgoserver.cfg
   chown cs2server:cs2server /home/cs2server/serverfiles/game/csgo/cfg/csgoserver.cfg
   echo "steamuser='$GAME_SERVER_USER'" |tee -a /home/cs2server/lgsm/config-lgsm/cs2server/common.cfg
   echo "steampass='$GAME_SERVER_PASSWORD'" |tee -a /home/cs2server/lgsm/config-lgsm/cs2server/common.cfg
fi

if [ $USER == "csgoserver" ]; then 
   # App ID 740
   echo "sv_setsteamaccount ${csgo_id_hash}" |tee -a /home/csgoserver/serverfiles/csgo/cfg/csgoserver.cfg
fi

if [ $USER == "tf2server" ]; then
   # App ID 440
   echo "sv_setsteamaccount ${tf2_id_hash}" |tee -a /home/tf2server/serverfiles/tf2/cfg/tf2server.cfg
fi

### Discord Alert
echo "# Discord Alerts | https://github.com/GameServerManagers/LinuxGSM/wiki/Discord
discordalert=\"on\"
discordwebhook=\"${discord_webhook}\"" | tee -a "$dir/lgsm/config-lgsm/$USER/common.cfg"

echo '''[Unit]
Description=LinuxGSM '$USER' Server
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=$USER
WorkingDirectory=/home/'$USER'
ExecStart=/home/'$USER'/'$USER' start
ExecStop=/home/'$USER'/'$USER' stop
Restart=no
RemainAfterExit=yes   #Assume that the service is running after main process exits with code 0

[Install]
WantedBy=multi-user.target
''' |tee -a /etc/systemd/system/$USER".service"

systemctl daemon-reload

sudo -iu $USER ./$USER start
sudo -iu $USER ./$USER monitor
sudo -iu $USER ./$USER ta
