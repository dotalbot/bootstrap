#!/bin/bash


 
# proxy variable
export http_proxy=http://192.168.0.35:3128/
export no_proxy=localhost,127.0.0.0/8,127.0.1.1
# set up of the proxy file for quick updates
echo 'Acquire::http::Proxy "http://192.168.0.35:3142/";' > 00proxy

sudo mv 00proxy /etc/apt/apt.conf.d/



# Install git to get statsd
sudo apt-get install git -y
 
#############################
# INSTALL SYSTEM DEPENDENCIES
#############################

sudo apt-get install apache2 libapache2-mod-wsgi libapache2-mod-python memcached python-dev python-cairo-dev python-django python-ldap python-memcache python-pysqlite2 python-pip sqlite3 erlang-os-mon erlang-snmp rabbitmq-server -y

unset http_proxy

sudo pip install django-tagging

#################
# INSTALL WHISPER
#################

sudo pip install http://launchpad.net/graphite/0.9/0.9.9/+download/whisper-0.9.9.tar.gz

################################################
# INSTALL AND CONFIGURE CARBON (data aggregator)
################################################

sudo pip install http://launchpad.net/graphite/0.9/0.9.9/+download/carbon-0.9.9.tar.gz
cd /opt/graphite/conf/
sudo cp carbon.conf.example carbon.conf

cat >> /tmp/storage-schemas.conf << EOF
# Schema definitions for Whisper files. Entries are scanned in order,
# and first match wins. This file is scanned for changes every 60 seconds.
#
# [name]
# pattern = regex
# retentions = timePerPoint:timeToStore, timePerPoint:timeToStore, ...
[stats]
priority = 110
pattern = ^stats\..*
retentions = 10s:6h,1m:7d,10m:1y
EOF
 
sudo cp /tmp/storage-schemas.conf storage-schemas.conf


###########################
# INSTALL GRAPHITE (webapp)
###########################
cd ~
wget http://launchpad.net/graphite/0.9/0.9.9/+download/graphite-web-0.9.9.tar.gz
tar -zxvf graphite-web-0.9.9.tar.gz
mv graphite-web-0.9.9 graphite
cd graphite
sudo python check-dependencies.py
sudo python setup.py install

	
##################
# CONFIGURE APACHE
##################

cd examples
sudo cp example-graphite-vhost.conf /etc/apache2/sites-available/default
sudo cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
sudo mkdir /etc/httpd
sudo mkdir /etc/httpd/wsgi
sudo /etc/init.d/apache2 reload


#########################
# CREATE INITIAL DATABASE 
#########################

cd /opt/graphite/webapp/graphite/
sudo python manage.py syncdb
sudo chown -R www-data:www-data /opt/graphite/storage/
sudo /etc/init.d/apache2 restart
sudo cp local_settings.py.example local_settings.py

################################
# START CARBON (data aggregator)
################################

$ cd /opt/graphite/
$ sudo ./bin/carbon-cache.py start






sleep 15
cd ~



# load node.js
wget http://nodejs.org/dist/v0.10.0/node-v0.10.0.tar.gz
tar zxvf node-v0.10.0.tar.gz 
cd node-v0.10.0/
./configure
make
sudo make install
cd ~

sudo npm install nodeunit

# statsd
cd /opt && sudo git clone git://github.com/etsy/statsd.git
 
# StatsD configuration
cat >> /tmp/localConfig.js << EOF
{
graphitePort: 2003
, graphiteHost: "127.0.0.1"
, port: 8125
}
EOF
 
sudo cp /tmp/localConfig.js /opt/statsd/localConfig.js
