#!/bin/bash

# Disable firewall
ufw disable

#Set this in the tfvars
dpkg --add-architecture i386
apt-get update
apt install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 openjdk-17-jre -y

echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
dpkg --configure -a
apt install steamcmd -y --allow-unauthenticated
