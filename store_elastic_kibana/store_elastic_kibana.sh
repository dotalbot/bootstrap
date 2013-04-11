#!/bin/bash

# STORE: Elasticsearch_Kibana LOGSTASH BUILDER 
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

# Installation of Elastic search 
cd ~
sudo apt-get update
sudo apt-get install openjdk-7-jre-headless -y 

# Take note of the version, at the moment is hard coded 
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.6.deb
sudo dpkg -i elasticsearch-0.20.6.deb
sudo service elasticsearch start

#Initialize Elasticsearch head
sudo /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head

# Install kibana and bind it into Apache
sudo apt-get install libapache2-mod-passenger apache2 ruby ruby1.8-dev libopenssl-ruby rubygems git -y

cd /var/www

sudo git clone --branch=kibana-ruby https://github.com/rashidkpc/Kibana.git --depth=1 kibana
cd kibana
sudo gem install bundle
sudo bundle install

# Setup of the default website 
cd ~
cd bootstrap
cd store_elastic_kibana
sudo rm -rf /etc/apache2/sites-available/default
sudo cp default /etc/apache2/sites-available 
sudo service apache2 restart






