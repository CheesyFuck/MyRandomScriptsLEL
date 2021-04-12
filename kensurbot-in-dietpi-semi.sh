#!/bin/bash

#semi installer for Kensurbot in dietpi(and possibly rasbian or any debian distro, not bothered to test so meh)
#To anyone is here the way to install this is apt install -y curl dos2unix && curl https://pastebin.com/raw/M669vgvv | dos2unix | bash
#it needs dos2unix cause i made this script in windowsXDDD

FILE0=/usr/bin/userbot
FILE1=/etc/systemd/system/userbot.service



if [ ! -f /mnt/dietpi_userdata/config.env ]; then
	echo -e "\e[0;32m====================================================================\e[0m"
    echo -e "\e[0;31mconfig.env not found...\e[0m pls place the file in /mnt/dietpi_userdata/"
    echo -e "\e[0;32m====================================================================\e[0m"
	exit
fi
apt update
apt upgrade -y
apt -y install git chromium-driver neofetch ffmpeg aria2 build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev nano libssl-dev libpq-dev libxml2-dev libxslt-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev libjpeg-dev curl software-properties-common
cd /root/
# ub installer section
if test -f "$FILE1"; then
    rm -rf "$FILE1"
fi
if test -f "$FILE0"; then
    rm -rf "$FILE1"
fi
git clone https://github.com/DGJM/KensurBot.git && cd KensurBot ; python3.9 -m pip install virtualenv && python3.9 -m virtualenv env && . ./env/bin/activate && pip install -r requirements.txt && ln -s ln -s /mnt/dietpi_userdata/config.env ./
ln -s /root/KensurBot /mnt/dietpi_userdata/
cd /root/
echo '#Aria
sleep 2
aria2c --daemon=true --enable-rpc –rpc-listen-port 8210
sleep 5
#Kensurbot
cd /root/KensurBot && . ./env/bin/activate && python -m userbot' > /usr/bin/userbot
chmod +x /usr/bin/userbot
echo '[Unit]
Description=userbot

[Service]
Type=simple
User=root
RemainAfterExit=yes
#WorkingDirectory=/usr/bin
ExecStart=sh /usr/bin/userbot

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/userbot.service
systemctl enable userbot
systemctl start userbot
echo -e "\e[0;35m[installer] Finished! \e[0m-- do \e[0;32msystemctl status userbot \e[0mif its running fine."