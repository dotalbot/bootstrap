#!/bin/bash

sudo service rsyslog stop

sudo sed -i -e 's|#$ModLoad imudp|$ModLoad imudp|' /etc/rsyslog.conf
sudo sed -i -e 's|#$UDPServerRun 514|$UDPServerRun 514|' /etc/rsyslog.conf

sudo service rsyslog start
