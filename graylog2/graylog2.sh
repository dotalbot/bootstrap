#!/bin/bash

# GRAYLOG2 INSTALL SCRIPT
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

# Proxy setting
export http_proxy=http://192.168.0.35:3128/
no_proxy=localhost,127.0.0.0/8,127.0.1.1

# Variables required 
RUBY_VER="1.9.2-p318"
#This is the mongo db portion of the 
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
tail -n 10 /var/log/mongodb/mongodb.log


sleep 30


# Setup of the mongo db permissions
cat <<EOF >mongodbsetup
use admin
db.addUser('admin', 'password123')
db.auth('admin', 'password123')
use graylog2
db.addUser('grayloguser', 'password123')
db.auth('grayloguser', 'password123')
EOF

mongo <mongodbsetup 

rm -rf mongodbsetup

sleep 10
# Installation of elastic search
sudo rm -rf builddownload

mkdir builddownload
cd builddownload

# Cleanup before install
sudo dpkg -r elasticsearch

# Install
wget http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.5.deb
sudo dpkg -i elasticsearch-0.20.5.deb


sudo sed -i -e 's|# cluster.name: elasticsearch|cluster.name: graylog2|' /etc/elasticsearch/elasticsearch.yml

# Restart service
sudo service elasticsearch restart
sleep 10


#Print the results of the cluster info:
echo Results of the elasticsearch cluster info:
curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'
sleep 10
# Download and install of Graylog2 server
# Stop service just in case.
sudo service graylog2-server stop 


cd /opt

sudo rm -rf graylog2-server-0.11.0.tar.gz
sudo rm -rf graylog2-server
sudo wget http://download.graylog2.org/graylog2-server/graylog2-server-0.11.0.tar.gz

sudo tar zxvf graylog2-server-0.11.0.tar.gz
sudo ln -s graylog2-server-0.11.0 graylog2-server
cd graylog2-server

sudo cp /opt/graylog2-server/graylog2.conf{.example,}
sudo cp /opt/graylog2-server/elasticsearch.yml{.example,}
cd /etc

sudo rm -rf graylog2.conf
sudo rm -rf graylog2-elasticsearch.yml

sudo ln -s /opt/graylog2-server/graylog2.conf graylog2.conf
sudo ln -s /opt/graylog2-server/elasticsearch.yml graylog2-elasticsearch.yml
cd -


# Setting up the auth
#sudo sed -i -e 's|mongodb_useauth = true|mongodb_useauth = false|' /etc/graylog2.conf
sudo sed -i -e 's|mongodb_password = 123|mongodb_password = password123|' /etc/graylog2.conf
sudo sed -i -e 's|processor_wait_strategy = sleeping|processor_wait_strategy = blocking|' /etc/graylog2.conf 


cd ~
sudo cp -rf graylog2-server.startup /etc/init.d/graylog2-server
sudo chmod +x /etc/init.d/graylog2-server
sudo update-rc.d graylog2-server defaults
sudo service graylog2-server restart


# Implementation of the web interface
cd /opt
sudo rm -rf graylog2-web-interface-0.11.0
sudo rm -rf graylog2-web-interface 


sudo wget http://download.graylog2.org/graylog2-web-interface/graylog2-web-interface-0.11.0.tar.gz
sudo tar zxvf graylog2-web-interface-0.11.0.tar.gz
sudo ln -s graylog2-web-interface-0.11.0 graylog2-web-interface


# Major components around ruby, apache etc...
#!/bin/bash
#
# This script was originally from https://github.com/joshfng/railsready
#

RUBY_VER="1.9.2-p318"
RUBYGEMS_VER="1.8.21"

shopt -s extglob
set -e

# Check if the user has sudo privileges.
sudo -v >/dev/null 2>&1 || { echo $(whoami) has no sudo privileges ; exit 1; }

echo "This script installs Ruby ${RUBY_VER} and Rubygems ${RUBYGEMS_VER}"

# Update the system
sudo apt-get update
sudo apt-get upgrade -y

# Install wget & curl before continuing
sudo apt-get -y install wget curl

# Install build tools
sudo apt-get -y install wget curl build-essential bison openssl zlib1g zlib1g-dev libxslt1.1 libssl-dev \
libxslt1-dev libxml2 libffi-dev libyaml-dev libxslt-dev autoconf libc6-dev libreadline6-dev zlib1g-dev \
libffi-dev libffi-ruby

# Install Ruby to /usr/local
curl http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-${RUBY_VER}.tar.gz --O /tmp/ruby-${RUBY_VER}.tar.gz
cd /tmp && tar -xzf /tmp/ruby-${RUBY_VER}.tar.gz
cd ruby-${RUBY_VER}
./configure --prefix=/usr/local
make
sudo make install
cd /tmp

# Install Rubygems
curl http://production.cf.rubygems.org/rubygems/rubygems-${RUBYGEMS_VER}.tgz --O /tmp/rubygems-${RUBYGEMS_VER}.tgz
cd /tmp && tar -xzf /tmp/rubygems-${RUBYGEMS_VER}.tgz

cd rubygems-${RUBYGEMS_VER}
sudo /usr/local/bin/ruby setup.rb
cd /tmp

# Clean up downloaded files in /tmp
sudo rm -rf /tmp/rubygems-${RUBYGEMS_VER}*
sudo rm -rf /tmp/ruby-${RUBY_VER}*

# Set up users
sudo useradd graylog2 -d /opt/graylog2-web-interface
sudo chown -R graylog2:graylog2 /opt/graylog2-web-interface*
sudo usermod -G root graylog2

sudo sed -i -e 's|username:|username: grayloguser|' /opt/graylog2-web-interface/config/mongoid.yml
sudo sed -i -e 's|password:|password: password123|' /opt/graylog2-web-interface/config/mongoid.yml


cd /opt/graylog2-web-interface
sudo gem install bundler --no-ri --no-rdoc
sudo bundle install


sudo apt-get install apache2 libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libcurl4-openssl-dev apache2-prefork-dev libapr1-dev

sudo gem install passenger
sudo passenger-install-apache2-module -a

echo need to add that bit

sudo service apache2 restart

cd ~
cat <<EOF >graylog2
<VirtualHost *:80>
    ServerName 192.168.0.34 
    ServerAlias 192.168.0.34 
    DocumentRoot /opt/graylog2-web-interface/public

    <Directory /opt/graylog2-web-interface/public>
        Allow from all
        Options -MultiViews
    </Directory>

    ErrorLog /var/log/apache2/error.log
    LogLevel warn
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF
sudo mv graylog2 /etc/apache2/sites-available

sudo a2ensite graylog2

cat > httpd.conf << HTTPD_CONF
LoadModule passenger_module /usr/local/lib/ruby/gems/1.9.1/gems/passenger-3.0.19/ext/apache2/mod_passenger.so
   PassengerRoot /usr/local/lib/ruby/gems/1.9.1/gems/passenger-3.0.19
   PassengerRuby /usr/local/bin/ruby
HTTPD_CONF

sudo mv httpd.conf /etc/apache2

sudo service apache2 restart
exit
echo "###############################################"
echo "           Installation is complete!           "
echo "###############################################"
echo " This server is going to restart in 30 seconds "
echo "   Stop the script if you don't want a restart "

sleep 35
sudo init 6






