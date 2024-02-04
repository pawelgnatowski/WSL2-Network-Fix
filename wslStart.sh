#!/bin/bash
# for systemd enabled WSL2 
# run this file viw command in wsl.conf in /etc/wsl.conf
# assumes docker engine already installed.
# Change hyper-v WSL network to bridge mode (LAN) - WLAN idk if will work. had some issues with it in the past so did not try
# File to which the line will be inserted
FILE="/etc/resolv.conf"

# Line to insert - enables internet names resolution
INSERT_LINE="nameserver 1.0.0.1"

# Keyword to search
SEARCH_WORD="nameserver"

# # Create a backup of the original file
cp "$FILE" "${FILE}.bak"

# Use awk to insert the line before the line containing the keyword - beacuse nameresolution is in order - if it is put later might be slow(?)
awk -v insert_line="$INSERT_LINE" -v search_word="$SEARCH_WORD" \
'{
    if ($0 ~ search_word) {
        print insert_line
    }
    print $0
}' "${FILE}.bak" > "$FILE"

# Remove the backup file if you don't need it
rm "${FILE}.bak"

# setup your network params here - 192.168.1.10/24 static IP for WSL instance - via 192.168.50.1 Gateway - e.g. home router to expose services
sudo ip addr flush eth0 && sudo ip addr add 192.168.1.10/24 brd + dev eth0 && sudo ip route delete default; sudo ip route add default via 192.168.1.1
systemctl start docker
# fix for broken vs code connection - run windows terminal - wsl then when you get in:
# rm -rf .vscode-server.
