#!/bin/bash

# MONGODB INSTALL SCRIPT
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


# Get the key for mongo db
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

# Include the correct resource for MongoDB
echo deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen > 10gen.list
sudo mv 10gen.list /etc/apt/sources.list.d/

# Update the package list
sudo apt-get update

# Cleanup just in case
sudo service mongodb stop
sudo apt-get remove mongodb-10gen -y

# install of the package
sudo apt-get install mongodb-10gen

# Start of the service
sudo service mongodb start


echo Waiting for the service to start 
sleep 5

echo Output of the logfile to confirm its working:
cat /var/log/mongodb/mongodb.log

ps -ef |grep mongod
