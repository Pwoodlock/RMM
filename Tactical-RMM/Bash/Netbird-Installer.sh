#!/bin/bash
# 
# Netbird Installer for Ubuntu and Debian based Systems. 


apt install ca-certificates curl gnupg -y
curl -sSL https://pkgs.netbird.io/debian/public.key | gpg --dearmor --output /usr/share/keyrings/netbird-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/netbird-archive-keyring.gpg] https://pkgs.netbird.io/debian stable main' | tee /etc/apt/sources.list.d/netbird.list
apt update
apt install netbird
netbird up --management-url https://YOUR_DOAMIN --setup-key YOUR_SETUP_KEY