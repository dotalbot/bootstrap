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
#sudo apt-get install --assume-yes apache2 apache2-mpm-worker apache2-utils apache2.2-bin apache2.2-common libapr1 libaprutil1 libaprutil1-dbd-sqlite3 python3.1 libpython3.1 python3.1-minimal libapache2-mod-wsgi libaprutil1-ldap memcached python-cairo-dev python-django python-ldap python-memcache python-pysqlite2 sqlite3 erlang-os-mon erlang-snmp rabbitmq-server bzr expect ssh libapache2-mod-python python-setuptools

sudo apt-get install apache2 libapache2-mod-wsgi libapache2-mod-python memcached python-dev python-cairo-dev python-django python-ldap python-memcache python-pysqlite2  python-pip sqlite3 erlang-os-mon erlang-snmp rabbitmq-server
sudo pip install django-tagging
sudo pip install http://launchpad.net/graphite/0.9/0.9.9/+download/whisper-0.9.9.tar.gz
sudo pip install http://launchpad.net/graphite/0.9/0.9.9/+download/carbon-0.9.9.tar.gz
cd /opt/graphite/conf/
sudo cp carbon.conf.example carbon.conf
sudo cp storage-schemas.conf.example storage-schemas.conf

cd ~
wget http://launchpad.net/graphite/0.9/0.9.9/+download/graphite-web-0.9.9.tar.gz
tar -zxvf graphite-web-0.9.9.tar.gz
mv graphite-web-0.9.9 graphite
cd graphite
sudo python check-dependencies.py
sudo python setup.py install
cd examples
sudo cp example-graphite-vhost.conf /etc/apache2/sites-available/default
sudo mkdir /etc/httpd
sudo mkdir /etc/httpd/wsgi
sudo /etc/init.d/apache2 reload
cd /opt/graphite/webapp/graphite/
cd /opt/graphite/
sudo ./bin/carbon-cache.py start

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
