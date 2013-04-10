#!/bin/bash

#  REDIS LOGSTASH BUILDER 
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

# Inclusion of the redis executable from Ubuntu apt-get
sudo apt-get update && sudo apt-get install redis-server


# Configuration of the listening port for Redis and restart of service
sudo sed -i -e 's|bind 127.0.0.1|bind 0.0.0.0|' /etc/redis/redis.conf

sudo service redis-server restart

# Testing Redis connection
sleep 3
redis-cli ping
sleep 3

# Include SysCtl file to address memory shortfall
sudo cp sysctl.conf /etc

echo "Server will restart in 10 seconds to take change into effect, halt script if you need it not too!"

sleep 12

sudo init 6




