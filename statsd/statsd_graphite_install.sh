#!/bin/bash


 
# proxy variable
export http_proxy=http://192.168.0.35:3128/
export no_proxy=localhost,127.0.0.0/8,127.0.1.1
# set up of the proxy file for quick updates
echo 'Acquire::http::Proxy "http://192.168.0.35:3142/";' > 00proxy

sudo mv 00proxy /etc/apt/apt.conf.d/



# Install git to get statsd
sudo apt-get install git -y
 
# System level dependencies for Graphite
sudo apt-get install --assume-yes apache2 apache2-mpm-worker apache2-utils apache2.2-bin apache2.2-common libapr1 libaprutil1 libaprutil1-dbd-sqlite3 python3.1 libpython3.1 python3.1-minimal libapache2-mod-wsgi libaprutil1-ldap memcached python-cairo-dev python-django python-ldap python-memcache python-pysqlite2 sqlite3 erlang-os-mon erlang-snmp rabbitmq-server bzr expect ssh libapache2-mod-python python-setuptools

# load node.js
wget http://nodejs.org/dist/v0.10.0/node-v0.10.0.tar.gz
tar zxvf node-v0.10.0.tar.gz 
cd node-v0.10.0/
./configure
make
sudo make install
cd ~


wget https://launchpad.net/graphite/0.9/0.9.10/+download/graphite-web-0.9.10.tar.gz
wget http://launchpad.net/graphite/0.9/0.9.9/+download/carbon-0.9.10.tar.gz
wget http://launchpad.net/graphite/0.9/0.9.9/+download/whisper-0.9.0.tar.gz
tar -zxvf graphite-web-0.9.9.tar.gz
tar -zxvf carbon-0.9.9.tar.gz
tar -zxvf whisper-0.9.9.tar.gz
mv graphite-web-0.9.9 graphite
mv carbon-0.9.9 carbon
mv whisper-0.9.9 whisper
rm carbon-0.9.9.tar.gz
rm graphite-web-0.9.9.tar.gz
rm whisper-0.9.9.tar.gz
sudo easy_install django-tagging




# unset http_proxy
 
# Get latest pip
#sudo -E pip install --upgrade pip
 
# Install carbon and graphite deps
#cat >> /tmp/graphite_reqs.txt << EOF
#django==1.3
#python-memcached
#django-tagging
#twisted
#whisper==0.9.9
#carbon==0.9.9
#graphite-web==0.9.9
#EOF

 
#sudo -E pip install -r /tmp/graphite_reqs.txt

####################################
# INSTALL WHISPER
####################################
 
cd ~/whisper
sudo python setup.py install
 
####################################
# INSTALL CARBON
####################################
 
cd ~/carbon
sudo python setup.py install
# CONFIGURE CARBON
####################

#
# Configure carbon
#
cd /opt/graphite/conf/

sudo cp carbon.conf.example carbon.conf
sudo cp storage-schemas.conf.example storage-schemas.conf

# Create storage schema and copy it over
# Using the sample as provided in the statsd README
# https://github.com/etsy/statsd#graphite-schema
 
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

####################################
# CONFIGURE GRAPHITE (webapp)
####################################
 
cd ~/graphite
sudo python check-dependencies.py
sudo python setup.py install
 
# CONFIGURE APACHE
###################
cd ~/graphite/examples
sudo cp example-graphite-vhost.conf /etc/apache2/sites-available/default
sudo cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
sudo vim /etc/apache2/sites-available/default
# moved 'WSGIImportScript /opt/gr..' to right before virtual host since it gave me an error saying
# WSGIImportScript cannot occur within <VirtualHost> section
# if this path does not exist make it!!!!!!
# /etc/httpd/wsgi
sudo mkdir /etc/httpd
sudo mkdir /etc/httpd/wsgi
sudo /etc/init.d/apache2 reload
 
####################################
# INITIAL DATABASE CREATION
####################################
cd /opt/graphite/webapp/graphite/
sudo python manage.py syncdb
# follow prompts to setup django admin user
sudo chown -R www-data:www-data /opt/graphite/storage/
sudo /etc/init.d/apache2 restart
cd /opt/graphite/webapp/graphite
sudo cp local_settings.py.example local_settings.py
 
####################################
# START CARBON
####################################
cd /opt/graphite/
sudo ./bin/carbon-cache.py start
 
####################################
# SEND DATA TO GRAPHITE
####################################
cd ~/graphite/examples
sudo chmod +x example-client.py
# [optional] edit example-client.py to report data faster
# sudo vim example-client.py
sudo ./example-client.py




sleep 15


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
