#!/bin/bash

#semi installer for Kensurbot in dietpi(and possibly rasbian or any debian distro, not bothered to test so meh)
#To anyone is here the way to install this is apt install -y curl dos2unix && curl https://pastebin.com/raw/M669vgvv | dos2unix | bash
#it needs dos2unix cause i made this script in windowsXDDD
echo -e "\e[0;35m[installer] Notice! \e[0m-- Make sure Your running under the root user. NOT sudo, if you do you may continue"
read -p "Press Enter to Continue..."
FILE0=/usr/bin/userbot
FILE1=/etc/systemd/system/userbot.service
confLoc0=/mnt/dietpi_userdata
confLoc1=/mnt/dietpi_userdata/userbots/ub_configs/KensurBot
ubInstallLoc=/mnt/dietpi_userdata/userbots/KensurBot  #also edit this part in line 60
ubInstallLocRoot=/mnt/dietpi_userdata/userbots
pythonSetupLocRoot=/mnt/dietpi_userdata/userbots/python

if [ ! -f $confLoc1/config.env ]; then
	if [ ! -f $confLoc0/config.env ]; then
		echo -e "\e[0;32m====================================================================\e[0m"
		echo -e "\e[0;31mconfig.env not found...\e[0m pls place the file in /mnt/dietpi_userdata/"
		echo -e "\e[0;32m====================================================================\e[0m"
		exit
	fi
fi

if [ -f $confLoc0/config.env ]; then
	if [ ! -f $confLoc1/config.env ]
	then
		mkdir -p $confLoc1
		mv $confLoc0/config.env $confLoc1/config.env
		configmessage0=true
	else
		configmessage0=false
	fi
fi

if [ -d "$ubInstallLoc" ] 
then
    rm -rf $ubInstallLoc
	systemctl stop userbot
fi
# crontab for something ig
crontab -l > cronlist.txt
if grep -Fxq "*/5 17-23 * * * ping -c1 8.8.8.8" cronlist.txt
then
    # code if found
        echo 'It Already Exist so men'
else
    # code if not found
        echo '*/5 17-23 * * * ping -c1 8.8.8.8' >> cronlist.txt
		crontab cronlist.txt
fi
rm cronlist.txt
apt update
apt upgrade -y
# all is prerequisites 
apt -y install git chromium-driver fdupes neofetch ffmpeg aria2 build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev nano libssl-dev libpq-dev libxml2-dev libxslt-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev libjpeg-dev curl software-properties-common
cd /root/
# ub installer section
if test -f "$FILE1"; then
    rm -rf "$FILE1"
	systemctl disable userbot
fi
if test -f "$FILE0"; then
    rm -rf "$FILE0"
fi
cd $ubInstallLocRoot
git clone https://github.com/DGJM/KensurBot.git && cd KensurBot ; python3.9 -m pip install virtualenv && python3.9 -m virtualenv env && . ./env/bin/activate && pip install -r requirements.txt && ln -s ln -s $confLoc1/config.env $ubInstallLoc
cd /root/
echo '#Aria
aria2c --daemon=true --enable-rpc –rpc-listen-port 8210
echo waiting aria to execute.....if failed then change delay lmao
sleep 8
#Kensurbot
cd /mnt/dietpi_userdata/userbots/KensurBot && . ./env/bin/activate && python -m userbot' > /usr/bin/userbot
chmod +x /usr/bin/userbot
echo '[Unit]
Description=userbot

[Service]
Type=simple
User=root
RemainAfterExit=no
#WorkingDirectory=/usr/bin
ExecStart=sh /usr/bin/userbot

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/userbot.service
systemctl enable userbot
systemctl start userbot
if [ "$configmessage0" == "true" ]
	then
		echo -e "\e[0;36m[installer] Notice! \e[0m-- config.env has been moved to $confLoc1"
	else
		if [ "$configmessage0" == "false" ]
		then
			echo -e "\e[0;32m[installer] Notice! \e[0m-- config.env already exist at $confLoc1 pls check"
		fi
fi
chmod 777 $ubInstallLocRoot
echo -e "\e[0;35m[installer] Finished! \e[0m-- do \e[0;32msystemctl status userbot \e[0mif its running fine."