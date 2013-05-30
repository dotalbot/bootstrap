#!/bin/bash

sudo service rsyslog stop

#curl https://packages.madhouse-project.org/debian/archive-key.txt | sudo apt-key add -

#cat <<EOF >> sources.add 
## Repo's for syslog-ng
#deb       http://packages.madhouse-project.org/debian   wheezy   syslog-ng-3.3
#deb-src   http://packages.madhouse-project.org/debian   wheezy   syslog-ng-3.3
#EOF

#sudo bash -c "cat sources.add >> /etc/apt/sources.list"
#rm -rf sources.add


# Syslog ng install without the mad house
sudo apt-get update
sudo apt-get install syslog-ng -y

sudo cp -rf syslog-ng.conf /etc/syslog-ng/


#sudo apt-get install syslog-ng-core -y
#sudo apt-get install syslog-ng-mod-sql -y
#sudo apt-get install syslog-ng-mod-mongodb -y
#sudo apt-get install syslog-ng-mod-json -y
#sudo apt-get install syslog-ng -y



