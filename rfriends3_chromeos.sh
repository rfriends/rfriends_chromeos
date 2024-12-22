#!/bin/bash
# -----------------------------------------
# install rfriends for chromeos linux env.
# -----------------------------------------
# 0.90 2024/03/27 new (copy rfriends3_ubuntu_full)
# 0.91 2024/03/30 modify smb.conf
# 0.92 2024/10/29 add webdav
# 0.93 2024/11/04 add dirindex.css
# 1.00 2024/12/14 github
ver=1.00
# -----------------------------------------
echo
echo rfriends3 for chromeos linux env. $ver
echo
SITE=https://github.com/rfriends/rfriends3/releases/latest/download
SCRIPT=rfriends3_latest_script.zip
# -----------------------------------------
user=`whoami`
dir=.
userstr="s/rfriendsuser/${user}/g"
# -----------------------------------------
ar=`dpkg --print-architecture`
bit=`getconf LONG_BIT`
echo
echo architecture is $ar $bit bits .
echo user is $user .
# -----------------------------------------
echo
echo install tools
echo
#
sudo apt-get update && sudo apt-get -y install \
unzip p7zip-full nano vim dnsutils iproute2 tzdata \
at cron wget curl atomicparsley \
php-cli php-xml php-zip php-mbstring php-json php-curl php-intl \
ffmpeg

sudo apt-get -y install chromium-browser
sudo apt-get -y install samba
sudo apt-get -y install lighttpd lighttpd-mod-webdav php-cgi
#sudo apt-get -y install openssh-server
# -----------------------------------------
echo
echo install rfriends3
echo
cd ~/
pkg install git -y
git clone https://github.com/rfriends/rfriends_chromeos.git
cd rfriends_chromeos
sh rfriends3_chromeos.sh
# -----------------------------------------
echo
echo configure samba
echo

#sudo mkdir -p /var/log/samba
#sudo chown root.adm /var/log/samba

mkdir -p /home/$user/smbdir/usr2/

sudo cp -p /etc/samba/smb.conf /etc/samba/smb.conf.org
sudo sed -e ${userstr} $dir/smb.conf.skel > $dir/smb.conf
sudo cp -p $dir/smb.conf /etc/samba/smb.conf
sudo chown root:root /etc/samba/smb.conf

#sudo systemctl restart smbd nmbd
#sudo service smbd restart
# for linux env.
# sudo smbd -D -p 4445
sudo service smbd restart
# -----------------------------------------
echo
echo configure usrdir
echo
mkdir -p /home/$user/tmp/
sed -e ${userstr} $dir/usrdir.ini.skel > /home/$user/rfriends3/config/usrdir.ini
# -----------------------------------------
echo
echo configure lighttpd
echo

sudo cp -p /etc/lighttpd/conf-available/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf.org
sudo sed -e ${userstr} $dir/15-fastcgi-php.conf.skel > $dir/15-fastcgi-php.conf
sudo cp -p $dir/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo chown root:root /etc/lighttpd/conf-available/15-fastcgi-php.conf

sudo cp -p /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org
sudo sed -e ${userstr} $dir/lighttpd.conf.skel > $dir/lighttpd.conf
sudo cp -p $dir/lighttpd.conf /etc/lighttpd/lighttpd.conf
sudo chown root:root /etc/lighttpd/lighttpd.conf

mkdir -p /home/$user/lighttpd/uploads/
cd /home/$user/rfriends3/script/html
ln -nfs temp webdav
cd ~/

sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php

#sudo systemctl restart lighttpd
sudo service lighttpd restart
# -----------------------------------------
#ip=`ip -4 -br a`
#echo
#echo ip address is $ip .
#echo
#echo visit rfriends at http://xxx.xxx.xxx.xxx:8000 .
#echo ex : http://192.168.1.100:8000
#echo
# -----------------------------------------
# finish
# -----------------------------------------
echo finished
# -----------------------------------------
