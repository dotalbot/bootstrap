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

# Clean up nameserver
cd ~
cat <<EOF >resolv.conf
nameserver 192.168.0.17
EOF
sudo mv resolv.conf /etc/ 


#hostname variable

# proxy variable
export http_proxy=http://192.168.0.35:3128/
export no_proxy=localhost,127.0.0.0/8,127.0.1.1
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

sudo apt-get install byobu -y
sudo apt-get install dos2unix -y

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


# Change of hostname
 

git clone https://github.com/dotalbot/bootstrap.git



