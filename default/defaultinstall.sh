#!/bin/bash

# DEFAULT INSTALL SCRIPT
# VER. 0.1.0 - 
# Copyright (c) 2008-2013 Maxtec Peripherals 
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================

#Setup DNS perm
echo 'nameserver 192.168.0.17' > resolv.conf
sudo mv resolv.conf /etc
sudo rm resolv.conf
sudo chattr +i /etc/resolv.conf

sudo sed -i -e 's|http://us.|http://za.|' /etc/apt/sources.list


# proxy variable

# set up of the proxy file for quick updates
echo 'Acquire::http::Proxy "http://192.168.0.35:3142/";' > 00proxy

sudo mv 00proxy /etc/apt/apt.conf.d/

# Update the package list
sudo apt-get update

# Install the latest releases
sudo apt-get upgrade -y

# Install git hub
sudo apt-get install git -y

#Install java elements
sudo apt-get install openjdk-7-jre -y
sudo apt-get install openjdk-7-jdk -y
sudo apt-get install unzip -y
sudo apt-get install build-essential -y
sudo apt-get install openjdk-7-jdk -y

# Install of basic GUI interface + vnc
#sudo apt-get install --no-install-recommends xubuntu-desktop -y
sudo apt-get install xubuntu-desktop -y
sudo apt-get install x11vnc -y

# Making sure openssh-server is install
sudo apt-get install openssh-server -y

# Geany for development work + firefox
sudo apt-get install geany -y
sudo apt-get install firefox -y

# Setup the host to get NTP updates automatically and get an update
sudo ntpdate ntp.is.co.za


# Creation of the file:
echo '#!/bin/sh' > ntpdate
echo '# This is IS ntp server, ip used just incase DNS is down' >> ntpdate
echo '/usr/sbin/ntpdate 196.4.160.4 > /var/log/ntpdate' >> ntpdate
echo '/usr/sbin/ntpdate ntp.is.co.za > /var/log/ntpdate2' >> ntpdate

sudo mv ntpdate /etc/cron.hourly
sudo chmod +x /etc/cron.hourly/ntpdate
sudo chmod 755 /etc/cron.hourly/ntpdate
# To make sure tha cron runs it.
sudo service cron restart

# Pull down bootstrap dir
rm -rf bootstrap
git clone https://github.com/dotalbot/bootstrap.git

# Install of the x11vnc config file for lightdm vnc launch
cd bootstrap
cd default
sudo cp -rf x11vnc.conf /etc/init 

# Setup of password for vnc
sudo x11vnc -storepasswd /etc/x11vnc.pass

# Make the user aware that you are going to reboot in 10 seconds unless they halt the script
sudo shutdown -r +2 "Rebooting in two minutes unless you stop it"





