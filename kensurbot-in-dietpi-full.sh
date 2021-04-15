#!/bin/bash

# check if scipt running under user root
echo -e "\e[0;32m[installer] Notice! \e[0m-- checking if script running under root user/account"
cd /root/
if [ $? -eq 0 ]; then
		echo OK
	else
		echo -e "\e[0;31mSomething Went horribly wrong.... did you run this script under root user/account?\e[0m"
		exit
	fi
	
#semi installer for Kensurbot in dietpi(and possibly rasbian or any debian distro, not bothered to test so meh)
#To anyone is here the way to install this is apt install -y curl dos2unix && curl https://pastebin.com/raw/M669vgvv | dos2unix | bash
#it needs dos2unix cause i made this script in windowsXDDD


confLoc0=/mnt/dietpi_userdata
confLoc1=/mnt/dietpi_userdata/userbots/ub_configs/KensurBot
ubInstallLoc=/mnt/dietpi_userdata/userbots/KensurBot  #also edit this part in line 60
ubInstallLocRoot=/mnt/dietpi_userdata/userbots
pythonSetupLocRoot=/mnt/dietpi_userdata/userbots/python
#change this if theres any new python versions:P
pyver=3.9.4

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
	# check if scipt running under user root
	echo -e "\e[0;32m[installer] Notice! \e[0m-- checking if script running under root user/account"
	cd /root/
	if [ $? -eq 0 ]; then
			echo OK
		else
			echo -e "\e[0;31mSomething Went horribly wrong.... did you run this script under root user/account?\e[0m"
			exit
		fi
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
# python installer
mkdir -p $pythonSetupLocRoot
# check if scipt running under user root
echo -e "\e[0;32m[installer] Notice! \e[0m-- checking if script running under root user/account again the second time just to be sure:P"
cd /root/
if [ $? -eq 0 ]; then
		echo OK
	else
		echo -e "\e[0;31mSomething Went horribly wrong.... did you run this script under root user/account?\e[0m"
		exit
	fi
cd $pythonSetupLocRoot
wget https://www.python.org/ftp/python/$pyver/Python-$pyver.tgz && tar -xf Python-$pyver.tgz && cd Python-$pyver && ./configure --enable-optimizations && make -j 2 && make altinstall
rm $pythonSetupLocRoot
cd /root/
# config git username or email just so supdate will work 
git config --global --list > gitlol.txt
gitlol=$(<gitlol.txt)
case "$gitlol" in
*user.name* ) echo 'It Already Exist so meh' ; emailerr=true ;;
*      ) echo applying git username placeholder ; git config --global user.email "dietpi@dietpi.lol" ; emailerr=false ;;
esac
case "$gitlol" in
*user.name* ) echo 'It Already Exist so meh' ; usern=true ;;
*      ) echo applying git username placeholder ; git config --global user.name "dietpi" ; usern=false ;;
esac
#git setting checking junk..... sets git acount if missing
if [ "$usern" == "true" ]
	then
		setn="\e[0;32m[using your own git username]\e[0m"
	else
		setn="\e[0;32m[using placeholder(eg. dietpi) git email]\e[0m"
fi

if [ "$emailerr" == "true" ]
	then
		setem="\e[0;32m[using your own git email]\e[0m"
	else
		setem="\e[0;32m[using placeholder(eg. dietpi@dietpi.lol) git email]\e[0m"
fi
rm gitlol.txt
# ub installer section
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
chmod -R 777 $ubInstallLocRoot
echo -e "\e[0;33m[installer] Git Account Summary! \e[0m-- Email == $setem || Username == $setn\e[0m'"
echo -e "\e[0;35m[installer] Finished! \e[0m-- do \e[0;32msystemctl status userbot \e[0mif its running fine."