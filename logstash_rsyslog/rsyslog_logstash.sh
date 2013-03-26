#!/bin/bash

# RSYSLOG LOGSTASH BUILDER 
# VER. 0.1.0 - 
# Copyright (c) 2008-2013 Maxtec Peripherals 
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is xxdistributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================

# Add proxy address

#export http_proxy=http://192.168.0.35:8080

#Version of logstash prod to be added

# Cleanup of previous folders
cd ~
rm -rf dev

# Make sure github is installed
sudo apt-get install git

# Java install elements for logstash
sudo apt-get install openjdk-7-jre -y
sudo apt-get install openjdk-7-jdk -y
sudo apt-get install unzip -y
sudo apt-get install build-essential -y
sudo apt-get install openjdk-7-jdk -y
mkdir dev
cd dev

git clone https://github.com/logstash/logstash.git

# Build of logstash
cd logstash
make jar

cd .

mkdir logstash
cd logstash
wget https://logstash.objects.dreamhost.com/release/logstash-1.1.9-monolithic.jar


